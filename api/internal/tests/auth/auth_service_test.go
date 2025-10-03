package auth_test

import (
	"api/internal/models"
	"api/internal/services/auth"
	"errors"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"golang.org/x/crypto/bcrypt"
)

// MockUserRepository is a mock implementation of UserRepository
type MockUserRepository struct {
	mock.Mock
}

func (m *MockUserRepository) Create(user *models.User) error {
	args := m.Called(user)
	return args.Error(0)
}

func (m *MockUserRepository) GetByEmail(email string) (*models.User, error) {
	args := m.Called(email)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*models.User), args.Error(1)
}

func (m *MockUserRepository) GetByID(id uint) (*models.User, error) {
	args := m.Called(id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*models.User), args.Error(1)
}

func (m *MockUserRepository) Update(user *models.User) error {
	args := m.Called(user)
	return args.Error(0)
}

func (m *MockUserRepository) Delete(id uint) error {
	args := m.Called(id)
	return args.Error(0)
}

func (m *MockUserRepository) EmailExists(email string) (bool, error) {
	args := m.Called(email)
	return args.Bool(0), args.Error(1)
}

// MockJWTService is a mock implementation of JWTService
type MockJWTService struct {
	mock.Mock
}

func (m *MockJWTService) GenerateTokens(userID uint) (string, string, error) {
	args := m.Called(userID)
	return args.String(0), args.String(1), args.Error(2)
}

func (m *MockJWTService) ValidateToken(tokenString string) (*auth.Claims, error) {
	args := m.Called(tokenString)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*auth.Claims), args.Error(1)
}

func (m *MockJWTService) ExtractUserID(tokenString string) (uint, error) {
	args := m.Called(tokenString)
	return args.Get(0).(uint), args.Error(1)
}

func (m *MockJWTService) RefreshAccessToken(refreshToken string) (string, string, error) {
	args := m.Called(refreshToken)
	return args.String(0), args.String(1), args.Error(2)
}

func TestAuthService_Register_Success(t *testing.T) {
	// Arrange
	mockRepo := new(MockUserRepository)
	mockJWT := new(MockJWTService)
	authService := auth.NewAuthService(mockRepo, mockJWT)

	registerReq := &models.RegisterRequest{
		Name:     "John Doe",
		Email:    "john@example.com",
		Password: "password123",
	}

	mockRepo.On("EmailExists", registerReq.Email).Return(false, nil)
	mockRepo.On("Create", mock.AnythingOfType("*models.User")).Return(nil)
	mockJWT.On("GenerateTokens", mock.AnythingOfType("uint")).Return("access_token", "refresh_token", nil)

	// Act
	response, err := authService.Register(registerReq)

	// Assert
	assert.NoError(t, err)
	assert.NotNil(t, response)
	assert.Equal(t, registerReq.Name, response.User.Name)
	assert.Equal(t, registerReq.Email, response.User.Email)
	assert.Equal(t, "access_token", response.AccessToken)
	assert.Equal(t, "refresh_token", response.RefreshToken)

	mockRepo.AssertExpectations(t)
	mockJWT.AssertExpectations(t)
}

func TestAuthService_Register_EmailExists(t *testing.T) {
	// Arrange
	mockRepo := new(MockUserRepository)
	mockJWT := new(MockJWTService)
	authService := auth.NewAuthService(mockRepo, mockJWT)

	registerReq := &models.RegisterRequest{
		Name:     "John Doe",
		Email:    "john@example.com",
		Password: "password123",
	}

	mockRepo.On("EmailExists", registerReq.Email).Return(true, nil)

	// Act
	response, err := authService.Register(registerReq)

	// Assert
	assert.Error(t, err)
	assert.Nil(t, response)
	assert.Contains(t, err.Error(), "email already exists")

	mockRepo.AssertExpectations(t)
}

func TestAuthService_Login_Success(t *testing.T) {
	// Arrange
	mockRepo := new(MockUserRepository)
	mockJWT := new(MockJWTService)
	authService := auth.NewAuthService(mockRepo, mockJWT)

	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)
	user := &models.User{
		ID:       1,
		Name:     "John Doe",
		Email:    "john@example.com",
		Password: string(hashedPassword),
	}

	loginReq := &models.AuthRequest{
		Email:    "john@example.com",
		Password: "password123",
	}

	mockRepo.On("GetByEmail", loginReq.Email).Return(user, nil)
	mockJWT.On("GenerateTokens", user.ID).Return("access_token", "refresh_token", nil)

	// Act
	response, err := authService.Login(loginReq)

	// Assert
	assert.NoError(t, err)
	assert.NotNil(t, response)
	assert.Equal(t, user.Name, response.User.Name)
	assert.Equal(t, user.Email, response.User.Email)
	assert.Equal(t, "access_token", response.AccessToken)
	assert.Equal(t, "refresh_token", response.RefreshToken)

	mockRepo.AssertExpectations(t)
	mockJWT.AssertExpectations(t)
}

func TestAuthService_Login_InvalidCredentials(t *testing.T) {
	// Arrange
	mockRepo := new(MockUserRepository)
	mockJWT := new(MockJWTService)
	authService := auth.NewAuthService(mockRepo, mockJWT)

	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)
	user := &models.User{
		ID:       1,
		Name:     "John Doe",
		Email:    "john@example.com",
		Password: string(hashedPassword),
	}

	loginReq := &models.AuthRequest{
		Email:    "john@example.com",
		Password: "wrongpassword",
	}

	mockRepo.On("GetByEmail", loginReq.Email).Return(user, nil)

	// Act
	response, err := authService.Login(loginReq)

	// Assert
	assert.Error(t, err)
	assert.Nil(t, response)
	assert.Contains(t, err.Error(), "invalid credentials")

	mockRepo.AssertExpectations(t)
}

func TestAuthService_Login_UserNotFound(t *testing.T) {
	// Arrange
	mockRepo := new(MockUserRepository)
	mockJWT := new(MockJWTService)
	authService := auth.NewAuthService(mockRepo, mockJWT)

	loginReq := &models.AuthRequest{
		Email:    "nonexistent@example.com",
		Password: "password123",
	}

	mockRepo.On("GetByEmail", loginReq.Email).Return(nil, errors.New("user not found"))

	// Act
	response, err := authService.Login(loginReq)

	// Assert
	assert.Error(t, err)
	assert.Nil(t, response)
	assert.Contains(t, err.Error(), "invalid credentials")

	mockRepo.AssertExpectations(t)
}

func TestAuthService_GetUserByID_Success(t *testing.T) {
	// Arrange
	mockRepo := new(MockUserRepository)
	mockJWT := new(MockJWTService)
	authService := auth.NewAuthService(mockRepo, mockJWT)

	user := &models.User{
		ID:    1,
		Name:  "John Doe",
		Email: "john@example.com",
	}

	mockRepo.On("GetByID", uint(1)).Return(user, nil)

	// Act
	result, err := authService.GetUserByID(1)

	// Assert
	assert.NoError(t, err)
	assert.NotNil(t, result)
	assert.Equal(t, user.ID, result.ID)
	assert.Equal(t, user.Name, result.Name)
	assert.Equal(t, user.Email, result.Email)

	mockRepo.AssertExpectations(t)
}

func TestAuthService_GetUserByID_NotFound(t *testing.T) {
	// Arrange
	mockRepo := new(MockUserRepository)
	mockJWT := new(MockJWTService)
	authService := auth.NewAuthService(mockRepo, mockJWT)

	mockRepo.On("GetByID", uint(999)).Return(nil, errors.New("user not found"))

	// Act
	result, err := authService.GetUserByID(999)

	// Assert
	assert.Error(t, err)
	assert.Nil(t, result)

	mockRepo.AssertExpectations(t)
}

func TestAuthService_RefreshToken_Success(t *testing.T) {
	// Arrange
	mockRepo := new(MockUserRepository)
	mockJWT := new(MockJWTService)
	authService := auth.NewAuthService(mockRepo, mockJWT)

	refreshReq := &models.RefreshTokenRequest{
		RefreshToken: "valid_refresh_token",
	}

	mockJWT.On("RefreshAccessToken", refreshReq.RefreshToken).Return("new_access_token", "new_refresh_token", nil)

	// Act
	response, err := authService.RefreshToken(refreshReq)

	// Assert
	assert.NoError(t, err)
	assert.NotNil(t, response)
	assert.Equal(t, "new_access_token", response.AccessToken)
	assert.Equal(t, "new_refresh_token", response.RefreshToken)

	mockJWT.AssertExpectations(t)
}

func TestAuthService_RefreshToken_InvalidToken(t *testing.T) {
	// Arrange
	mockRepo := new(MockUserRepository)
	mockJWT := new(MockJWTService)
	authService := auth.NewAuthService(mockRepo, mockJWT)

	refreshReq := &models.RefreshTokenRequest{
		RefreshToken: "invalid_refresh_token",
	}

	mockJWT.On("RefreshAccessToken", refreshReq.RefreshToken).Return("", "", errors.New("invalid token"))

	// Act
	response, err := authService.RefreshToken(refreshReq)

	// Assert
	assert.Error(t, err)
	assert.Nil(t, response)

	mockJWT.AssertExpectations(t)
}

func TestAuthService_Logout_Success(t *testing.T) {
	// Arrange
	mockRepo := new(MockUserRepository)
	mockJWT := new(MockJWTService)
	authService := auth.NewAuthService(mockRepo, mockJWT)

	// Act
	err := authService.Logout(1)

	// Assert
	assert.NoError(t, err)
}