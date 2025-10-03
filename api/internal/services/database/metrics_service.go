package database

import (
	"api/internal/middlewares"
	"database/sql"
	"log"
	"time"

	"gorm.io/gorm"
)

// MetricsService handles database metrics collection
type MetricsService struct {
	db *gorm.DB
}

// NewMetricsService creates a new metrics service
func NewMetricsService(db *gorm.DB) *MetricsService {
	return &MetricsService{
		db: db,
	}
}

// StartMetricsCollection starts collecting database metrics periodically
func (s *MetricsService) StartMetricsCollection() {
	ticker := time.NewTicker(30 * time.Second) // Collect metrics every 30 seconds
	go func() {
		defer ticker.Stop()
		for {
			select {
			case <-ticker.C:
				s.collectDBMetrics()
			}
		}
	}()
}

// collectDBMetrics collects and updates database connection metrics
func (s *MetricsService) collectDBMetrics() {
	sqlDB, err := s.db.DB()
	if err != nil {
		log.Printf("Error getting underlying sql.DB for metrics: %v", err)
		return
	}

	stats := sqlDB.Stats()
	
	// Update Prometheus metrics
	middlewares.UpdateDBConnectionMetrics(
		stats.OpenConnections,
		stats.Idle,
	)
}

// GetDBStats returns current database statistics
func (s *MetricsService) GetDBStats() (*sql.DBStats, error) {
	sqlDB, err := s.db.DB()
	if err != nil {
		return nil, err
	}

	stats := sqlDB.Stats()
	return &stats, nil
}