package main

import (
	"fmt"
	"net/http"
)

func welcome(w http.ResponseWriter, req *http.Request) {
	fmt.Fprintf(w, "text to be returned\n")
}

func main() {
	fmt.Println("Starting http server.")
	// Register handler function
	http.HandleFunc("/welcome", welcome)
	fmt.Println("Go to localhost:8080/welcome To terminate press CTRL+C")
	// Start server
	http.ListenAndServe(":8080", nil)
}
