package main

import (
	"log"
	"os"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/recover"
	"github.com/joho/godotenv"
	"github.com/gofiber/adaptor/v2"
	"github.com/prometheus/client_golang/prometheus/promhttp"

	"api/config"
	"api/internal/middlewares"
	"api/pkg"
	
	// Auth imports
	authHandlers "api/internal/handlers/auth"
	authRepositories "api/internal/repositories/auth"
	authRoutes "api/internal/routes/auth"
	authServices "api/internal/services/auth"
	"api/internal/services/database"
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
	app.Use(middlewares.NewCORS())

	// Add Prometheus metrics middleware
	app.Use(middlewares.PrometheusMiddleware())

	// Add logger middleware if debug is enabled
	if os.Getenv("APP_DEBUG") == "true" {
		app.Use(logger.New())
	}

	// Setup auth dependencies
	userRepo := authRepositories.NewUserRepository(config.GetDB())
	jwtService := authServices.NewJWTService()
	authService := authServices.NewAuthService(userRepo, jwtService)
	authHandler := authHandlers.NewAuthHandler(authService)
	jwtMiddleware := middlewares.NewJWTMiddleware(jwtService)

	// Initialize and start database metrics collection
	metricsService := database.NewMetricsService(config.GetDB())
	metricsService.StartMetricsCollection()

	// Setup routes
	setupRoutes(app, authHandler, jwtMiddleware)

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
func setupRoutes(app *fiber.App, authHandler *authHandlers.AuthHandler, jwtMiddleware *middlewares.JWTMiddleware) {
	// Prometheus metrics endpoint
	app.Get("/metrics", adaptor.HTTPHandler(promhttp.Handler()))

	// Serve Swagger UI static files with proper routing
	app.Static("/swagger", "./asset/swagger", fiber.Static{
		Index: "index.html",
	})
	
	// Serve YAML documentation files
	app.Static("/docs", "./internal/docs")
	
	// Setup auth routes
	authRoutes.SetupAuthRoutes(app, authHandler, jwtMiddleware)
	
	// API v1 group
	v1 := app.Group("/api/v1")

	// Status endpoint
	v1.Get("/status", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"message": "success",
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