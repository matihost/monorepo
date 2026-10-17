package handlers

import (
	"fmt"
	"log"
	"net/http"

	lang "github.com/matihost/monorepo/go/learning/pkg/language"
)

type HttpHandler struct {
	DefaultAnswer string
}

func (v *HttpHandler) Welcome(w http.ResponseWriter, req *http.Request) {
	if _, err := fmt.Fprintf(w, "%s", v.DefaultAnswer); err != nil {
		log.Printf("failed to write response: %v", err)
	}
}

func (v *HttpHandler) Headers(w http.ResponseWriter, req *http.Request) {
	headers := getHeaders(req)
	if err := lang.WriteJSON(w, *headers); err != nil {
		log.Printf("failed to write headers response: %v", err)
	}
}

func getHeaders(r *http.Request) *map[string]string {
	hdr := make(map[string]string, len(r.Header))
	for k, v := range r.Header {
		hdr[k] = v[0]
	}
	return &hdr
}
