package server

import (
	"net/http"

	"github.com/CaribouBlue/goth-stack/internal/templates"
)

func NewServer() *http.Server {
	rootMux := http.NewServeMux()

	rootMux.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir("static/public"))))
	rootMux.Handle("/", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		templates.LandingPage().Render(r.Context(), w)
	}))

	server := &http.Server{
		Addr:    "127.0.0.1:8080",
		Handler: rootMux,
	}

	return server
}
