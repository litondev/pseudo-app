# Test Monitoring Setup Script
# This script tests the complete CI/CD and Prometheus monitoring setup

Write-Host "=== Testing Pseudo App Monitoring Setup ===" -ForegroundColor Green

# Test 1: Check if Docker containers are running
Write-Host "`n1. Checking Docker containers status..." -ForegroundColor Yellow
$containers = docker-compose ps --format "table {{.Name}}\t{{.Status}}"
Write-Host $containers

# Test 2: Test API health endpoint
Write-Host "`n2. Testing API health endpoint..." -ForegroundColor Yellow
try {
    $healthResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/health" -Method GET
    Write-Host "Health Status: $($healthResponse.status)" -ForegroundColor Green
    Write-Host "Database: $($healthResponse.database)" -ForegroundColor Green
} catch {
    Write-Host "API Health check failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Test API metrics endpoint
Write-Host "`n3. Testing API metrics endpoint..." -ForegroundColor Yellow
try {
    $metricsResponse = Invoke-WebRequest -Uri "http://localhost:8080/metrics" -Method GET
    $metricsLines = ($metricsResponse.Content -split "`n").Count
    Write-Host "Metrics endpoint accessible - $metricsLines lines of metrics" -ForegroundColor Green
    
    # Check for specific metrics
    if ($metricsResponse.Content -match "http_requests_total") {
        Write-Host "✓ HTTP request metrics found" -ForegroundColor Green
    }
    if ($metricsResponse.Content -match "auth_attempts_total") {
        Write-Host "✓ Authentication metrics found" -ForegroundColor Green
    }
    if ($metricsResponse.Content -match "jwt_tokens_issued_total") {
        Write-Host "✓ JWT token metrics found" -ForegroundColor Green
    }
    if ($metricsResponse.Content -match "db_connections_active") {
        Write-Host "✓ Database connection metrics found" -ForegroundColor Green
    }
} catch {
    Write-Host "Metrics endpoint test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Test Prometheus server
Write-Host "`n4. Testing Prometheus server..." -ForegroundColor Yellow
try {
    $prometheusResponse = Invoke-WebRequest -Uri "http://localhost:9090/-/healthy" -Method GET
    if ($prometheusResponse.StatusCode -eq 200) {
        Write-Host "✓ Prometheus server is healthy" -ForegroundColor Green
    }
} catch {
    Write-Host "Prometheus server test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Test Grafana server
Write-Host "`n5. Testing Grafana server..." -ForegroundColor Yellow
try {
    $grafanaResponse = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -Method GET
    if ($grafanaResponse.StatusCode -eq 200) {
        Write-Host "✓ Grafana server is healthy" -ForegroundColor Green
    }
} catch {
    Write-Host "Grafana server test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Test authentication flow and metrics
Write-Host "`n6. Testing authentication flow and metrics..." -ForegroundColor Yellow
try {
    # Test signup
    $signupData = @{
        name = "Test User"
        email = "test@example.com"
        password = "password123"
    } | ConvertTo-Json
    
    $signupResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/auth/signup" -Method POST -Body $signupData -ContentType "application/json"
    Write-Host "✓ Signup test completed" -ForegroundColor Green
    
    # Test signin
    $signinData = @{
        email = "test@example.com"
        password = "password123"
    } | ConvertTo-Json
    
    $signinResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/auth/signin" -Method POST -Body $signinData -ContentType "application/json"
    Write-Host "✓ Signin test completed" -ForegroundColor Green
    
    # Check if metrics were updated
    Start-Sleep -Seconds 2
    $metricsAfterAuth = Invoke-WebRequest -Uri "http://localhost:8080/metrics" -Method GET
    if ($metricsAfterAuth.Content -match "auth_attempts_total.*signup.*success") {
        Write-Host "✓ Signup metrics recorded" -ForegroundColor Green
    }
    if ($metricsAfterAuth.Content -match "auth_attempts_total.*signin.*success") {
        Write-Host "✓ Signin metrics recorded" -ForegroundColor Green
    }
    
} catch {
    Write-Host "Authentication flow test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 7: Check CI/CD files
Write-Host "`n7. Checking CI/CD configuration files..." -ForegroundColor Yellow
if (Test-Path ".github\workflows\ci-cd.yml") {
    Write-Host "✓ GitHub Actions workflow file exists" -ForegroundColor Green
} else {
    Write-Host "✗ GitHub Actions workflow file missing" -ForegroundColor Red
}

if (Test-Path ".gitlab-ci.yml") {
    Write-Host "✓ GitLab CI/CD pipeline file exists" -ForegroundColor Green
} else {
    Write-Host "✗ GitLab CI/CD pipeline file missing" -ForegroundColor Red
}

Write-Host "`n=== Monitoring Setup Test Complete ===" -ForegroundColor Green
Write-Host "`nAccess URLs:" -ForegroundColor Cyan
Write-Host "- API: http://localhost:8080" -ForegroundColor White
Write-Host "- Prometheus: http://localhost:9090" -ForegroundColor White
Write-Host "- Grafana: http://localhost:3000 (admin/admin)" -ForegroundColor White
Write-Host "- API Metrics: http://localhost:8080/metrics" -ForegroundColor White
Write-Host "- API Health: http://localhost:8080/api/v1/health" -ForegroundColor White