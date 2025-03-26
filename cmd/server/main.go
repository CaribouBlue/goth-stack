package main

import (
	"log"

	"github.com/CaribouBlue/goth-stack/internal/server"
)

func main() {
	server := server.NewServer()

	log.Println("Starting server on", server.Addr)
	err := server.ListenAndServe()
	if err != nil {
		log.Panicln("Failed to start server", err)
	}
}
