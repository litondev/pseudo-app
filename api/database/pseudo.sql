-- Database: pseudo
-- Created for Pseudo App Project

SET FOREIGN_KEY_CHECKS=0;

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS pseudo;
USE pseudo;

-- Table: users
CREATE TABLE IF NOT EXISTS users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) DEFAULT NULL,
    email VARCHAR(100) DEFAULT NULL,
    password TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: warehouses
CREATE TABLE IF NOT EXISTS warehouses (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: products
CREATE TABLE IF NOT EXISTS products (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) DEFAULT NULL,
    price DECIMAL(20,2) DEFAULT NULL,
    stock DECIMAL(20,2) DEFAULT NULL,
    image VARCHAR(100) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: transactions
CREATE TABLE IF NOT EXISTS transactions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED DEFAULT NULL,
    product_id BIGINT UNSIGNED DEFAULT NULL,
    warehouse_id BIGINT UNSIGNED DEFAULT NULL,
    quantity DECIMAL(20,2) DEFAULT NULL,
    total_price DECIMAL(20,2) DEFAULT NULL,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    
    -- Foreign key constraints
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Indexes for better performance
CREATE INDEX idx_transactions_user_id ON transactions(user_id);
CREATE INDEX idx_transactions_product_id ON transactions(product_id);
CREATE INDEX idx_transactions_warehouse_id ON transactions(warehouse_id);
CREATE INDEX idx_transactions_date ON transactions(date);
CREATE INDEX idx_transactions_deleted_at ON transactions(deleted_at);

-- Insert sample data (optional)
INSERT INTO users (name, email, password) VALUES 
('Admin User', 'admin@pseudo.com', '$2a$10$example_hashed_password'),
('Test User', 'test@pseudo.com', '$2a$10$example_hashed_password');

INSERT INTO warehouses (name) VALUES 
('Main Warehouse'),
('Secondary Warehouse');

INSERT INTO products (name, price, stock) VALUES 
('Product A', 100.00, 50.00),
('Product B', 200.00, 30.00),
('Product C', 150.00, 75.00);

SET FOREIGN_KEY_CHECKS=1;
