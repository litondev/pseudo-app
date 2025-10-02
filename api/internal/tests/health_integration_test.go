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

	"pseudo-app/api/config"
)

// HealthIntegrationTestSuite defines the test suite for health endpoint integration tests
type HealthIntegrationTestSuite struct {
	suite.Suite
	app     *fiber.App
	port    string
	baseURL string
}

// SetupSuite runs before all tests in the suite
func (suite *HealthIntegrationTestSuite) SetupSuite() {
	// Find available port
	suite.port = "8082"
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
func (suite *HealthIntegrationTestSuite) TearDownSuite() {
	if suite.app != nil {
		suite.app.Shutdown()
	}
}

// setupRoutes configures the routes for testing
func (suite *HealthIntegrationTestSuite) setupRoutes() {
	v1 := suite.app.Group("/api/v1")

	// Health check endpoint (similar to main.go)
	v1.Get("/health", func(c *fiber.Ctx) error {
		// Test database connection if available
		if config.DB != nil {
			if err := config.TestConnection(); err != nil {
				return c.Status(fiber.StatusServiceUnavailable).JSON(fiber.Map{
					"status":  "unhealthy",
					"message": "Database connection failed",
					"error":   err.Error(),
				})
			}
		}

		return c.JSON(fiber.Map{
			"status":   "healthy",
			"message":  "Service is running",
			"database": "connected",
		})
	})
}

// waitForServer waits for the server to be ready
func (suite *HealthIntegrationTestSuite) waitForServer() {
	maxRetries := 30
	for i := 0; i < maxRetries; i++ {
		resp, err := http.Get(suite.baseURL + "/api/v1/health")
		if err == nil {
			resp.Body.Close()
			return
		}
		time.Sleep(100 * time.Millisecond)
	}
	suite.T().Fatal("Server failed to start within timeout")
}

// TestHealthEndpoint_Integration tests the health endpoint with real HTTP requests
func (suite *HealthIntegrationTestSuite) TestHealthEndpoint_Integration() {
	tests := []struct {
		name           string
		method         string
		url            string
		expectedStatus int
		checkBody      bool
	}{
		{
			name:           "GET /api/v1/health should return health status",
			method:         "GET",
			url:            "/api/v1/health",
			expectedStatus: http.StatusOK,
			checkBody:      true,
		},
		{
			name:           "POST /api/v1/health should return method not allowed",
			method:         "POST",
			url:            "/api/v1/health",
			expectedStatus: http.StatusMethodNotAllowed,
			checkBody:      false,
		},
		{
			name:           "PUT /api/v1/health should return method not allowed",
			method:         "PUT",
			url:            "/api/v1/health",
			expectedStatus: http.StatusMethodNotAllowed,
			checkBody:      false,
		},
		{
			name:           "DELETE /api/v1/health should return method not allowed",
			method:         "DELETE",
			url:            "/api/v1/health",
			expectedStatus: http.StatusMethodNotAllowed,
			checkBody:      false,
		},
	}

	for _, tt := range tests {
		suite.Run(tt.name, func() {
			client := &http.Client{Timeout: 10 * time.Second}
			
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
				
				// Check required fields
				suite.Contains(responseBody, "status")
				suite.Contains(responseBody, "message")
				
				// Status should be either "healthy" or "unhealthy"
				status := responseBody["status"].(string)
				suite.True(status == "healthy" || status == "unhealthy")
				
				if status == "healthy" {
					suite.Contains(responseBody, "database")
					suite.Equal("Service is running", responseBody["message"])
				} else {
					suite.Contains(responseBody, "error")
					suite.Equal("Database connection failed", responseBody["message"])
				}
			}
		})
	}
}

// TestHealthEndpoint_ConcurrentRequests tests concurrent access to health endpoint
func (suite *HealthIntegrationTestSuite) TestHealthEndpoint_ConcurrentRequests() {
	const numRequests = 10
	results := make(chan error, numRequests)

	// Send concurrent requests
	for i := 0; i < numRequests; i++ {
		go func() {
			client := &http.Client{Timeout: 10 * time.Second}
			resp, err := client.Get(suite.baseURL + "/api/v1/health")
			if err != nil {
				results <- err
				return
			}
			defer resp.Body.Close()

			// Health endpoint can return either 200 (healthy) or 503 (unhealthy)
			if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusServiceUnavailable {
				results <- fmt.Errorf("expected status 200 or 503, got %d", resp.StatusCode)
				return
			}

			var responseBody map[string]interface{}
			if err := json.NewDecoder(resp.Body).Decode(&responseBody); err != nil {
				results <- err
				return
			}

			// Verify response structure
			if _, exists := responseBody["status"]; !exists {
				results <- fmt.Errorf("response missing 'status' field")
				return
			}

			if _, exists := responseBody["message"]; !exists {
				results <- fmt.Errorf("response missing 'message' field")
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

// TestHealthEndpoint_ResponseHeaders tests response headers
func (suite *HealthIntegrationTestSuite) TestHealthEndpoint_ResponseHeaders() {
	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Get(suite.baseURL + "/api/v1/health")
	suite.NoError(err)
	defer resp.Body.Close()

	// Health endpoint can return either 200 or 503
	suite.True(resp.StatusCode == http.StatusOK || resp.StatusCode == http.StatusServiceUnavailable)
	suite.Equal("application/json", resp.Header.Get("Content-Type"))
}

// TestHealthEndpoint_WithDifferentUserAgents tests with different user agents
func (suite *HealthIntegrationTestSuite) TestHealthEndpoint_WithDifferentUserAgents() {
	userAgents := []string{
		"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
		"curl/7.68.0",
		"PostmanRuntime/7.28.4",
		"Go-http-client/1.1",
		"HealthCheck-Bot/1.0",
		"Kubernetes/1.21",
	}

	for _, ua := range userAgents {
		suite.Run(fmt.Sprintf("UserAgent_%s", ua), func() {
			client := &http.Client{Timeout: 10 * time.Second}
			req, err := http.NewRequest("GET", suite.baseURL+"/api/v1/health", nil)
			suite.NoError(err)
			
			req.Header.Set("User-Agent", ua)
			
			resp, err := client.Do(req)
			suite.NoError(err)
			defer resp.Body.Close()

			// Health endpoint can return either 200 or 503
			suite.True(resp.StatusCode == http.StatusOK || resp.StatusCode == http.StatusServiceUnavailable)
		})
	}
}

// TestHealthEndpoint_ResponseTime tests response time
func (suite *HealthIntegrationTestSuite) TestHealthEndpoint_ResponseTime() {
	client := &http.Client{Timeout: 10 * time.Second}
	
	start := time.Now()
	resp, err := client.Get(suite.baseURL + "/api/v1/health")
	duration := time.Since(start)
	
	suite.NoError(err)
	defer resp.Body.Close()

	// Health check should respond within reasonable time (5 seconds)
	suite.True(duration < 5*time.Second, "Health check took too long: %v", duration)
}

// TestHealthEndpoint_LoadTest performs a basic load test
func (suite *HealthIntegrationTestSuite) TestHealthEndpoint_LoadTest() {
	const numRequests = 50
	const concurrency = 10
	
	semaphore := make(chan struct{}, concurrency)
	results := make(chan error, numRequests)

	for i := 0; i < numRequests; i++ {
		go func() {
			semaphore <- struct{}{} // Acquire
			defer func() { <-semaphore }() // Release

			client := &http.Client{Timeout: 10 * time.Second}
			resp, err := client.Get(suite.baseURL + "/api/v1/health")
			if err != nil {
				results <- err
				return
			}
			defer resp.Body.Close()

			// Health endpoint can return either 200 or 503
			if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusServiceUnavailable {
				results <- fmt.Errorf("unexpected status code: %d", resp.StatusCode)
				return
			}

			results <- nil
		}()
	}

	// Check all results
	successCount := 0
	for i := 0; i < numRequests; i++ {
		err := <-results
		if err == nil {
			successCount++
		} else {
			suite.T().Logf("Request failed: %v", err)
		}
	}

	// At least 80% of requests should succeed
	successRate := float64(successCount) / float64(numRequests)
	suite.True(successRate >= 0.8, "Success rate too low: %.2f", successRate)
}

// TestHealthIntegrationSuite runs the integration test suite
func TestHealthIntegrationSuite(t *testing.T) {
	// Skip integration tests if running in CI without proper setup
	if os.Getenv("SKIP_INTEGRATION_TESTS") == "true" {
		t.Skip("Skipping integration tests")
	}

	suite.Run(t, new(HealthIntegrationTestSuite))
}