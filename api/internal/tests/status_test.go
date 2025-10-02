package tests

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gofiber/fiber/v2"
	"github.com/stretchr/testify/assert"
)

// TestStatusEndpoint_Unit tests the /api/v1/status endpoint unit functionality
func TestStatusEndpoint_Unit(t *testing.T) {
	// Create a new Fiber app
	app := fiber.New()

	// Setup the status route
	v1 := app.Group("/api/v1")
	v1.Get("/status", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"message": "true",
		})
	})

	tests := []struct {
		name           string
		method         string
		url            string
		expectedStatus int
		expectedBody   map[string]interface{}
	}{
		{
			name:           "GET /api/v1/status should return success",
			method:         "GET",
			url:            "/api/v1/status",
			expectedStatus: http.StatusOK,
			expectedBody: map[string]interface{}{
				"message": "true",
			},
		},
		{
			name:           "POST /api/v1/status should return method not allowed",
			method:         "POST",
			url:            "/api/v1/status",
			expectedStatus: http.StatusMethodNotAllowed,
			expectedBody:   nil,
		},
		{
			name:           "PUT /api/v1/status should return method not allowed",
			method:         "PUT",
			url:            "/api/v1/status",
			expectedStatus: http.StatusMethodNotAllowed,
			expectedBody:   nil,
		},
		{
			name:           "DELETE /api/v1/status should return method not allowed",
			method:         "DELETE",
			url:            "/api/v1/status",
			expectedStatus: http.StatusMethodNotAllowed,
			expectedBody:   nil,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Create request
			req := httptest.NewRequest(tt.method, tt.url, nil)
			req.Header.Set("Content-Type", "application/json")

			// Perform request
			resp, err := app.Test(req)
			assert.NoError(t, err)

			// Check status code
			assert.Equal(t, tt.expectedStatus, resp.StatusCode)

			// Check response body for successful requests
			if tt.expectedBody != nil {
				var responseBody map[string]interface{}
				err := json.NewDecoder(resp.Body).Decode(&responseBody)
				assert.NoError(t, err)
				assert.Equal(t, tt.expectedBody, responseBody)
			}
		})
	}
}

// TestStatusEndpoint_ResponseFormat tests the response format
func TestStatusEndpoint_ResponseFormat(t *testing.T) {
	app := fiber.New()

	v1 := app.Group("/api/v1")
	v1.Get("/status", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"message": "true",
		})
	})

	req := httptest.NewRequest("GET", "/api/v1/status", nil)
	resp, err := app.Test(req)
	assert.NoError(t, err)

	// Check content type
	assert.Equal(t, "application/json", resp.Header.Get("Content-Type"))

	// Check response structure
	var responseBody map[string]interface{}
	err = json.NewDecoder(resp.Body).Decode(&responseBody)
	assert.NoError(t, err)

	// Verify required fields exist
	assert.Contains(t, responseBody, "message")
	assert.Equal(t, "true", responseBody["message"])
}

// TestStatusEndpoint_Headers tests various header scenarios
func TestStatusEndpoint_Headers(t *testing.T) {
	app := fiber.New()

	v1 := app.Group("/api/v1")
	v1.Get("/status", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"message": "true",
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
				"User-Agent": "Test-Agent/1.0",
			},
		},
		{
			name: "Request with multiple headers",
			headers: map[string]string{
				"Accept":     "application/json",
				"User-Agent": "Test-Agent/1.0",
				"X-Test":     "test-value",
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req := httptest.NewRequest("GET", "/api/v1/status", nil)
			
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