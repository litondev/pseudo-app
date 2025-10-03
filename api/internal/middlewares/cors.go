package middlewares

import (
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
)

// CORSConfig holds the configuration for CORS middleware
type CORSConfig struct {
	AllowOrigins     string
	AllowMethods     string
	AllowHeaders     string
	AllowCredentials bool
	ExposeHeaders    string
	MaxAge           int
}

// DefaultCORSConfig returns default CORS configuration
func DefaultCORSConfig() CORSConfig {
	return CORSConfig{
		AllowOrigins:     "*",
		AllowMethods:     "GET,POST,HEAD,PUT,DELETE,PATCH,OPTIONS",
		AllowHeaders:     "Origin,Content-Type,Accept,Authorization,X-Requested-With,X-API-Key,X-Client-ID,X-Client-Version",
		AllowCredentials: false,
		ExposeHeaders:    "Content-Length,Content-Range,X-Total-Count,X-Page-Count",
		MaxAge:           86400, // 24 hours
	}
}

// ProductionCORSConfig returns production-safe CORS configuration
func ProductionCORSConfig() CORSConfig {
	return CORSConfig{
		AllowOrigins:     "http://localhost:3000,http://localhost:8000,https://yourdomain.com",
		AllowMethods:     "GET,POST,HEAD,PUT,DELETE,PATCH,OPTIONS",
		AllowHeaders:     "Origin,Content-Type,Accept,Authorization,X-Requested-With,X-API-Key,X-Client-ID,X-Client-Version",
		AllowCredentials: true,
		ExposeHeaders:    "Content-Length,Content-Range,X-Total-Count,X-Page-Count",
		MaxAge:           3600, // 1 hour
	}
}

// NewCORS creates a new CORS middleware with default configuration
func NewCORS() fiber.Handler {
	config := DefaultCORSConfig()
	
	return cors.New(cors.Config{
		AllowOrigins:     config.AllowOrigins,
		AllowMethods:     config.AllowMethods,
		AllowHeaders:     config.AllowHeaders,
		AllowCredentials: config.AllowCredentials,
		ExposeHeaders:    config.ExposeHeaders,
		MaxAge:           config.MaxAge,
	})
}

// NewCORSWithConfig creates a new CORS middleware with custom configuration
func NewCORSWithConfig(config CORSConfig) fiber.Handler {
	return cors.New(cors.Config{
		AllowOrigins:     config.AllowOrigins,
		AllowMethods:     config.AllowMethods,
		AllowHeaders:     config.AllowHeaders,
		AllowCredentials: config.AllowCredentials,
		ExposeHeaders:    config.ExposeHeaders,
		MaxAge:           config.MaxAge,
	})
}

// NewProductionCORS creates a new CORS middleware with production configuration
func NewProductionCORS() fiber.Handler {
	config := ProductionCORSConfig()
	
	return cors.New(cors.Config{
		AllowOrigins:     config.AllowOrigins,
		AllowMethods:     config.AllowMethods,
		AllowHeaders:     config.AllowHeaders,
		AllowCredentials: config.AllowCredentials,
		ExposeHeaders:    config.ExposeHeaders,
		MaxAge:           config.MaxAge,
	})
}