package auth_test

import (
	"api/internal/handlers/auth"
	"api/internal/models"
	"bytes"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gofiber/fiber/v2"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

// MockAuthService is a mock implementation of AuthService
type MockAuthService struct {
	mock.Mock
}

func (m *MockAuthService) Register(req *models.RegisterRequest) (*models.AuthResponse, error) {
	args := m.Called(req)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*models.AuthResponse), args.Error(1)
}

func (m *MockAuthService) Login(req *models.AuthRequest) (*models.AuthResponse, error) {
	args := m.Called(req)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*models.AuthResponse), args.Error(1)
}

func (m *MockAuthService) GetUserByID(id uint) (*models.UserResponse, error) {
	args := m.Called(id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*models.UserResponse), args.Error(1)
}

func (m *MockAuthService) RefreshToken(req *models.RefreshTokenRequest) (*models.AuthResponse, error) {
	args := m.Called(req)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*models.AuthResponse), args.Error(1)
}

func (m *MockAuthService) Logout(userID uint) error {
	args := m.Called(userID)
	return args.Error(0)
}

func setupTestApp() *fiber.App {
	app := fiber.New()
	return app
}

func TestAuthHandler_SignUp_Success(t *testing.T) {
	// Arrange
	app := setupTestApp()
	mockService := new(MockAuthService)
	handler := auth.NewAuthHandler(mockService)

	registerReq := models.RegisterRequest{
		Name:     "John Doe",
		Email:    "john@example.com",
		Password: "password123",
	}

	expectedResponse := &models.AuthResponse{
		User: models.UserResponse{
			ID:    1,
			Name:  "John Doe",
			Email: "john@example.com",
		},
		AccessToken:  "access_token",
		RefreshToken: "refresh_token",
	}

	mockService.On("Register", mock.AnythingOfType("*models.RegisterRequest")).Return(expectedResponse, nil)

	app.Post("/signup", handler.SignUp)

	reqBody, _ := json.Marshal(registerReq)
	req := httptest.NewRequest("POST", "/signup", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")

	// Act
	resp, err := app.Test(req)

	// Assert
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)

	var response map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&response)

	assert.Equal(t, "success", response["message"])
	assert.NotNil(t, response["data"])

	mockService.AssertExpectations(t)
}

func TestAuthHandler_SignUp_ValidationError(t *testing.T) {
	// Arrange
	app := setupTestApp()
	mockService := new(MockAuthService)
	handler := auth.NewAuthHandler(mockService)

	// Invalid request - missing required fields
	registerReq := models.RegisterRequest{
		Name: "John Doe",
		// Missing email and password
	}

	app.Post("/signup", handler.SignUp)

	reqBody, _ := json.Marshal(registerReq)
	req := httptest.NewRequest("POST", "/signup", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")

	// Act
	resp, err := app.Test(req)

	// Assert
	assert.NoError(t, err)
	assert.Equal(t, http.StatusUnprocessableEntity, resp.StatusCode)

	var response map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&response)

	assert.Equal(t, "failed", response["message"])
	assert.NotNil(t, response["errors"])
}

func TestAuthHandler_SignUp_ServiceError(t *testing.T) {
	// Arrange
	app := setupTestApp()
	mockService := new(MockAuthService)
	handler := auth.NewAuthHandler(mockService)

	registerReq := models.RegisterRequest{
		Name:     "John Doe",
		Email:    "john@example.com",
		Password: "password123",
	}

	mockService.On("Register", mock.AnythingOfType("*models.RegisterRequest")).Return(nil, errors.New("email already exists"))

	app.Post("/signup", handler.SignUp)

	reqBody, _ := json.Marshal(registerReq)
	req := httptest.NewRequest("POST", "/signup", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")

	// Act
	resp, err := app.Test(req)

	// Assert
	assert.NoError(t, err)
	assert.Equal(t, http.StatusInternalServerError, resp.StatusCode)

	var response map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&response)

	assert.Equal(t, "failed", response["message"])
	assert.NotNil(t, response["error"])

	mockService.AssertExpectations(t)
}

func TestAuthHandler_SignIn_Success(t *testing.T) {
	// Arrange
	app := setupTestApp()
	mockService := new(MockAuthService)
	handler := auth.NewAuthHandler(mockService)

	loginReq := models.AuthRequest{
		Email:    "john@example.com",
		Password: "password123",
	}

	expectedResponse := &models.AuthResponse{
		User: models.UserResponse{
			ID:    1,
			Name:  "John Doe",
			Email: "john@example.com",
		},
		AccessToken:  "access_token",
		RefreshToken: "refresh_token",
	}

	mockService.On("Login", mock.AnythingOfType("*models.AuthRequest")).Return(expectedResponse, nil)

	app.Post("/signin", handler.SignIn)

	reqBody, _ := json.Marshal(loginReq)
	req := httptest.NewRequest("POST", "/signin", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")

	// Act
	resp, err := app.Test(req)

	// Assert
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)

	var response map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&response)

	assert.Equal(t, "success", response["message"])
	assert.NotNil(t, response["data"])

	mockService.AssertExpectations(t)
}

func TestAuthHandler_SignIn_InvalidCredentials(t *testing.T) {
	// Arrange
	app := setupTestApp()
	mockService := new(MockAuthService)
	handler := auth.NewAuthHandler(mockService)

	loginReq := models.AuthRequest{
		Email:    "john@example.com",
		Password: "wrongpassword",
	}

	mockService.On("Login", mock.AnythingOfType("*models.AuthRequest")).Return(nil, errors.New("invalid credentials"))

	app.Post("/signin", handler.SignIn)

	reqBody, _ := json.Marshal(loginReq)
	req := httptest.NewRequest("POST", "/signin", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")

	// Act
	resp, err := app.Test(req)

	// Assert
	assert.NoError(t, err)
	assert.Equal(t, http.StatusInternalServerError, resp.StatusCode)

	var response map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&response)

	assert.Equal(t, "failed", response["message"])
	assert.NotNil(t, response["error"])

	mockService.AssertExpectations(t)
}

func TestAuthHandler_Me_Success(t *testing.T) {
	// Arrange
	app := setupTestApp()
	mockService := new(MockAuthService)
	handler := auth.NewAuthHandler(mockService)

	expectedUser := &models.UserResponse{
		ID:    1,
		Name:  "John Doe",
		Email: "john@example.com",
	}

	mockService.On("GetUserByID", uint(1)).Return(expectedUser, nil)

	app.Get("/me", func(c *fiber.Ctx) error {
		// Simulate JWT middleware setting userID
		c.Locals("userID", "1")
		return handler.Me(c)
	})

	req := httptest.NewRequest("GET", "/me", nil)

	// Act
	resp, err := app.Test(req)

	// Assert
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)

	var response map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&response)

	assert.Equal(t, "success", response["message"])
	assert.NotNil(t, response["data"])

	mockService.AssertExpectations(t)
}

func TestAuthHandler_Me_Unauthorized(t *testing.T) {
	// Arrange
	app := setupTestApp()
	mockService := new(MockAuthService)
	handler := auth.NewAuthHandler(mockService)

	app.Get("/me", handler.Me)

	req := httptest.NewRequest("GET", "/me", nil)

	// Act
	resp, err := app.Test(req)

	// Assert
	assert.NoError(t, err)
	assert.Equal(t, http.StatusUnauthorized, resp.StatusCode)

	var response map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&response)

	assert.Equal(t, "failed", response["message"])
	assert.Equal(t, "Unauthorized", response["error"])
}

func TestAuthHandler_RefreshToken_Success(t *testing.T) {
	// Arrange
	app := setupTestApp()
	mockService := new(MockAuthService)
	handler := auth.NewAuthHandler(mockService)

	refreshReq := models.RefreshTokenRequest{
		RefreshToken: "valid_refresh_token",
	}

	expectedResponse := &models.AuthResponse{
		AccessToken:  "new_access_token",
		RefreshToken: "new_refresh_token",
	}

	mockService.On("RefreshToken", mock.AnythingOfType("*models.RefreshTokenRequest")).Return(expectedResponse, nil)

	app.Post("/refresh-token", handler.RefreshToken)

	reqBody, _ := json.Marshal(refreshReq)
	req := httptest.NewRequest("POST", "/refresh-token", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")

	// Act
	resp, err := app.Test(req)

	// Assert
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)

	var response map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&response)

	assert.Equal(t, "success", response["message"])
	assert.NotNil(t, response["data"])

	mockService.AssertExpectations(t)
}

func TestAuthHandler_Logout_Success(t *testing.T) {
	// Arrange
	app := setupTestApp()
	mockService := new(MockAuthService)
	handler := auth.NewAuthHandler(mockService)

	mockService.On("Logout", uint(1)).Return(nil)

	app.Post("/logout", func(c *fiber.Ctx) error {
		// Simulate JWT middleware setting userID
		c.Locals("userID", "1")
		return handler.Logout(c)
	})

	req := httptest.NewRequest("POST", "/logout", nil)

	// Act
	resp, err := app.Test(req)

	// Assert
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)

	var response map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&response)

	assert.Equal(t, "success", response["message"])

	mockService.AssertExpectations(t)
}