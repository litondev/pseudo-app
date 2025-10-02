package models

import (
	"time"
	"gorm.io/gorm"
)

type Product struct {
	ID        uint           `json:"id" gorm:"primaryKey;autoIncrement"`
	Name      *string        `json:"name" gorm:"type:varchar(100);default:null"`
	Price     *float64       `json:"price" gorm:"type:decimal(20,2);default:null"`
	Stock     *float64       `json:"stock" gorm:"type:decimal(20,2);default:null"`
	Image     *string        `json:"image" gorm:"type:varchar(100);default:null"`
	CreatedAt time.Time      `json:"created_at" gorm:"autoCreateTime"`
	UpdatedAt time.Time      `json:"updated_at" gorm:"autoUpdateTime"`
	DeletedAt gorm.DeletedAt `json:"deleted_at,omitempty" gorm:"index"`
}

// TableName specifies the table name for Product model
func (Product) TableName() string {
	return "products"
}

// ProductResponse represents the product data for API responses
type ProductResponse struct {
	ID        uint      `json:"id"`
	Name      *string   `json:"name"`
	Price     *float64  `json:"price"`
	Stock     *float64  `json:"stock"`
	Image     *string   `json:"image"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// ToResponse converts Product to ProductResponse
func (p *Product) ToResponse() ProductResponse {
	return ProductResponse{
		ID:        p.ID,
		Name:      p.Name,
		Price:     p.Price,
		Stock:     p.Stock,
		Image:     p.Image,
		CreatedAt: p.CreatedAt,
		UpdatedAt: p.UpdatedAt,
	}
}