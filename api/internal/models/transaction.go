package models

import (
	"time"
	"gorm.io/gorm"
)

type Transaction struct {
	ID          uint           `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID      *uint          `json:"user_id" gorm:"default:null;index"`
	WarehouseID *uint          `json:"warehouse_id" gorm:"default:null;index"`
	ProductID   *uint          `json:"product_id" gorm:"default:null;index"`
	Type        *string        `json:"type" gorm:"type:enum('in','out');default:null"`
	Quantity    *float64       `json:"quantity" gorm:"type:decimal(20,2);default:null"`
	CreatedAt   time.Time      `json:"created_at" gorm:"autoCreateTime"`
	UpdatedAt   time.Time      `json:"updated_at" gorm:"autoUpdateTime"`
	DeletedAt   gorm.DeletedAt `json:"deleted_at,omitempty" gorm:"index"`

	// Relationships
	User      *User      `json:"user,omitempty" gorm:"foreignKey:UserID;constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`
	Warehouse *Warehouse `json:"warehouse,omitempty" gorm:"foreignKey:WarehouseID;constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`
	Product   *Product   `json:"product,omitempty" gorm:"foreignKey:ProductID;constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`
}

// TableName specifies the table name for Transaction model
func (Transaction) TableName() string {
	return "transactions"
}

// TransactionResponse represents the transaction data for API responses
type TransactionResponse struct {
	ID          uint                `json:"id"`
	UserID      *uint               `json:"user_id"`
	WarehouseID *uint               `json:"warehouse_id"`
	ProductID   *uint               `json:"product_id"`
	Type        *string             `json:"type"`
	Quantity    *float64            `json:"quantity"`
	CreatedAt   time.Time           `json:"created_at"`
	UpdatedAt   time.Time           `json:"updated_at"`
	User        *UserResponse       `json:"user,omitempty"`
	Warehouse   *WarehouseResponse  `json:"warehouse,omitempty"`
	Product     *ProductResponse    `json:"product,omitempty"`
}

// ToResponse converts Transaction to TransactionResponse
func (t *Transaction) ToResponse() TransactionResponse {
	response := TransactionResponse{
		ID:          t.ID,
		UserID:      t.UserID,
		WarehouseID: t.WarehouseID,
		ProductID:   t.ProductID,
		Type:        t.Type,
		Quantity:    t.Quantity,
		CreatedAt:   t.CreatedAt,
		UpdatedAt:   t.UpdatedAt,
	}

	// Include related models if they are loaded
	if t.User != nil {
		userResponse := t.User.ToResponse()
		response.User = &userResponse
	}
	if t.Warehouse != nil {
		warehouseResponse := t.Warehouse.ToResponse()
		response.Warehouse = &warehouseResponse
	}
	if t.Product != nil {
		productResponse := t.Product.ToResponse()
		response.Product = &productResponse
	}

	return response
}