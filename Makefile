BIN = forego
SRC = $(shell ls *.go)

TAG := `git describe --tags`
LDFLAGS := -X main.buildVersion=$(TAG) -extldflags -static

CMD := ${GOPATH}/bin/godep go build -ldflags "$(LDFLAGS)"

.Phony: all build clean install test lint

all: build

build: $(BIN)

clean:
	rm -f $(BIN)

install: forego
	cp $< ${GOPATH}/bin/

lint: $(SRC)
	go fmt

test: lint build
	go test ./... -cover
	cd eg && ../forego start

$(BIN): $(SRC)
	 $(CMD) -o $@

dist-clean:
	rm -rf dist
	rm -f forego-linux-*.tar.gz
	rm -f forego-darwin-*.tar.gz

dist: dist-clean
	mkdir -p dist/linux/amd64 && GOOS=linux GOARCH=amd64 $(CMD) -o dist/linux/amd64/forego
	mkdir -p dist/linux/i386  && GOOS=linux GOARCH=386 $(CMD) -o dist/linux/i386/forego
	mkdir -p dist/linux/armel  && GOOS=linux GOARCH=arm GOARM=5 $(CMD) -o dist/linux/armel/forego
	mkdir -p dist/linux/armhf  && GOOS=linux GOARCH=arm GOARM=6 $(CMD) -o dist/linux/armhf/forego
	mkdir -p dist/darwin/amd64 && GOOS=darwin GOARCH=amd64 $(CMD) -o dist/darwin/amd64/forego
	mkdir -p dist/darwin/i386  && GOOS=darwin GOARCH=386 $(CMD) -o dist/darwin/i386/forego


release: dist
	tar -cvzf forego-linux-amd64-$(TAG).tar.gz -C dist/linux/amd64 forego
	tar -cvzf forego-linux-i386-$(TAG).tar.gz -C dist/linux/i386 forego
	tar -cvzf forego-linux-armel-$(TAG).tar.gz -C dist/linux/armel forego
	tar -cvzf forego-linux-armhf-$(TAG).tar.gz -C dist/linux/armhf forego
	tar -cvzf forego-darwin-amd64-$(TAG).tar.gz -C dist/darwin/amd64 forego
	tar -cvzf forego-darwin-i386-$(TAG).tar.gz -C dist/darwin/i386 forego
