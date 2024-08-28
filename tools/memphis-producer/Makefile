PROTOC_DIR=$(PWD)/protobuf
DATA_DIR=$(PWD)/../../data/

producer:
	@mkdir -p protobuf
	@mkdir -p data
	@#cp ../../data/ual.proto protobuf/
	@cp ../../data/*.csv data/
	@protoc \
		--proto_path=$(DATA_DIR) \
		--go_opt=paths=source_relative \
		--go_opt=Mual.proto=github.com/arustydev/memphis-producer/protobuf \
		--go_out=$(PROTOC_DIR) \
		$(DATA_DIR)/ual.proto
	@go mod init github.com/arustydev/memphis-producer || true
	@go mod tidy
	@go build -o memphis-producer

clean:
	@rm memphis-producer
	@go clean -modcache
	@rm proto/*.pb.go
