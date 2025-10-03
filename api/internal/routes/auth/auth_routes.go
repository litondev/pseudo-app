package auth

import (
	authHandlers "api/internal/handlers/auth"
	"api/internal/middlewares"

	"github.com/gofiber/fiber/v2"
)

func SetupAuthRoutes(app *fiber.App, authHandler *authHandlers.AuthHandler, jwtMiddleware *middlewares.JWTMiddleware) {
	// Create auth group
	auth := app.Group("/api/v1/auth")

	// Public routes (no authentication required)
	auth.Post("/signin", authHandler.SignIn)
	auth.Post("/signup", authHandler.SignUp)
	auth.Post("/refresh-token", authHandler.RefreshToken)

	// Protected routes (authentication required)
	auth.Get("/me", jwtMiddleware.JWTAuth(), authHandler.Me)
	auth.Post("/logout", jwtMiddleware.JWTAuth(), authHandler.Logout)
}