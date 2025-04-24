package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	port := getPort()

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "✅ Hello this is Soumeet, deployed branch: %s", os.Getenv("BRANCH_NAME"))
	})

	log.Printf("🚀 Server running on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}

func getPort() string {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	return port
}
