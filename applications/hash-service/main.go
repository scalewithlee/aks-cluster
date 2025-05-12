package main

import (
	"crypto/md5"
	"crypto/sha1"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	// Define route handlers
	http.HandleFunc("/", rootHandler)
	http.HandleFunc("/md5/", md5Handler)
	http.HandleFunc("/sha1/", sha1Handler)
	http.HandleFunc("/sha256/", sha256Handler)
	http.HandleFunc("/health", healthHandler)

	// Start the server
	log.Printf("Starting server on port %s...", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf("Error starting server: %v", err)
	}
}

func rootHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	fmt.Fprintf(w, `
	<html>
		<head>
			<title>Hash Service</title>
			<style>
				body {
					font-family: Arial, sans-serif;
					max-width: 800px;
					margin: 0 auto;
					padding: 20px;
					line-height: 1.6;
				}
				h1 {
					color: #333;
				}
				.endpoint {
					background-color: #f4f4f4;
					padding: 10px;
					border-radius: 4px;
					margin-bottom: 10px;
				}
			</style>
		</head>
		<body>
			<h1>Hash Service</h1>
			<p>This service provides various hashing functions. Use the following endpoints:</p>

			<div class="endpoint">
				<strong>MD5:</strong> /md5/{string}
			</div>

			<div class="endpoint">
				<strong>SHA1:</strong> /sha1/{string}
			</div>

			<div class="endpoint">
				<strong>SHA256:</strong> /sha256/{string}
			</div>

			<div class="endpoint">
				<strong>Health:</strong> /health
			</div>
		</body>
		</html>
	`)
}

func md5Handler(w http.ResponseWriter, r *http.Request) {
	input := r.URL.Path[5:] // remove "/md5/" prefix
	if input == "" {
		http.Error(w, "No input provided", http.StatusBadRequest)
		return
	}

	hash := md5.Sum([]byte(input))
	hashString := hex.EncodeToString(hash[:])

	fmt.Fprintf(w, "MD5 hash of '%s': %s\n", input, hashString)
}

func sha1Handler(w http.ResponseWriter, r *http.Request) {
	input := r.URL.Path[6:] // Remove "/sha1/" prefix
	if input == "" {
		http.Error(w, "No input provided", http.StatusBadRequest)
		return
	}

	hash := sha1.Sum([]byte(input))
	hashString := hex.EncodeToString(hash[:])

	fmt.Fprintf(w, "SHA1 hash of '%s': %s\n", input, hashString)
}

func sha256Handler(w http.ResponseWriter, r *http.Request) {
	input := r.URL.Path[8:] // Remove "/sha256/" prefix
	if input == "" {
		http.Error(w, "No input provided", http.StatusBadRequest)
		return
	}

	hash := sha256.Sum256([]byte(input))
	hashString := hex.EncodeToString(hash[:])

	fmt.Fprintf(w, "SHA256 hash of '%s': %s\n", input, hashString)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "OK")
}
