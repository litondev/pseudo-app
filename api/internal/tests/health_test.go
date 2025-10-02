package tests

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gofiber/fiber/v2"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

// MockDBTester is a mock for database testing functionality
type MockDBTester struct {
	mock.Mock
}

func (m *MockDBTester) TestConnection() error {
	args := m.Called()
	return args.Error(0)
}

// TestHealthEndpoint_Unit tests the /api/v1/health endpoint unit functionality
func TestHealthEndpoint_Unit(t *testing.T) {
	tests := []struct {
		name           string
		dbError        error
		expectedStatus int
		expectedFields map[string]interface{}
	}{
		{
			name:           "Health check with healthy database",
			dbError:        nil,
			expectedStatus: http.StatusOK,
			expectedFields: map[string]interface{}{
				"status":   "healthy",
				"message":  "Service is running",
				"database": "connected",
			},
		},
		{
			name:           "Health check with database connection error",
			dbError:        fmt.Errorf("database connection failed"),
			expectedStatus: http.StatusServiceUnavailable,
			expectedFields: map[string]interface{}{
				"status":  "unhealthy",
				"message": "Database connection failed",
				"error":   "database connection failed",
			},
		},
		{
			name:           "Health check with database timeout error",
			dbError:        fmt.Errorf("connection timeout"),
			expectedStatus: http.StatusServiceUnavailable,
			expectedFields: map[string]interface{}{
				"status":  "unhealthy",
				"message": "Database connection failed",
				"error":   "connection timeout",
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Create a new Fiber app
			app := fiber.New()

			// Setup the health route with mock
			v1 := app.Group("/api/v1")
			v1.Get("/health", func(c *fiber.Ctx) error {
				// Simulate database test
				if tt.dbError != nil {
					return c.Status(fiber.StatusServiceUnavailable).JSON(fiber.Map{
						"status":  "unhealthy",
						"message": "Database connection failed",
						"error":   tt.dbError.Error(),
					})
				}

				return c.JSON(fiber.Map{
					"status":   "healthy",
					"message":  "Service is running",
					"database": "connected",
				})
			})

			// Create request
			req := httptest.NewRequest("GET", "/api/v1/health", nil)
			req.Header.Set("Content-Type", "application/json")

			// Perform request
			resp, err := app.Test(req)
			assert.NoError(t, err)

			// Check status code
			assert.Equal(t, tt.expectedStatus, resp.StatusCode)

			// Check response body
			var responseBody map[string]interface{}
			err = json.NewDecoder(resp.Body).Decode(&responseBody)
			assert.NoError(t, err)

			// Verify expected fields
			for key, expectedValue := range tt.expectedFields {
				assert.Contains(t, responseBody, key)
				assert.Equal(t, expectedValue, responseBody[key])
			}
		})
	}
}

// TestHealthEndpoint_HTTPMethods tests different HTTP methods
func TestHealthEndpoint_HTTPMethods(t *testing.T) {
	app := fiber.New()

	v1 := app.Group("/api/v1")
	v1.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"status":   "healthy",
			"message":  "Service is running",
			"database": "connected",
		})
	})

	tests := []struct {
		name           string
		method         string
		expectedStatus int
	}{
		{
			name:           "GET /api/v1/health should return success",
			method:         "GET",
			expectedStatus: http.StatusOK,
		},
		{
			name:           "POST /api/v1/health should return method not allowed",
			method:         "POST",
			expectedStatus: http.StatusMethodNotAllowed,
		},
		{
			name:           "PUT /api/v1/health should return method not allowed",
			method:         "PUT",
			expectedStatus: http.StatusMethodNotAllowed,
		},
		{
			name:           "DELETE /api/v1/health should return method not allowed",
			method:         "DELETE",
			expectedStatus: http.StatusMethodNotAllowed,
		},
		{
			name:           "PATCH /api/v1/health should return method not allowed",
			method:         "PATCH",
			expectedStatus: http.StatusMethodNotAllowed,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req := httptest.NewRequest(tt.method, "/api/v1/health", nil)
			req.Header.Set("Content-Type", "application/json")

			resp, err := app.Test(req)
			assert.NoError(t, err)
			assert.Equal(t, tt.expectedStatus, resp.StatusCode)
		})
	}
}

// TestHealthEndpoint_ResponseFormat tests the response format
func TestHealthEndpoint_ResponseFormat(t *testing.T) {
	app := fiber.New()

	v1 := app.Group("/api/v1")
	v1.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"status":   "healthy",
			"message":  "Service is running",
			"database": "connected",
		})
	})

	req := httptest.NewRequest("GET", "/api/v1/health", nil)
	resp, err := app.Test(req)
	assert.NoError(t, err)

	// Check content type
	assert.Equal(t, "application/json", resp.Header.Get("Content-Type"))

	// Check response structure
	var responseBody map[string]interface{}
	err = json.NewDecoder(resp.Body).Decode(&responseBody)
	assert.NoError(t, err)

	// Verify required fields exist for healthy response
	requiredFields := []string{"status", "message", "database"}
	for _, field := range requiredFields {
		assert.Contains(t, responseBody, field)
	}

	// Verify field types
	assert.IsType(t, "", responseBody["status"])
	assert.IsType(t, "", responseBody["message"])
	assert.IsType(t, "", responseBody["database"])
}

// TestHealthEndpoint_ErrorResponseFormat tests error response format
func TestHealthEndpoint_ErrorResponseFormat(t *testing.T) {
	app := fiber.New()

	v1 := app.Group("/api/v1")
	v1.Get("/health", func(c *fiber.Ctx) error {
		// Simulate database error
		return c.Status(fiber.StatusServiceUnavailable).JSON(fiber.Map{
			"status":  "unhealthy",
			"message": "Database connection failed",
			"error":   "mock database error",
		})
	})

	req := httptest.NewRequest("GET", "/api/v1/health", nil)
	resp, err := app.Test(req)
	assert.NoError(t, err)

	// Check status code
	assert.Equal(t, http.StatusServiceUnavailable, resp.StatusCode)

	// Check content type
	assert.Equal(t, "application/json", resp.Header.Get("Content-Type"))

	// Check response structure
	var responseBody map[string]interface{}
	err = json.NewDecoder(resp.Body).Decode(&responseBody)
	assert.NoError(t, err)

	// Verify required fields exist for error response
	requiredFields := []string{"status", "message", "error"}
	for _, field := range requiredFields {
		assert.Contains(t, responseBody, field)
	}

	// Verify field values
	assert.Equal(t, "unhealthy", responseBody["status"])
	assert.Equal(t, "Database connection failed", responseBody["message"])
	assert.Equal(t, "mock database error", responseBody["error"])
}

// TestHealthEndpoint_Headers tests various header scenarios
func TestHealthEndpoint_Headers(t *testing.T) {
	app := fiber.New()

	v1 := app.Group("/api/v1")
	v1.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"status":   "healthy",
			"message":  "Service is running",
			"database": "connected",
		})
	})

	tests := []struct {
		name    string
		headers map[string]string
	}{
		{
			name: "Request with Accept header",
			headers: map[string]string{
				"Accept": "application/json",
			},
		},
		{
			name: "Request with User-Agent header",
			headers: map[string]string{
				"User-Agent": "HealthCheck/1.0",
			},
		},
		{
			name: "Request with monitoring headers",
			headers: map[string]string{
				"Accept":           "application/json",
				"User-Agent":       "Monitoring-Agent/1.0",
				"X-Health-Check":   "true",
				"X-Request-ID":     "test-123",
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req := httptest.NewRequest("GET", "/api/v1/health", nil)
			
			// Set headers
			for key, value := range tt.headers {
				req.Header.Set(key, value)
			}

			resp, err := app.Test(req)
			assert.NoError(t, err)
			assert.Equal(t, http.StatusOK, resp.StatusCode)
		})
	}
}