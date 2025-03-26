package logger

import (
	"os"

	"github.com/rs/zerolog"
)

var defaultLogger = zerolog.New(os.Stderr).With().Timestamp().Logger()

func Default() *zerolog.Logger {
	return &defaultLogger
}

func SetDefaultLogger(logger zerolog.Logger) {
	defaultLogger = logger
}
