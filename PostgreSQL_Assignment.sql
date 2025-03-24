-- Active: 1742265938903@@127.0.0.1@5432@bookstore_db

-- --------------------Table Creation--------------------

-- Create the books table
CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    stock INTEGER NOT NULL,
    published_year INTEGER NOT NULL
);

-- Create the customers table
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    joined_date DATE NOT NULL DEFAULT CURRENT_DATE
);

-- Create the orders table
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers (id),
    book_id INTEGER NOT NULL REFERENCES books (id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- --------------------Sample Data Insertion--------------------

-- Insert sample data into books table
INSERT INTO
    books (
        title,
        author,
        price,
        stock,
        published_year
    )
VALUES (
        'The Pragmatic Programmer',
        'Andrew Hunt',
        40.00,
        10,
        1999
    ),
    (
        'Clean Code',
        'Robert C. Martin',
        35.00,
        5,
        2008
    ),
    (
        'You Don''t Know JS',
        'Kyle Simpson',
        30.00,
        8,
        2014
    ),
    (
        'Refactoring',
        'Martin Fowler',
        50.00,
        3,
        1999
    ),
    (
        'Database Design Principles',
        'Jane Smith',
        20.00,
        0,
        2018
    );

-- Insert sample data into customers table
INSERT INTO
    customers (name, email, joined_date)
VALUES (
        'Alice',
        'alice@email.com',
        '2023-01-10'
    ),
    (
        'Bob',
        'bob@email.com',
        '2022-05-15'
    ),
    (
        'Charlie',
        'charlie@email.com',
        '2023-06-20'
    );

-- Insert sample data into orders table
INSERT INTO
    orders (
        customer_id,
        book_id,
        quantity,
        order_date
    )
VALUES (1, 2, 1, '2024-03-10'),
    (2, 1, 1, '2024-02-20'),
    (1, 3, 2, '2024-03-05');

-- --------------------Check all data inserted successfully--------------------
-- SELECT * FROM books;

-- SELECT * FROM customers;

-- SELECT * FROM orders;

-- --------------------Delete tables--------------------
-- DROP TABLE IF EXISTS orders, customers, books;

-- --------------------PostgreSQL Queries--------------------

-- Query 1: Find books that are out of stock
SELECT title FROM books WHERE stock = 0;

-- Query 2: Retrieve the most expensive book in the store
SELECT * FROM books WHERE price = ( SELECT MAX(price) FROM books );

-- Query 3: Find the total number of orders placed by each customer
-- N.B: INNER JOIN ensures we only see customers who have actually placed orders.
SELECT c.name, COUNT(o.id) AS total_orders
FROM customers c
    INNER JOIN orders o ON c.id = o.customer_id
GROUP BY
    c.name;

-- Query 4: Calculate the total revenue generated from book sales
-- N.B: Multiplies book price by quantity ordered to calculate actual revenue.
SELECT SUM(b.price * o.quantity) AS total_revenue
FROM orders o
    JOIN books b ON o.book_id = b.id;

-- Query 5: List all customers who have placed more than one order
-- N.B: We group by both customer ID and name because different customers might have the same name
SELECT c.name, COUNT(o.id) AS orders_count
FROM customers c
    JOIN orders o ON c.id = o.customer_id
GROUP BY
    c.id,
    c.name
HAVING
    COUNT(o.id) > 1;

-- Query 6: Find the average price of books in the store
-- N.B: We use ROUND to round the average price to 2 decimal places for readability.
SELECT ROUND(AVG(price), 2) AS avg_book_price FROM books;

-- Query 7: Increase the price of all books published before 2000 by 10%
UPDATE books SET price = price * 1.1 WHERE published_year < 2000;

-- Verify the update
SELECT * FROM books ORDER BY id;

-- Query 8: Delete customers who haven't placed any orders
-- N.B: We use EXCEPT to find customers who haven't placed any orders.
DELETE FROM customers
WHERE
    id IN (
        SELECT id
        FROM customers
        EXCEPT
        SELECT customer_id
        FROM orders
    );

-- Verify the deletion
SELECT * FROM customers;