-- SQL script to initialize Supabase database with sample data

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create tables (if not auto-created by Hibernate)
-- These tables will be auto-created by Spring Boot JPA, but you can run this for manual setup

-- Insert sample products
INSERT INTO products (name, description, price, image_url, category, stock_quantity, rating, active) VALUES
('Red Printed T-Shirt', 'Comfortable cotton t-shirt with red print', 3000.00, 'images/product-1.jpg', 'T-Shirts', 50, 4.5, true),
('Black Shoes', 'Premium quality black formal shoes', 5000.00, 'images/product-2.jpg', 'Shoes', 30, 4.0, true),
('Grey Track Pants', 'Comfortable track pants for workout', 2500.00, 'images/product-3.jpg', 'Pants', 40, 4.2, true),
('Blue T-Shirt', 'Cool blue cotton t-shirt', 2800.00, 'images/product-4.jpg', 'T-Shirts', 60, 4.3, true),
('Black Leather Watch', 'Elegant black leather watch', 8000.00, 'images/product-5.jpg', 'Accessories', 20, 4.8, true),
('Puma T-Shirt', 'Puma branded sports t-shirt', 3500.00, 'images/product-6.jpg', 'T-Shirts', 35, 4.4, true),
('HRX Socks', 'Pack of 3 HRX sports socks', 1500.00, 'images/product-7.jpg', 'Accessories', 100, 4.1, true),
('Fossil Watch', 'Fossil branded premium watch', 12000.00, 'images/product-8.jpg', 'Accessories', 15, 4.9, true),
('Roadster Watch', 'Roadster casual watch', 4500.00, 'images/product-9.jpg', 'Accessories', 25, 4.0, true),
('Black Casual Shoes', 'Comfortable black casual shoes', 4000.00, 'images/product-10.jpg', 'Shoes', 45, 4.3, true),
('Sports Shoes', 'Running and training sports shoes', 6000.00, 'images/product-11.jpg', 'Shoes', 50, 4.6, true),
('Nike Red Shoes', 'Nike branded red sports shoes', 7500.00, 'images/product-12.jpg', 'Shoes', 30, 4.7, true);

-- Create sample admin user (password: admin123)
-- Password is BCrypt encoded
INSERT INTO users (email, password, full_name, phone_number, address, enabled, created_at) VALUES
('admin@fashionretail.com', '$2a$12$fBJwnvVTYjgB/Nynz5zihO7811mmGqqVQpXcn/8O..IdK.Q3E0Bli', 'Admin User', '1234567890', '123 Admin Street', true, NOW());

-- Add admin role
INSERT INTO user_roles (user_id, role) VALUES
((SELECT id FROM users WHERE email = 'admin@fashionretail.com'), 'ROLE_ADMIN'),
((SELECT id FROM users WHERE email = 'admin@fashionretail.com'), 'ROLE_USER');

-- Note: Replace '$2a$10$YourBCryptEncodedPasswordHere' with actual BCrypt encoded password
-- You can generate it using an online BCrypt generator or through the application's registration endpoint
