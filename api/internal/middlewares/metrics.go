package middlewares

import (
	"github.com/gofiber/fiber/v2"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
)

var (
	// Database connection metrics
	dbConnectionsActive = promauto.NewGauge(
		prometheus.GaugeOpts{
			Name: "db_connections_active",
			Help: "Number of active database connections",
		},
	)

	dbConnectionsIdle = promauto.NewGauge(
		prometheus.GaugeOpts{
			Name: "db_connections_idle",
			Help: "Number of idle database connections",
		},
	)

	// Authentication metrics
	authAttempts = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "auth_attempts_total",
			Help: "Total number of authentication attempts",
		},
		[]string{"type", "status"}, // type: signin/signup, status: success/failure
	)

	// JWT token metrics
	jwtTokensIssued = promauto.NewCounter(
		prometheus.CounterOpts{
			Name: "jwt_tokens_issued_total",
			Help: "Total number of JWT tokens issued",
		},
	)

	jwtTokensValidated = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "jwt_tokens_validated_total",
			Help: "Total number of JWT token validations",
		},
		[]string{"status"}, // status: valid/invalid/expired
	)

	// API endpoint specific metrics
	apiEndpointCalls = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "api_endpoint_calls_total",
			Help: "Total number of calls to specific API endpoints",
		},
		[]string{"endpoint", "method", "status"},
	)
)

// UpdateDBConnectionMetrics updates database connection metrics
func UpdateDBConnectionMetrics(active, idle int) {
	dbConnectionsActive.Set(float64(active))
	dbConnectionsIdle.Set(float64(idle))
}

// RecordAuthAttempt records an authentication attempt
func RecordAuthAttempt(authType, status string) {
	authAttempts.WithLabelValues(authType, status).Inc()
}

// RecordJWTTokenIssued records a JWT token issuance
func RecordJWTTokenIssued() {
	jwtTokensIssued.Inc()
}

// RecordJWTTokenValidation records a JWT token validation
func RecordJWTTokenValidation(status string) {
	jwtTokensValidated.WithLabelValues(status).Inc()
}

// RecordAPIEndpointCall records an API endpoint call
func RecordAPIEndpointCall(endpoint, method, status string) {
	apiEndpointCalls.WithLabelValues(endpoint, method, status).Inc()
}

// APIMetricsMiddleware creates middleware for API-specific metrics
func APIMetricsMiddleware() fiber.Handler {
	return func(c *fiber.Ctx) error {
		err := c.Next()
		
		// Record API endpoint call
		endpoint := c.Route().Path
		if endpoint == "" {
			endpoint = c.Path()
		}
		method := c.Method()
		status := c.Response().StatusCode()
		
		RecordAPIEndpointCall(endpoint, method, string(rune(status)))
		
		return err
	}
}