package handlers

import (
	"fmt"
	"net/http"
	lang "github.com/matihost/learning/go/pkg/language"
)

type HttpHandler struct {
	DefaultAnswer string
}

func (v *HttpHandler) Welcome(w http.ResponseWriter, req *http.Request) {
	fmt.Fprintf(w, v.DefaultAnswer)
}

func (v *HttpHandler) Headers(w http.ResponseWriter, req *http.Request) {
	headers := getHeaders(req)
	lang.WriteJSON(w, *headers)
}



func getHeaders(r *http.Request) *map[string]string {
	hdr := make(map[string]string, len(r.Header))
	for k, v := range r.Header {
		hdr[k] = v[0]
	}
	return &hdr
}
