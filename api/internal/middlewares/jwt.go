package middlewares

import (
	"api/internal/services/auth"
	"net/http"
	"strconv"
	"strings"

	"github.com/gofiber/fiber/v2"
)

type JWTMiddleware struct {
	jwtService auth.JWTService
}

func NewJWTMiddleware(jwtService auth.JWTService) *JWTMiddleware {
	return &JWTMiddleware{
		jwtService: jwtService,
	}
}

// JWTAuth middleware validates JWT tokens
func (m *JWTMiddleware) JWTAuth() fiber.Handler {
	return func(c *fiber.Ctx) error {
		// Get Authorization header
		authHeader := c.Get("Authorization")
		if authHeader == "" {
			return c.Status(http.StatusUnauthorized).JSON(fiber.Map{
				"message": "failed",
				"error":   "Authorization header is required",
			})
		}

		// Check if header starts with "Bearer "
		if !strings.HasPrefix(authHeader, "Bearer ") {
			return c.Status(http.StatusUnauthorized).JSON(fiber.Map{
				"message": "failed",
				"error":   "Invalid authorization header format",
			})
		}

		// Extract token
		tokenString := strings.TrimPrefix(authHeader, "Bearer ")
		if tokenString == "" {
			return c.Status(http.StatusUnauthorized).JSON(fiber.Map{
				"message": "failed",
				"error":   "Token is required",
			})
		}

		// Validate token
		token, err := m.jwtService.ValidateToken(tokenString)
		if err != nil {
			// Record failed JWT validation
			RecordJWTTokenValidation("invalid")
			
			return c.Status(http.StatusUnauthorized).JSON(fiber.Map{
				"message": "failed",
				"error":   "Invalid or expired token",
			})
		}

		// Record successful JWT validation
		RecordJWTTokenValidation("valid")

		// Extract user ID from token
		userID, err := m.jwtService.ExtractUserID(token)
		if err != nil {
			return c.Status(http.StatusUnauthorized).JSON(fiber.Map{
				"message": "failed",
				"error":   "Invalid token claims",
			})
		}

		// Store user ID in context for use in handlers
		c.Locals("userID", strconv.FormatUint(uint64(userID), 10))

		return c.Next()
	}
}

// OptionalJWTAuth middleware validates JWT tokens but doesn't require them
func (m *JWTMiddleware) OptionalJWTAuth() fiber.Handler {
	return func(c *fiber.Ctx) error {
		// Get Authorization header
		authHeader := c.Get("Authorization")
		if authHeader == "" {
			return c.Next()
		}

		// Check if header starts with "Bearer "
		if !strings.HasPrefix(authHeader, "Bearer ") {
			return c.Next()
		}

		// Extract token
		tokenString := strings.TrimPrefix(authHeader, "Bearer ")
		if tokenString == "" {
			return c.Next()
		}

		// Validate token
		token, err := m.jwtService.ValidateToken(tokenString)
		if err != nil {
			return c.Next()
		}

		// Extract user ID from token
		userID, err := m.jwtService.ExtractUserID(token)
		if err != nil {
			return c.Next()
		}

		// Store user ID in context for use in handlers
		c.Locals("userID", strconv.FormatUint(uint64(userID), 10))

		return c.Next()
	}
}