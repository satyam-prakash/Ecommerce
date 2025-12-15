-- Sample data for local H2 database testing

-- Insert sample products
INSERT INTO products (name, description, price, category, stock_quantity, rating, active) VALUES
('Blue T-Shirt', 'Comfortable cotton blue t-shirt', 29.99, 'Clothing', 50, 4.5, true),
('Black Shoes', 'Stylish black leather shoes', 79.99, 'Footwear', 30, 4.7, true),
('Grey Track Pants', 'Athletic grey track pants', 39.99, 'Sportswear', 40, 4.3, true),
('Black Leather Watch', 'Premium leather strap watch', 149.99, 'Accessories', 20, 4.8, true),
('White Sneakers', 'Casual white sneakers', 59.99, 'Footwear', 35, 4.6, true),
('Red Jacket', 'Stylish red jacket', 89.99, 'Clothing', 25, 4.4, true);

-- Insert a test user (password: password123 - BCrypt encoded)
INSERT INTO users (email, password, full_name, phone_number, address, enabled, created_at) VALUES
('test@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye1RJ1elQ7QJXYpA0xLLb3Hp6IQF/3YQe', 'Test User', '1234567890', '123 Test Street', true, CURRENT_TIMESTAMP);

-- Insert default role for test user
INSERT INTO user_roles (user_id, role) VALUES
(1, 'ROLE_USER');
