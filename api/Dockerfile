# Build stage
FROM golang:1.24.3-alpine AS builder

# Set working directory
WORKDIR /app

# Install dependencies for building
RUN apk add --no-cache git curl

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main ./cmd/main.go

# Final stage
FROM alpine:latest

# Install ca-certificates and curl for health checks
RUN apk --no-cache add ca-certificates curl

# Set working directory
WORKDIR /app

# Create necessary directories
RUN mkdir -p /app/logger /app/asset/images /app/asset/files

# Copy the binary from builder stage
COPY --from=builder /app/main .

# Copy .env.example as .env (will be overridden by docker-compose environment)
COPY --from=builder /app/.env.example ./.env

# Make sure the binary is executable
RUN chmod +x ./main

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/api/v1/health || exit 1

# Run the application
CMD ["./main"]