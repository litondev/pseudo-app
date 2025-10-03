# CI/CD and Monitoring Setup Documentation

## Overview
This document describes the complete CI/CD and Prometheus monitoring setup for the Pseudo App project.

## Components Implemented

### 1. CI/CD Pipelines

#### GitHub Actions (`.github/workflows/ci-cd.yml`)
- **API Testing**: Go tests, linting with PostgreSQL service
- **Client Testing**: Flutter tests, analyze, and web build
- **Docker Build**: Automated building and pushing to `ghcr.io`
- **Deployment**: Optional staging and production deployment steps

#### GitLab CI/CD (`.gitlab-ci.yml`)
- **Testing Stage**: Go and Flutter tests with PostgreSQL
- **Build Stage**: Docker image building for both API and client
- **Deploy Stage**: Optional deployment to staging and production

### 2. Monitoring Stack

#### Prometheus Server
- **Location**: `http://localhost:9090`
- **Configuration**: `monitoring/prometheus/prometheus.yml`
- **Targets**: API instances, MySQL, Nginx, Node Exporter
- **Alert Rules**: `monitoring/prometheus/rules/api_alerts.yml`

#### Grafana Dashboard
- **Location**: `http://localhost:3000`
- **Credentials**: admin/admin
- **Datasource**: Prometheus (auto-configured)
- **Provisioning**: `monitoring/grafana/provisioning/`

#### Node Exporter
- **Location**: `http://localhost:9100`
- **Purpose**: System metrics collection

### 3. API Metrics Integration

#### Prometheus Client
- **Package**: `github.com/prometheus/client_golang`
- **Middleware**: `internal/middlewares/prometheus.go`
- **Metrics Endpoint**: `http://localhost:8080/metrics`

#### Custom Metrics Implemented

##### HTTP Metrics
- `http_requests_total`: Total HTTP requests by method, path, status
- `http_request_duration_seconds`: Request duration histogram
- `http_active_connections`: Active HTTP connections gauge
- `http_request_size_bytes`: Request size histogram
- `http_response_size_bytes`: Response size histogram

##### Authentication Metrics
- `auth_attempts_total`: Authentication attempts by type (signin/signup) and status
- `jwt_tokens_issued_total`: Total JWT tokens issued
- `jwt_tokens_validated_total`: JWT token validations by status

##### Database Metrics
- `db_connections_active`: Active database connections
- `db_connections_idle`: Idle database connections

##### API Endpoint Metrics
- `api_endpoint_calls_total`: API endpoint calls by endpoint, method, status

## Setup Instructions

### 1. Start the Complete Stack
```bash
# Start all services including monitoring
docker-compose up -d

# Check container status
docker-compose ps
```

### 2. Verify API Integration
```bash
# Check API health
curl http://localhost:8080/api/v1/health

# Check metrics endpoint
curl http://localhost:8080/metrics
```

### 3. Access Monitoring Dashboards
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin)

### 4. Run Comprehensive Tests
```bash
# Run the monitoring test script
powershell -ExecutionPolicy Bypass -File test-monitoring.ps1
```

## Metrics Collection

### Automatic Collection
- **HTTP Metrics**: Collected via Prometheus middleware on every request
- **Database Metrics**: Collected every 30 seconds via metrics service
- **Authentication Metrics**: Recorded on every auth attempt
- **JWT Metrics**: Recorded on token issuance and validation

### Manual Testing
```bash
# Generate some metrics by making API calls
curl -X POST http://localhost:8080/api/v1/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"password123"}'

curl -X POST http://localhost:8080/api/v1/auth/signin \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Check updated metrics
curl http://localhost:8080/metrics | grep auth_attempts_total
```

## Alert Rules

### API Alerts (`monitoring/prometheus/rules/api_alerts.yml`)
- **APIInstanceDown**: Triggers when API instance is unreachable
- **APIHighResponseTime**: Triggers when response time > 1 second
- **APIHighErrorRate**: Triggers when error rate > 5%
- **APIHighMemoryUsage**: Triggers when memory usage > 80%
- **APIHighCPUUsage**: Triggers when CPU usage > 80%
- **APIHighDiskUsage**: Triggers when disk usage > 85%

## File Structure

```
pseudo-app/
├── .github/workflows/ci-cd.yml          # GitHub Actions workflow
├── .gitlab-ci.yml                       # GitLab CI/CD pipeline
├── docker-compose.yml                   # Complete stack with monitoring
├── monitoring/
│   ├── prometheus/
│   │   ├── prometheus.yml               # Prometheus configuration
│   │   └── rules/api_alerts.yml         # Alert rules
│   └── grafana/
│       └── provisioning/                # Grafana auto-configuration
├── api/
│   ├── internal/middlewares/
│   │   ├── prometheus.go                # Prometheus middleware
│   │   └── metrics.go                   # Custom metrics
│   └── internal/services/database/
│       └── metrics_service.go           # Database metrics service
└── test-monitoring.ps1                  # Comprehensive test script
```

## Troubleshooting

### Common Issues

1. **Metrics not appearing**: Check if Prometheus middleware is properly registered
2. **Database metrics missing**: Verify metrics service is started in main.go
3. **Containers not starting**: Check Docker Compose logs with `docker-compose logs`
4. **Authentication metrics not recording**: Verify metrics calls in auth handlers

### Debugging Commands
```bash
# Check container logs
docker-compose logs prometheus
docker-compose logs grafana
docker-compose logs api1

# Check API logs
docker-compose logs api1 api2 api3

# Test individual components
curl http://localhost:9090/-/healthy    # Prometheus health
curl http://localhost:3000/api/health   # Grafana health
curl http://localhost:8080/metrics      # API metrics
```

## Next Steps

1. **Custom Dashboards**: Create Grafana dashboards for business metrics
2. **Alerting**: Configure alert notifications (email, Slack, etc.)
3. **Production Setup**: Adjust configurations for production environment
4. **Security**: Implement proper authentication for monitoring endpoints
5. **Backup**: Set up monitoring data backup and retention policies

## Security Considerations

- Metrics endpoint is publicly accessible (consider authentication in production)
- Default Grafana credentials should be changed in production
- Prometheus configuration should be secured
- Alert rules should be reviewed and customized for production use