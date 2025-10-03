package auth

import (
	"api/internal/models"
	"errors"
	"os"
	"strconv"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

type JWTService interface {
	GenerateTokens(user *models.User) (accessToken, refreshToken string, expiresIn int64, err error)
	ValidateToken(tokenString string) (*jwt.Token, error)
	ExtractUserID(token *jwt.Token) (uint, error)
	RefreshAccessToken(refreshToken string) (accessToken string, expiresIn int64, err error)
}

type jwtService struct {
	secretKey        string
	refreshSecretKey string
	accessTokenTTL   time.Duration
	refreshTokenTTL  time.Duration
}

type Claims struct {
	UserID uint   `json:"user_id"`
	Email  string `json:"email"`
	Type   string `json:"type"` // "access" or "refresh"
	jwt.RegisteredClaims
}

func NewJWTService() JWTService {
	secretKey := os.Getenv("JWT_SECRET")
	if secretKey == "" {
		secretKey = "your-secret-key-change-in-production"
	}

	refreshSecretKey := os.Getenv("JWT_REFRESH_SECRET")
	if refreshSecretKey == "" {
		refreshSecretKey = "your-refresh-secret-key-change-in-production"
	}

	accessTTLStr := os.Getenv("JWT_ACCESS_TTL")
	accessTTL := 15 * time.Minute // default 15 minutes
	if accessTTLStr != "" {
		if minutes, err := strconv.Atoi(accessTTLStr); err == nil {
			accessTTL = time.Duration(minutes) * time.Minute
		}
	}

	refreshTTLStr := os.Getenv("JWT_REFRESH_TTL")
	refreshTTL := 7 * 24 * time.Hour // default 7 days
	if refreshTTLStr != "" {
		if hours, err := strconv.Atoi(refreshTTLStr); err == nil {
			refreshTTL = time.Duration(hours) * time.Hour
		}
	}

	return &jwtService{
		secretKey:        secretKey,
		refreshSecretKey: refreshSecretKey,
		accessTokenTTL:   accessTTL,
		refreshTokenTTL:  refreshTTL,
	}
}

func (s *jwtService) GenerateTokens(user *models.User) (accessToken, refreshToken string, expiresIn int64, err error) {
	now := time.Now()
	accessExpiry := now.Add(s.accessTokenTTL)
	refreshExpiry := now.Add(s.refreshTokenTTL)

	// Generate access token
	accessClaims := Claims{
		UserID: user.ID,
		Email:  user.Email,
		Type:   "access",
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(accessExpiry),
			IssuedAt:  jwt.NewNumericDate(now),
			NotBefore: jwt.NewNumericDate(now),
			Issuer:    "pseudo-app",
			Subject:   strconv.Itoa(int(user.ID)),
		},
	}

	accessTokenObj := jwt.NewWithClaims(jwt.SigningMethodHS256, accessClaims)
	accessToken, err = accessTokenObj.SignedString([]byte(s.secretKey))
	if err != nil {
		return "", "", 0, err
	}

	// Generate refresh token
	refreshClaims := Claims{
		UserID: user.ID,
		Email:  user.Email,
		Type:   "refresh",
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(refreshExpiry),
			IssuedAt:  jwt.NewNumericDate(now),
			NotBefore: jwt.NewNumericDate(now),
			Issuer:    "pseudo-app",
			Subject:   strconv.Itoa(int(user.ID)),
		},
	}

	refreshTokenObj := jwt.NewWithClaims(jwt.SigningMethodHS256, refreshClaims)
	refreshToken, err = refreshTokenObj.SignedString([]byte(s.refreshSecretKey))
	if err != nil {
		return "", "", 0, err
	}

	return accessToken, refreshToken, int64(s.accessTokenTTL.Seconds()), nil
}

func (s *jwtService) ValidateToken(tokenString string) (*jwt.Token, error) {
	return jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("unexpected signing method")
		}
		return []byte(s.secretKey), nil
	})
}

func (s *jwtService) ExtractUserID(token *jwt.Token) (uint, error) {
	claims, ok := token.Claims.(*Claims)
	if !ok || !token.Valid {
		return 0, errors.New("invalid token claims")
	}
	return claims.UserID, nil
}

func (s *jwtService) RefreshAccessToken(refreshToken string) (accessToken string, expiresIn int64, err error) {
	token, err := jwt.ParseWithClaims(refreshToken, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("unexpected signing method")
		}
		return []byte(s.refreshSecretKey), nil
	})

	if err != nil {
		return "", 0, err
	}

	claims, ok := token.Claims.(*Claims)
	if !ok || !token.Valid || claims.Type != "refresh" {
		return "", 0, errors.New("invalid refresh token")
	}

	// Generate new access token
	now := time.Now()
	accessExpiry := now.Add(s.accessTokenTTL)

	accessClaims := Claims{
		UserID: claims.UserID,
		Email:  claims.Email,
		Type:   "access",
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(accessExpiry),
			IssuedAt:  jwt.NewNumericDate(now),
			NotBefore: jwt.NewNumericDate(now),
			Issuer:    "pseudo-app",
			Subject:   strconv.Itoa(int(claims.UserID)),
		},
	}

	accessTokenObj := jwt.NewWithClaims(jwt.SigningMethodHS256, accessClaims)
	accessToken, err = accessTokenObj.SignedString([]byte(s.secretKey))
	if err != nil {
		return "", 0, err
	}

	return accessToken, int64(s.accessTokenTTL.Seconds()), nil
}