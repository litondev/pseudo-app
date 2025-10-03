# Nginx Load Balancer Configuration

This directory contains the Nginx configuration for load balancing multiple API instances in the pseudo-app project.

## Files

- `nginx.conf` - Main Nginx configuration file with load balancing setup

## Configuration Overview

### Load Balancing Strategy
- **Method**: Round-robin (default)
- **Backend Servers**: 3 API instances (api1, api2, api3)
- **Health Checks**: Automatic failover with retry logic
- **Weight**: Equal weight (1) for all instances

### Features
- **Gzip Compression**: Enabled for better performance
- **Rate Limiting**: 10 requests per second per IP with burst of 20
- **Health Monitoring**: `/nginx-health` endpoint for monitoring
- **Logging**: Access and error logs stored in `/var/log/nginx/`
- **Timeout Settings**: Optimized for API responses
- **Static File Serving**: Proxy support for Swagger UI and documentation

### Upstream Configuration
```nginx
upstream api_backend {
    server api1:8000 weight=1 max_fails=3 fail_timeout=30s;
    server api2:8000 weight=1 max_fails=3 fail_timeout=30s;
    server api3:8000 weight=1 max_fails=3 fail_timeout=30s;
    keepalive 32;
}
```

### Load Balancing Methods
The current configuration uses round-robin. You can change to:
- `least_conn` - Routes to server with least active connections
- `ip_hash` - Routes based on client IP hash (session persistence)
- `hash` - Custom hash-based routing

### Health Checks
- **Max Fails**: 3 consecutive failures before marking server as down
- **Fail Timeout**: 30 seconds before retrying failed server
- **Next Upstream**: Automatic retry on error/timeout/5xx responses

### Rate Limiting
- **Zone**: `api_limit` with 10MB memory
- **Rate**: 10 requests per second per IP
- **Burst**: Up to 20 requests in burst with no delay

## Usage with Docker Compose

The Nginx load balancer is configured in `docker-compose.yml` to:
1. Listen on ports 80 and 443
2. Route traffic to 3 API instances
3. Provide health check endpoint
4. Store logs in named volume

## Monitoring

### Health Check Endpoints
- **Nginx Health**: `http://localhost/nginx-health`
- **API Health**: Proxied through load balancer to `/api/v1/health`

### Logs
- **Access Log**: `/var/log/nginx/access.log`
- **Error Log**: `/var/log/nginx/error.log`
- **Docker Volume**: `nginx_logs` for persistent storage

## Scaling

To add more API instances:
1. Add new service in `docker-compose.yml`
2. Add server entry in `nginx.conf` upstream block
3. Restart the stack

## Security Features
- Rate limiting to prevent abuse
- Proper header forwarding for client identification
- Timeout configurations to prevent resource exhaustion
- Health check isolation

## Performance Optimizations
- Gzip compression for text-based responses
- Connection keep-alive for upstream servers
- Optimized buffer settings
- Efficient worker configuration