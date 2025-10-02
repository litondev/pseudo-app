package tests

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"testing"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/recover"
	"github.com/stretchr/testify/suite"
)

// StatusIntegrationTestSuite defines the test suite for status endpoint integration tests
type StatusIntegrationTestSuite struct {
	suite.Suite
	app    *fiber.App
	server *http.Server
	port   string
	baseURL string
}

// SetupSuite runs before all tests in the suite
func (suite *StatusIntegrationTestSuite) SetupSuite() {
	// Find available port
	suite.port = "8081"
	suite.baseURL = fmt.Sprintf("http://localhost:%s", suite.port)

	// Create Fiber app with middleware (similar to main.go)
	suite.app = fiber.New(fiber.Config{
		ErrorHandler: func(c *fiber.Ctx, err error) error {
			code := fiber.StatusInternalServerError
			if e, ok := err.(*fiber.Error); ok {
				code = e.Code
			}
			return c.Status(code).JSON(fiber.Map{
				"error": err.Error(),
			})
		},
	})

	// Add middleware
	suite.app.Use(recover.New())
	suite.app.Use(logger.New())
	suite.app.Use(cors.New())

	// Setup routes
	suite.setupRoutes()

	// Start server in goroutine
	go func() {
		if err := suite.app.Listen(":" + suite.port); err != nil {
			suite.T().Logf("Server failed to start: %v", err)
		}
	}()

	// Wait for server to start
	suite.waitForServer()
}

// TearDownSuite runs after all tests in the suite
func (suite *StatusIntegrationTestSuite) TearDownSuite() {
	if suite.app != nil {
		suite.app.Shutdown()
	}
}

// setupRoutes configures the routes for testing
func (suite *StatusIntegrationTestSuite) setupRoutes() {
	v1 := suite.app.Group("/api/v1")

	v1.Get("/status", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"message": "true",
		})
	})
}

// waitForServer waits for the server to be ready
func (suite *StatusIntegrationTestSuite) waitForServer() {
	maxRetries := 30
	for i := 0; i < maxRetries; i++ {
		resp, err := http.Get(suite.baseURL + "/api/v1/status")
		if err == nil {
			resp.Body.Close()
			return
		}
		time.Sleep(100 * time.Millisecond)
	}
	suite.T().Fatal("Server failed to start within timeout")
}

// TestStatusEndpoint_Integration tests the status endpoint with real HTTP requests
func (suite *StatusIntegrationTestSuite) TestStatusEndpoint_Integration() {
	tests := []struct {
		name           string
		method         string
		url            string
		expectedStatus int
		checkBody      bool
	}{
		{
			name:           "GET /api/v1/status should return success",
			method:         "GET",
			url:            "/api/v1/status",
			expectedStatus: http.StatusOK,
			checkBody:      true,
		},
		{
			name:           "POST /api/v1/status should return method not allowed",
			method:         "POST",
			url:            "/api/v1/status",
			expectedStatus: http.StatusMethodNotAllowed,
			checkBody:      false,
		},
		{
			name:           "PUT /api/v1/status should return method not allowed",
			method:         "PUT",
			url:            "/api/v1/status",
			expectedStatus: http.StatusMethodNotAllowed,
			checkBody:      false,
		},
		{
			name:           "DELETE /api/v1/status should return method not allowed",
			method:         "DELETE",
			url:            "/api/v1/status",
			expectedStatus: http.StatusMethodNotAllowed,
			checkBody:      false,
		},
	}

	for _, tt := range tests {
		suite.Run(tt.name, func() {
			client := &http.Client{Timeout: 5 * time.Second}
			
			req, err := http.NewRequest(tt.method, suite.baseURL+tt.url, nil)
			suite.NoError(err)
			
			req.Header.Set("Content-Type", "application/json")
			
			resp, err := client.Do(req)
			suite.NoError(err)
			defer resp.Body.Close()

			suite.Equal(tt.expectedStatus, resp.StatusCode)

			if tt.checkBody {
				var responseBody map[string]interface{}
				err := json.NewDecoder(resp.Body).Decode(&responseBody)
				suite.NoError(err)
				
				suite.Contains(responseBody, "message")
				suite.Equal("true", responseBody["message"])
			}
		})
	}
}

// TestStatusEndpoint_ConcurrentRequests tests concurrent access to status endpoint
func (suite *StatusIntegrationTestSuite) TestStatusEndpoint_ConcurrentRequests() {
	const numRequests = 10
	results := make(chan error, numRequests)

	// Send concurrent requests
	for i := 0; i < numRequests; i++ {
		go func() {
			client := &http.Client{Timeout: 5 * time.Second}
			resp, err := client.Get(suite.baseURL + "/api/v1/status")
			if err != nil {
				results <- err
				return
			}
			defer resp.Body.Close()

			if resp.StatusCode != http.StatusOK {
				results <- fmt.Errorf("expected status 200, got %d", resp.StatusCode)
				return
			}

			var responseBody map[string]interface{}
			if err := json.NewDecoder(resp.Body).Decode(&responseBody); err != nil {
				results <- err
				return
			}

			if responseBody["message"] != "true" {
				results <- fmt.Errorf("expected message 'true', got %v", responseBody["message"])
				return
			}

			results <- nil
		}()
	}

	// Check all results
	for i := 0; i < numRequests; i++ {
		err := <-results
		suite.NoError(err)
	}
}

// TestStatusEndpoint_ResponseHeaders tests response headers
func (suite *StatusIntegrationTestSuite) TestStatusEndpoint_ResponseHeaders() {
	client := &http.Client{Timeout: 5 * time.Second}
	resp, err := client.Get(suite.baseURL + "/api/v1/status")
	suite.NoError(err)
	defer resp.Body.Close()

	suite.Equal(http.StatusOK, resp.StatusCode)
	suite.Equal("application/json", resp.Header.Get("Content-Type"))
}

// TestStatusEndpoint_WithDifferentUserAgents tests with different user agents
func (suite *StatusIntegrationTestSuite) TestStatusEndpoint_WithDifferentUserAgents() {
	userAgents := []string{
		"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
		"curl/7.68.0",
		"PostmanRuntime/7.28.4",
		"Go-http-client/1.1",
	}

	for _, ua := range userAgents {
		suite.Run(fmt.Sprintf("UserAgent_%s", ua), func() {
			client := &http.Client{Timeout: 5 * time.Second}
			req, err := http.NewRequest("GET", suite.baseURL+"/api/v1/status", nil)
			suite.NoError(err)
			
			req.Header.Set("User-Agent", ua)
			
			resp, err := client.Do(req)
			suite.NoError(err)
			defer resp.Body.Close()

			suite.Equal(http.StatusOK, resp.StatusCode)
		})
	}
}

// TestStatusIntegrationSuite runs the integration test suite
func TestStatusIntegrationSuite(t *testing.T) {
	// Skip integration tests if running in CI without proper setup
	if os.Getenv("SKIP_INTEGRATION_TESTS") == "true" {
		t.Skip("Skipping integration tests")
	}

	suite.Run(t, new(StatusIntegrationTestSuite))
}