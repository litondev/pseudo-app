package main

import (
	"log"
	"os"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/recover"
	"github.com/joho/godotenv"

	"api/config"
	"api/pkg"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("Warning: .env file not found, using system environment variables")
	}

	// Initialize database
	config.InitDatabase()
	defer config.CloseDatabase()

	// Test database connection
	if err := config.TestConnection(); err != nil {
		log.Fatal("Database connection test failed:", err)
	}

	// Initialize Fiber app
	app := fiber.New(fiber.Config{
		ErrorHandler: func(c *fiber.Ctx, err error) error {
			code := fiber.StatusInternalServerError
			if e, ok := err.(*fiber.Error); ok {
				code = e.Code
			}

			// Log error
			pkg.LogErrorf(err, "Fiber error on %s %s", c.Method(), c.Path())

			return c.Status(code).JSON(fiber.Map{
				"error":   true,
				"message": err.Error(),
			})
		},
	})

	// Add panic recovery middleware
	app.Use(recover.New(recover.Config{
		EnableStackTrace: os.Getenv("APP_DEBUG") == "true",
	}))

	// Add CORS middleware
	app.Use(cors.New(cors.Config{
		AllowOrigins: "*",
		AllowMethods: "GET,POST,HEAD,PUT,DELETE,PATCH,OPTIONS",
		AllowHeaders: "Origin,Content-Type,Accept,Authorization",
	}))

	// Add logger middleware if debug is enabled
	if os.Getenv("APP_DEBUG") == "true" {
		app.Use(logger.New())
	}

	// Setup routes
	setupRoutes(app)

	// Get server configuration
	host := os.Getenv("APP_HOST")
	port := os.Getenv("APP_PORT")
	if host == "" {
		host = "localhost"
	}
	if port == "" {
		port = "8080"
	}

	// Start server
	address := host + ":" + port
	log.Printf("Server starting on http://%s", address)
	
	if err := app.Listen(address); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}

// setupRoutes configures all application routes
func setupRoutes(app *fiber.App) {
	// API v1 group
	v1 := app.Group("/api/v1")

	// Status endpoint
	v1.Get("/status", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"message": "true",
		})
	})

	// Health check endpoint
	v1.Get("/health", func(c *fiber.Ctx) error {
		// Test database connection
		if err := config.TestConnection(); err != nil {
			return c.Status(fiber.StatusServiceUnavailable).JSON(fiber.Map{
				"status":  "unhealthy",
				"message": "Database connection failed",
				"error":   err.Error(),
			})
		}

		return c.JSON(fiber.Map{
			"status":   "healthy",
			"message":  "Service is running",
			"database": "connected",
		})
	})
}