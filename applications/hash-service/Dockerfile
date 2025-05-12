# Build stage
FROM golang:1.21-alpine AS build

WORKDIR /app

# Copy go.mod and go.sum
COPY go.mod ./

# Download dependencies
RUN go mod download

# Copy source code
COPY main.go ./

# Build the application
# No need to specify GOARCH - buildx will handle this
RUN CGO_ENABLED=0 GOOS=linux go build -o hash-service .

# Final stage
FROM alpine:3.18

WORKDIR /app

# Copy the binary from the build stage
COPY --from=build /app/hash-service .

# Expose port
EXPOSE 8080

# Run the application
CMD ["./hash-service"]
