package models

import (
	"time"
	"gorm.io/gorm"
)

type Warehouse struct {
	ID        uint           `json:"id" gorm:"primaryKey;autoIncrement"`
	Name      *string        `json:"name" gorm:"type:varchar(100);default:null"`
	CreatedAt time.Time      `json:"created_at" gorm:"autoCreateTime"`
	UpdatedAt time.Time      `json:"updated_at" gorm:"autoUpdateTime"`
	DeletedAt gorm.DeletedAt `json:"deleted_at,omitempty" gorm:"index"`
}

// TableName specifies the table name for Warehouse model
func (Warehouse) TableName() string {
	return "warehouses"
}

// WarehouseResponse represents the warehouse data for API responses
type WarehouseResponse struct {
	ID        uint      `json:"id"`
	Name      *string   `json:"name"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// ToResponse converts Warehouse to WarehouseResponse
func (w *Warehouse) ToResponse() WarehouseResponse {
	return WarehouseResponse{
		ID:        w.ID,
		Name:      w.Name,
		CreatedAt: w.CreatedAt,
		UpdatedAt: w.UpdatedAt,
	}
}