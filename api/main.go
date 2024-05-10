package main

import (
	"bytes"
	"context"
	"database/sql"
	"encoding/base64"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/aws/aws-sdk-go-v2/aws"
	aws_config "github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	s3_types "github.com/aws/aws-sdk-go-v2/service/s3/types"
	"github.com/gin-gonic/gin"
	"github.com/h2non/filetype"
	_ "github.com/lib/pq"
)

type album struct {
	Artist string  `json:"artist"`
	Cover  string  `json:"cover"`
	ID     int     `json:"id"`
	Price  float64 `json:"price"`
	Title  string  `json:"title"`
}

var db *sql.DB
var s3_client *s3.Client
var bucket_name string
var bucket_prefix string

func main() {
	var db_host = os.Getenv("DB_HOSTNAME")
	var db_name = os.Getenv("DB_DATABASE_NAME")
	var db_password = os.Getenv("DB_PASSWORD")
	var db_user = os.Getenv("DB_USERNAME")
	var connection_string = fmt.Sprintf("postgres://%s:%s@%s/%s?sslmode=disable", db_user, db_password, db_host, db_name)

	var err error
	db, err = sql.Open("postgres", connection_string)
	if err != nil {
		log.Fatal(err)
	}

	cfg, err := aws_config.LoadDefaultConfig(context.TODO())
	if err != nil {
		log.Fatal(err)
	}

	s3_client = s3.NewFromConfig(cfg)
	bucket_name = os.Getenv("BUCKET_NAME")
	bucket_prefix = os.Getenv("BUCKET_PREFIX")

	router := gin.Default()
	router.GET("/albums", getAlbums)
	router.POST("/albums", createAlbum)
	router.GET("/ping", ping)

	api_port := os.Getenv("API_PORT")
	listen_address := fmt.Sprintf("0.0.0.0:%s", api_port)
	router.Run(listen_address)
}

func getAlbums(c *gin.Context) {
	c.Header("Content-Type", "application/json")

	rows, err := db.Query("SELECT id, title, artist, price, cover FROM albums")
	if err != nil {
		log.Println(err)
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": "Failed to read from the database"})
		return
	}
	defer rows.Close()

	var albums []album
	for rows.Next() {
		var a album
		err := rows.Scan(&a.ID, &a.Title, &a.Artist, &a.Price, &a.Cover)
		if err != nil {
			log.Fatal(err)
		}
		albums = append(albums, a)
	}
	err = rows.Err()
	if err != nil {
		log.Println(err)
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": "Failed to read from the database"})
		return
	}

	c.IndentedJSON(http.StatusOK, albums)
}

func createAlbum(c *gin.Context) {
	c.Header("Content-Type", "application/json")

	var awesomeAlbum album
	err := c.BindJSON(&awesomeAlbum)
	if err != nil {
		log.Println(err)
		c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": "Invalid request payload"})
		return
	}

	decoded, err := base64.StdEncoding.DecodeString(awesomeAlbum.Cover)
	if err != nil {
		log.Println(err)
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode the base64 cover"})
		return
	}

	kind, err := filetype.Match(decoded)
	if err != nil {
		log.Println(err)
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": "Failed to determine filetype"})
		return
	}
	if kind.MIME.Type != "image" {
		c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": "Cover should be an image"})
		return
	}

	s3_key := fmt.Sprintf("%s/%d", bucket_prefix, awesomeAlbum.ID)
	s3_input := s3.PutObjectInput{
		ACL:         s3_types.ObjectCannedACLPublicRead,
		Body:        bytes.NewReader(decoded),
		Bucket:      aws.String(bucket_name),
		ContentType: aws.String(kind.MIME.Value),
		Key:         aws.String(s3_key),
	}

	_, err = s3_client.PutObject(context.TODO(), &s3_input)
	if err != nil {
		log.Println(err)
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": "Failed to upload to the s3 bucket"})
		return
	}

	stmt, err := db.Prepare("INSERT INTO albums (id, title, artist, price, cover) VALUES ($1, $2, $3, $4, $5)")
	if err != nil {
		log.Println(err)
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": "Failed to prepare the sql statement"})
		return
	}
	defer stmt.Close()

	_, err = stmt.Exec(awesomeAlbum.ID, awesomeAlbum.Title, awesomeAlbum.Artist, awesomeAlbum.Price, fmt.Sprintf("http://%s/%s", bucket_name, s3_key))
	if err != nil {
		log.Println(err)
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": "Failed to insert into the database"})
		return
	}

	c.IndentedJSON(http.StatusCreated, gin.H{"response": "ok"})
}

func ping(c *gin.Context) {
	c.IndentedJSON(http.StatusOK, gin.H{"response": "pong"})
}
