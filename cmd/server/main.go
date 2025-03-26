package main

import (
	"os"

	"github.com/CaribouBlue/goth-stack/internal/logger"
	"github.com/CaribouBlue/goth-stack/internal/server"
	"github.com/joho/godotenv"
	"github.com/rs/zerolog"
)

func main() {
	godotenv.Load()

	appEnv := os.Getenv("APP_ENV")
	if appEnv == "development" {
		logger.SetDefaultLogger(logger.Default().Output(zerolog.ConsoleWriter{Out: os.Stderr}))
		logger.Default().Warn().Msg("Using development mode")
	} else {
		logFile, _ := os.OpenFile(
			"app.log",
			os.O_APPEND|os.O_CREATE|os.O_WRONLY,
			0664,
		)
		defer logFile.Close()

		logger.SetDefaultLogger(zerolog.New(logFile).Level(zerolog.InfoLevel).With().Timestamp().Logger())
	}

	server := server.NewServer()

	logger.Default().Info().Str("address", server.Addr).Msg("Starting server")
	err := server.ListenAndServe()
	if err != nil {
		logger.Default().Panic().Err(err).Msg("Failed to start server")
	}
}
