package auth_test

import (
	"api/config"
	authHandlers "api/internal/handlers/auth"
	"api/internal/middlewares"
	"api/internal/models"
	authRepositories "api/internal/repositories/auth"
	authRoutes "api/internal/routes/auth"
	authServices "api/internal/services/auth"
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"

	"github.com/gofiber/fiber/v2"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/suite"
	"gorm.io/gorm"
)

type AuthIntegrationTestSuite struct {
	suite.Suite
	app        *fiber.App
	db         *gorm.DB
	testUser   *models.User
	authToken  string
}

func (suite *AuthIntegrationTestSuite) SetupSuite() {
	// Set test environment
	os.Setenv("JWT_SECRET", "test_secret_key")
	os.Setenv("JWT_REFRESH_SECRET", "test_refresh_secret_key")

	// Initialize test database
	config.InitDB()
	suite.db = config.GetDB()

	// Auto migrate
	suite.db.AutoMigrate(&models.User{})

	// Setup Fiber app with auth routes
	suite.app = fiber.New()

	// Initialize auth dependencies
	userRepo := authRepositories.NewUserRepository(suite.db)
	jwtService := authServices.NewJWTService()
	authService := authServices.NewAuthService(userRepo, jwtService)
	authHandler := authHandlers.NewAuthHandler(authService)
	jwtMiddleware := middlewares.NewJWTMiddleware(jwtService)

	// Setup auth routes
	authRoutes.SetupAuthRoutes(suite.app, authHandler, jwtMiddleware)
}

func (suite *AuthIntegrationTestSuite) SetupTest() {
	// Clean up database before each test
	suite.db.Exec("DELETE FROM users")
}

func (suite *AuthIntegrationTestSuite) TearDownSuite() {
	// Clean up after all tests
	suite.db.Exec("DROP TABLE IF EXISTS users")
}

func (suite *AuthIntegrationTestSuite) TestSignUpFlow() {
	// Test user registration
	registerReq := models.RegisterRequest{
		Name:     "John Doe",
		Email:    "john@example.com",
		Password: "password123",
	}

	reqBody, _ := json.Marshal(registerReq)
	req := httptest.NewRequest("POST", "/api/v1/auth/signup", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")

	resp, err := suite.app.Test(req)
	suite.NoError(err)
	suite.Equal(http.StatusOK, resp.StatusCode)

	var response map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&response)

	suite.Equal("success", response["message"])
	suite.NotNil(response["data"])

	data := response["data"].(map[string]interface{})
	suite.NotNil(data["user"])
	suite.NotNil(data["access_token"])
	suite.NotNil(data["refresh_token"])

	user := data["user"].(map[string]interface{})
	suite.Equal(registerReq.Name, user["name"])
	suite.Equal(registerReq.Email, user["email"])
}

func (suite *AuthIntegrationTestSuite) TestSignUpDuplicateEmail() {
	// First registration
	registerReq := models.RegisterRequest{
		Name:     "John Doe",
		Email:    "john@example.com",
		Password: "password123",
	}

	reqBody, _ := json.Marshal(registerReq)
	req := httptest.NewRequest("POST", "/api/v1/auth/signup", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")

	resp, _ := suite.app.Test(req)
	suite.Equal(http.StatusOK, resp.StatusCode)

	// Second registration with same email
	req2 := httptest.NewRequest("POST", "/api/v1/auth/signup", bytes.NewBuffer(reqBody))
	req2.Header.Set("Content-Type", "application/json")

	resp2, err := suite.app.Test(req2)
	suite.NoError(err)
	suite.Equal(http.StatusInternalServerError, resp2.StatusCode)

	var response map[string]interface{}
	json.NewDecoder(resp2.Body).Decode(&response)

	suite.Equal("failed", response["message"])
	suite.Contains(response["error"], "email already exists")
}

func (suite *AuthIntegrationTestSuite) TestSignInFlow() {
	// First register a user
	registerReq := models.RegisterRequest{
		Name:     "John Doe",
		Email:    "john@example.com",
		Password: "password123",
	}

	reqBody, _ := json.Marshal(registerReq)
	req := httptest.NewRequest("POST", "/api/v1/auth/signup", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")
	suite.app.Test(req)

	// Now test sign in
	loginReq := models.AuthRequest{
		Email:    "john@example.com",
		Password: "password123",
	}

	reqBody, _ = json.Marshal(loginReq)
	req = httptest.NewRequest("POST", "/api/v1/auth/signin", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")

	resp, err := suite.app.Test(req)
	suite.NoError(err)
	suite.Equal(http.StatusOK, resp.StatusCode)

	var response map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&response)

	suite.Equal("success", response["message"])
	suite.NotNil(response["data"])

	data := response["data"].(map[string]interface{})
	suite.NotNil(data["user"])
	suite.NotNil(data["access_token"])
	suite.NotNil(data["refresh_token"])

	// Store token for other tests
	suite.authToken = data["access_token"].(string)
}

func (suite *AuthIntegrationTestSuite) TestSignInInvalidCredentials() {
	// Register a user first
	registerReq := models.RegisterRequest{
		Name:     "John Doe",
		Email:    "john@example.com",
		Password: "password123",
	}

	reqBody, _ := json.Marshal(registerReq)
	req := httptest.NewRequest("POST", "/api/v1/auth/signup", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")
	suite.app.Test(req)

	// Try to sign in with wrong password
	loginReq := models.AuthRequest{
		Email:    "john@example.com",
		Password: "wrongpassword",
	}

	reqBody, _ = json.Marshal(loginReq)
	req = httptest.NewRequest("POST", "/api/v1/auth/signin", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")

	resp, err := suite.app.Test(req)
	suite.NoError(err)
	suite.Equal(http.StatusInternalServerError, resp.StatusCode)

	var response map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&response)

	suite.Equal("failed", response["message"])
	suite.Contains(response["error"], "invalid credentials")
}

func (suite *AuthIntegrationTestSuite) TestMeEndpoint() {
	// Register and sign in to get token
	registerReq := models.RegisterRequest{
		Name:     "John Doe",
		Email:    "john@example.com",
		Password: "password123",
	}

	reqBody, _ := json.Marshal(registerReq)
	req := httptest.NewRequest("POST", "/api/v1/auth/signup", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")

	resp, _ := suite.app.Test(req)
	var signupResponse map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&signupResponse)

	data := signupResponse["data"].(map[string]interface{})
	token := data["access_token"].(string)

	// Test /me endpoint
	req = httptest.NewRequest("GET", "/api/v1/auth/me", nil)
	req.Header.Set("Authorization", "Bearer "+token)

	resp, err := suite.app.Test(req)
	suite.NoError(err)
	suite.Equal(http.StatusOK, resp.StatusCode)

	var response map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&response)

	suite.Equal("success", response["message"])
	suite.NotNil(response["data"])

	user := response["data"].(map[string]interface{})
	suite.Equal(registerReq.Name, user["name"])
	suite.Equal(registerReq.Email, user["email"])
}

func (suite *AuthIntegrationTestSuite) TestMeEndpointUnauthorized() {
	// Test /me endpoint without token
	req := httptest.NewRequest("GET", "/api/v1/auth/me", nil)

	resp, err := suite.app.Test(req)
	suite.NoError(err)
	suite.Equal(http.StatusUnauthorized, resp.StatusCode)

	var response map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&response)

	suite.Equal("failed", response["message"])
	suite.Equal("Missing or invalid token", response["error"])
}

func (suite *AuthIntegrationTestSuite) TestRefreshTokenEndpoint() {
	// Register and sign in to get tokens
	registerReq := models.RegisterRequest{
		Name:     "John Doe",
		Email:    "john@example.com",
		Password: "password123",
	}

	reqBody, _ := json.Marshal(registerReq)
	req := httptest.NewRequest("POST", "/api/v1/auth/signup", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")

	resp, _ := suite.app.Test(req)
	var signupResponse map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&signupResponse)

	data := signupResponse["data"].(map[string]interface{})
	refreshToken := data["refresh_token"].(string)

	// Test refresh token endpoint
	refreshReq := models.RefreshTokenRequest{
		RefreshToken: refreshToken,
	}

	reqBody, _ = json.Marshal(refreshReq)
	req = httptest.NewRequest("POST", "/api/v1/auth/refresh-token", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")

	resp, err := suite.app.Test(req)
	suite.NoError(err)
	suite.Equal(http.StatusOK, resp.StatusCode)

	var response map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&response)

	suite.Equal("success", response["message"])
	suite.NotNil(response["data"])

	newData := response["data"].(map[string]interface{})
	suite.NotNil(newData["access_token"])
	suite.NotNil(newData["refresh_token"])
}

func (suite *AuthIntegrationTestSuite) TestLogoutEndpoint() {
	// Register and sign in to get token
	registerReq := models.RegisterRequest{
		Name:     "John Doe",
		Email:    "john@example.com",
		Password: "password123",
	}

	reqBody, _ := json.Marshal(registerReq)
	req := httptest.NewRequest("POST", "/api/v1/auth/signup", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")

	resp, _ := suite.app.Test(req)
	var signupResponse map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&signupResponse)

	data := signupResponse["data"].(map[string]interface{})
	token := data["access_token"].(string)

	// Test logout endpoint
	req = httptest.NewRequest("POST", "/api/v1/auth/logout", nil)
	req.Header.Set("Authorization", "Bearer "+token)

	resp, err := suite.app.Test(req)
	suite.NoError(err)
	suite.Equal(http.StatusOK, resp.StatusCode)

	var response map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&response)

	suite.Equal("success", response["message"])
}

func TestAuthIntegrationTestSuite(t *testing.T) {
	suite.Run(t, new(AuthIntegrationTestSuite))
}