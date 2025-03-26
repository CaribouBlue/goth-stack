.PHONY: build
build:
	templ generate
	npx @tailwindcss/cli -i ./static/src/main.css -o ./static/public/main.css
	go build -v -o ./bin/app ./cmd/server

.PHONY: start
start:
	go run ./cmd/server/main.go

.PHONY: start-dev
start-dev:
	wgo -file=.go -file=.templ -file=main.css -xfile=_templ.go templ generate :: npx @tailwindcss/cli -i ./static/src/main.css -o ./static/public/main.css :: go run ./cmd/server
