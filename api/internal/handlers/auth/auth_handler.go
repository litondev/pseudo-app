package auth

import (
	"api/internal/middlewares"
	"api/internal/models"
	"api/internal/services/auth"
	"net/http"
	"strconv"

	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
)

type AuthHandler struct {
	authService auth.AuthService
	validator   *validator.Validate
}

func NewAuthHandler(authService auth.AuthService) *AuthHandler {
	return &AuthHandler{
		authService: authService,
		validator:   validator.New(),
	}
}

// SignUp handles user registration
// @Summary Register a new user
// @Description Register a new user with name, email and password
// @Tags Authentication
// @Accept json
// @Produce json
// @Param request body models.RegisterRequest true "Registration request"
// @Success 200 {object} models.AuthResponse
// @Failure 422 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /api/v1/auth/signup [post]
func (h *AuthHandler) SignUp(c *fiber.Ctx) error {
	var req models.RegisterRequest
	
	if err := c.BodyParser(&req); err != nil {
		return c.Status(http.StatusUnprocessableEntity).JSON(fiber.Map{
			"message": "failed",
			"error":   "Invalid request body",
		})
	}

	if err := h.validator.Struct(&req); err != nil {
		return c.Status(http.StatusUnprocessableEntity).JSON(fiber.Map{
			"message": "failed",
			"error":   "Validation failed",
			"details": err.Error(),
		})
	}

	response, err := h.authService.Register(&req)
	if err != nil {
		// Record failed registration attempt
		middlewares.RecordAuthAttempt("signup", "failure")
		
		if err.Error() == "email already registered" {
			return c.Status(http.StatusUnprocessableEntity).JSON(fiber.Map{
				"message": "failed",
				"error":   err.Error(),
			})
		}
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"message": "failed",
			"error":   "Internal server error",
		})
	}

	// Record successful registration attempt
	middlewares.RecordAuthAttempt("signup", "success")
	middlewares.RecordJWTTokenIssued()

	return c.Status(http.StatusOK).JSON(response)
}

// SignIn handles user login
// @Summary Login user
// @Description Login user with email and password
// @Tags Authentication
// @Accept json
// @Produce json
// @Param request body models.AuthRequest true "Login request"
// @Success 200 {object} models.AuthResponse
// @Failure 422 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /api/v1/auth/signin [post]
func (h *AuthHandler) SignIn(c *fiber.Ctx) error {
	var req models.AuthRequest
	
	if err := c.BodyParser(&req); err != nil {
		return c.Status(http.StatusUnprocessableEntity).JSON(fiber.Map{
			"message": "failed",
			"error":   "Invalid request body",
		})
	}

	if err := h.validator.Struct(&req); err != nil {
		return c.Status(http.StatusUnprocessableEntity).JSON(fiber.Map{
			"message": "failed",
			"error":   "Validation failed",
			"details": err.Error(),
		})
	}

	response, err := h.authService.Login(&req)
	if err != nil {
		// Record failed signin attempt
		middlewares.RecordAuthAttempt("signin", "failure")
		
		if err.Error() == "invalid email or password" {
			return c.Status(http.StatusUnprocessableEntity).JSON(fiber.Map{
				"message": "failed",
				"error":   err.Error(),
			})
		}
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"message": "failed",
			"error":   "Internal server error",
		})
	}

	// Record successful signin attempt
	middlewares.RecordAuthAttempt("signin", "success")
	middlewares.RecordJWTTokenIssued()

	return c.Status(http.StatusOK).JSON(response)
}

// Me handles getting current user information
// @Summary Get current user
// @Description Get current authenticated user information
// @Tags Authentication
// @Produce json
// @Security BearerAuth
// @Success 200 {object} map[string]interface{}
// @Failure 422 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /api/v1/auth/me [get]
func (h *AuthHandler) Me(c *fiber.Ctx) error {
	userIDStr := c.Locals("userID").(string)
	userID, err := strconv.ParseUint(userIDStr, 10, 32)
	if err != nil {
		return c.Status(http.StatusUnprocessableEntity).JSON(fiber.Map{
			"message": "failed",
			"error":   "Invalid user ID",
		})
	}

	user, err := h.authService.GetUserByID(uint(userID))
	if err != nil {
		if err.Error() == "user not found" {
			return c.Status(http.StatusUnprocessableEntity).JSON(fiber.Map{
				"message": "failed",
				"error":   err.Error(),
			})
		}
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"message": "failed",
			"error":   "Internal server error",
		})
	}

	return c.Status(http.StatusOK).JSON(fiber.Map{
		"message": "success",
		"user":    user,
	})
}

// RefreshToken handles token refresh
// @Summary Refresh access token
// @Description Refresh access token using refresh token
// @Tags Authentication
// @Accept json
// @Produce json
// @Param request body models.RefreshTokenRequest true "Refresh token request"
// @Success 200 {object} models.AuthResponse
// @Failure 422 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /api/v1/auth/refresh-token [post]
func (h *AuthHandler) RefreshToken(c *fiber.Ctx) error {
	var req models.RefreshTokenRequest
	
	if err := c.BodyParser(&req); err != nil {
		return c.Status(http.StatusUnprocessableEntity).JSON(fiber.Map{
			"message": "failed",
			"error":   "Invalid request body",
		})
	}

	if err := h.validator.Struct(&req); err != nil {
		return c.Status(http.StatusUnprocessableEntity).JSON(fiber.Map{
			"message": "failed",
			"error":   "Validation failed",
			"details": err.Error(),
		})
	}

	response, err := h.authService.RefreshToken(&req)
	if err != nil {
		return c.Status(http.StatusUnprocessableEntity).JSON(fiber.Map{
			"message": "failed",
			"error":   "Invalid refresh token",
		})
	}

	return c.Status(http.StatusOK).JSON(response)
}

// Logout handles user logout
// @Summary Logout user
// @Description Logout current authenticated user
// @Tags Authentication
// @Produce json
// @Security BearerAuth
// @Success 200 {object} map[string]interface{}
// @Failure 422 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /api/v1/auth/logout [post]
func (h *AuthHandler) Logout(c *fiber.Ctx) error {
	userIDStr := c.Locals("userID").(string)
	userID, err := strconv.ParseUint(userIDStr, 10, 32)
	if err != nil {
		return c.Status(http.StatusUnprocessableEntity).JSON(fiber.Map{
			"message": "failed",
			"error":   "Invalid user ID",
		})
	}

	err = h.authService.Logout(uint(userID))
	if err != nil {
		if err.Error() == "user not found" {
			return c.Status(http.StatusUnprocessableEntity).JSON(fiber.Map{
				"message": "failed",
				"error":   err.Error(),
			})
		}
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"message": "failed",
			"error":   "Internal server error",
		})
	}

	return c.Status(http.StatusOK).JSON(fiber.Map{
		"message": "success",
		"data":    "Successfully logged out",
	})
}