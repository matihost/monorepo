package main

import (
	"flag"
	"fmt"
	"net/http"
	handler "github.com/matihost/learning/go/internal/http/handlers"
)

var (
	host = flag.String("host", ":8080", "<host:port>")
	defaultAnswer = flag.String("defaultAnswer", "welcome world", "default HTTP server response")

	httpHandler = handler.HttpHandler{DefaultAnswer: *defaultAnswer}
)


func main() {
	flag.Parse()

	fmt.Println("Starting http server.")
	// Register handler function
	http.HandleFunc("/", httpHandler.Welcome)
	http.HandleFunc("/headers", httpHandler.Headers)
	fmt.Println("Go to :8080/headers  To terminate press CTRL+C")
	// Start server
	http.ListenAndServe(*host, nil)
}
