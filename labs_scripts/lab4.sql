-- №1 Наличие товара на складе
SELECT p.id, p.name, s.quantity
FROM products p
         JOIN storages s ON p.id = s.product_id
ORDER BY s.quantity;

-- №2 Цена товара
SELECT p.price
FROM products p
WHERE p.name = 'Red Brick';

-- №3 Категория товара
SELECT c.name, c.description
FROM categories c
JOIN products p
ON p.category_id = c.id
WHERE p.name = 'Red Brick';

-- №4 Поставщик по товару
SELECT s.company_name, s.contact_person, s.email
FROM suppliers s
JOIN products p
ON s.id = p.supplier_id;

-- №5 Все заказы клиента
SELECT *
FROM orders o
WHERE o.customer_id = 1;

-- №6 Статус заказа
SELECT o.status
FROM orders o
WHERE o.id = 1;

-- №7 Платеж по заказу
SELECT o.id, p.amount, p.payment_method, p.date
FROM orders o
JOIN payments p
ON o.id = p.order_id
WHERE o.id = 1;

-- №8 Добавить клиента
INSERT INTO customers (first_name, last_name, address, email, phone_number)
VALUES ('Oleg', 'Frolov', 'Volgograd', 'oleg123@mail.com', '799954152060');

-- №9 Добавить товар
INSERT INTO products(name, unit, description, price, category_id, supplier_id)
VALUES ('Sand brick', 'pcs', 'Standard building brick', 10, 1, 1);

-- №10 Добавить поставщика
INSERT INTO suppliers(company_name, contact_person, email, phone_number, address)
VALUES ('BrickPro', 'Alexander', 'brickpro34@mail.com', '79955555555', 'Volgograd');

-- №11 Добавить категорию
INSERT INTO categories(name, description)
VALUES ('Doors', '');

-- №12 Оформить заказ
INSERT INTO orders (status, employee_id, customer_id)
VALUES ('new', 1, 1);

-- №13 Добавить товар в заказ
INSERT INTO order_details (order_id, product_id, quantity)
VALUES (1, 1, 5);

-- №14 Изменить статус заказа
UPDATE orders
SET status = 'delivered'
WHERE id = 1;

-- №15 Добавить платеж
INSERT INTO payments (amount, payment_method, order_id)
VALUES (5000, 'card', 1);

-- №16 Зарегистрировать доставку
INSERT INTO deliveries (courier_name, expected_time, order_id)
VALUES ('Иван', NOW() + INTERVAL '2 days', 3);

-- №17 Уменьшить остаток товара
UPDATE storages
SET quantity = quantity - 5
WHERE product_id = 1;

-- №18 Пополнить склад
UPDATE storages
SET quantity = quantity + 100
WHERE product_id = 1;

-- №19 Удалить заказ
DELETE FROM orders
WHERE id = 1;

-- №20 Количество товаров в категории
SELECT category_id, COUNT(*)
FROM products
GROUP BY category_id;

-- №21 Нет на складе
SELECT p.name
FROM products p
         JOIN storages s ON p.id = s.product_id
WHERE s.quantity = 0;

-- №22 Объем продаж
SELECT SUM(d.quantity * p.price)
FROM order_details d
JOIN products p ON d.product_id = p.id
JOIN orders o ON d.order_id = o.id
WHERE o.date BETWEEN '2025-01-01' AND '2025-12-31';

-- №23 Сумма за месяц
SELECT SUM(p.amount)
FROM payments p
WHERE DATE_TRUNC('month', p.date) = DATE_TRUNC('month', CURRENT_DATE);

-- №24 Поставки по поставщику
SELECT s.company_name, COUNT(*)
FROM suppliers s
         JOIN products pr ON s.id = pr.supplier_id
GROUP BY s.company_name;

-- №25 Топ товары
SELECT p.name, SUM(d.quantity)
FROM products p
         JOIN order_details d ON p.id = d.product_id
GROUP BY p.name
ORDER BY SUM(d.quantity) DESC
LIMIT 5;

-- №26 INNER JOIN
SELECT o.id, c.first_name
FROM orders o
         JOIN customers c ON o.customer_id = c.id;

-- №27 LEFT JOIN
SELECT c.first_name, o.id
FROM customers c
         LEFT JOIN orders o ON c.id = o.customer_id;

-- №28 RIGHT JOIN
SELECT o.id, c.first_name
FROM orders o
         RIGHT JOIN customers c ON o.customer_id = c.id;

-- №29 FULL JOIN
SELECT c.first_name, o.id
FROM customers c
         FULL JOIN orders o ON c.id = o.customer_id;

-- №30 CROSS JOIN
SELECT c.first_name, p.name
FROM customers c
         CROSS JOIN products p;

-- №31 BETWEEN
SELECT *
FROM products
WHERE price BETWEEN 100 AND 1000;

-- №32 IN
SELECT *
FROM products
WHERE id IN (1,2,3);

-- №33 IS NULL
SELECT *
FROM orders
WHERE employee_id IS NULL;

-- №34 NOT
SELECT *
FROM orders
WHERE NOT customer_id = 1;

-- №35 LIKE
SELECT *
FROM products
WHERE name LIKE '%Brick%';

-- №36 LIKE email
SELECT *
FROM customers
WHERE email LIKE '%mail.com';

-- №37 Дороже среднего
SELECT *
FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- №38 Клиенты с заказами
SELECT *
FROM customers
WHERE id IN (SELECT customer_id FROM orders);

-- №39 Без заказов
SELECT *
FROM customers c
WHERE NOT EXISTS (
    SELECT 1 FROM orders o WHERE o.customer_id = c.id
);

-- №40 GROUP BY
SELECT customer_id, COUNT(*)
FROM orders
GROUP BY customer_id;

-- №41 AVG
SELECT category_id, AVG(price)
FROM products
GROUP BY category_id;

-- №42 SUM
SELECT product_id, SUM(quantity)
FROM order_details
GROUP BY product_id;

-- №43 CTE
WITH order_counts AS (
    SELECT customer_id, COUNT(*) AS count
    FROM orders
    GROUP BY customer_id
)
SELECT * FROM order_counts;

-- №44 CTE продажи
WITH sales AS (
    SELECT o.customer_id, SUM(d.quantity) AS total
    FROM orders o
             JOIN order_details d ON o.id = d.order_id
    GROUP BY o.customer_id
)
SELECT * FROM sales ORDER BY total DESC;

-- №45 UNION
SELECT first_name FROM customers
UNION
SELECT first_name
FROM employees;

-- №46 INTERSECT
SELECT id FROM customers
INTERSECT
SELECT customer_id
FROM orders;

-- №47 EXCEPT
SELECT id FROM customers
EXCEPT
SELECT customer_id
FROM orders;

-- №48 LENGTH
SELECT name, LENGTH(name)
FROM products;

-- №49 UPPER
SELECT UPPER(name)
FROM products;
-- №51 Удалить клиента
DELETE FROM customers
WHERE id = 1;

-- №52 Удалить товар
DELETE FROM products
WHERE id = 1;

-- №53 Удалить поставщика
DELETE FROM suppliers
WHERE id = 1;

-- №54 Удалить категорию
DELETE FROM categories
WHERE id = 1;

-- №55 Удалить платеж
DELETE FROM payments
WHERE id = 1;

-- №56 Клиенты и сумма их заказов
EXPLAIN ANALYZE
SELECT c.id, c.first_name, SUM(p.amount)
FROM customers c
JOIN orders o ON c.id = o.customer_id
JOIN payments p ON o.id = p.order_id
GROUP BY c.id, c.first_name;

-- №57 Количество товаров в каждом заказе
SELECT o.id, SUM(d.quantity)
FROM orders o
         JOIN order_details d ON o.id = d.order_id
GROUP BY o.id;

-- №58 Средний чек по клиенту
SELECT c.id, AVG(p.amount)
FROM customers c
         JOIN orders o ON c.id = o.customer_id
         JOIN payments p ON o.id = p.order_id
GROUP BY c.id;

-- №59 Сколько товаров продал каждый поставщик
SELECT s.company_name, SUM(d.quantity)
FROM suppliers s
         JOIN products p ON s.id = p.supplier_id
         JOIN order_details d ON p.id = d.product_id
GROUP BY s.company_name;

-- №60 Количество заказов по статусам
SELECT status, COUNT(*)
FROM orders
GROUP BY status;

-- №61 Самый дорогой товар в категории
SELECT category_id, MAX(price)
FROM products
GROUP BY category_id;

-- №62 Количество заказов по дням
SELECT date, COUNT(*)
FROM orders
GROUP BY date;

-- №63 Заказы и их общая сумма
SELECT o.id, SUM(d.quantity * p.price)
FROM orders o
         JOIN order_details d ON o.id = d.order_id
         JOIN products p ON d.product_id = p.id
GROUP BY o.id;

-- №64 Топ клиенты по количеству товаров
SELECT c.id, SUM(d.quantity) AS total
FROM customers c
         JOIN orders o ON c.id = o.customer_id
         JOIN order_details d ON o.id = d.order_id
GROUP BY c.id
ORDER BY total DESC;

-- №65 Количество товаров у поставщика
SELECT s.company_name, COUNT(p.id)
FROM suppliers s
         JOIN products p ON s.id = p.supplier_id
GROUP BY s.company_name;

-- №66 Заказы без доставки
SELECT o.id
FROM orders o
         LEFT JOIN deliveries d ON o.id = d.order_id
WHERE d.id IS NULL;

-- №67 Заказы без платежей
SELECT o.id
FROM orders o
         LEFT JOIN payments p ON o.id = p.order_id
WHERE p.id IS NULL;

-- №68 Клиенты без заказов
SELECT c.id
FROM customers c
         LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.id IS NULL;

-- №69 Товары без заказов
SELECT p.id
FROM products p
         LEFT JOIN order_details d ON p.id = d.product_id
WHERE d.product_id IS NULL;

-- №70 Максимальная сумма заказа
SELECT MAX(total)
FROM (
         SELECT o.id, SUM(d.quantity * p.price) AS total
         FROM orders o
                  JOIN order_details d ON o.id = d.order_id
                  JOIN products p ON d.product_id = p.id
         GROUP BY o.id
     ) t;

-- №71 Минимальная сумма заказа
SELECT MIN(total)
FROM (
         SELECT o.id, SUM(d.quantity * p.price) AS total
         FROM orders o
                  JOIN order_details d ON o.id = d.order_id
                  JOIN products p ON d.product_id = p.id
         GROUP BY o.id
     ) t;

-- №72 Средняя сумма заказа
SELECT AVG(total)
FROM (
         SELECT o.id, SUM(d.quantity * p.price) AS total
         FROM orders o
                  JOIN order_details d ON o.id = d.order_id
                  JOIN products p ON d.product_id = p.id
         GROUP BY o.id
     ) t;

-- №73 Количество товаров в заказах по клиентам
SELECT c.id, COUNT(d.product_id)
FROM customers c
         JOIN orders o ON c.id = o.customer_id
         JOIN order_details d ON o.id = d.order_id
GROUP BY c.id;

-- №74 Заказы с количеством товаров > 10
SELECT o.id, SUM(d.quantity)
FROM orders o
         JOIN order_details d ON o.id = d.order_id
GROUP BY o.id
HAVING SUM(d.quantity) > 10;

-- №75 Топ категории по продажам
SELECT p.category_id, SUM(d.quantity)
FROM products p
         JOIN order_details d ON p.id = d.product_id
GROUP BY p.category_id
ORDER BY SUM(d.quantity) DESC;

-- №76 Сколько заказов у каждого сотрудника
SELECT employee_id, COUNT(*)
FROM orders
GROUP BY employee_id;

-- №77 Сотрудники и сумма продаж
SELECT e.id, SUM(p.amount) AS total_sum
FROM employees e
         JOIN orders o ON e.id = o.employee_id
         JOIN payments p ON o.id = p.order_id
GROUP BY e.id
ORDER BY total_sum DESC ;

-- №78 Заказы за последние 7 дней
SELECT *
FROM orders
WHERE date >= CURRENT_DATE - INTERVAL '7 days';

-- №79 Товары дороже 500
SELECT *
FROM products
WHERE price > 500;

-- №80 Обновить цену на 10%
UPDATE products
SET price = price * 1.1;

-- №81 Обнулить отрицательные остатки
UPDATE storages
SET quantity = 0
WHERE quantity < 0;

-- №82 Заказы с максимальной датой
SELECT *
FROM orders
WHERE date = (SELECT MAX(date) FROM orders);

-- №83 Количество товаров в заказе (alias)
SELECT o.id AS order_id, SUM(d.quantity) AS total_items
FROM orders o
         JOIN order_details d ON o.id = d.order_id
GROUP BY o.id;

-- №84 Общая сумма всех продаж
SELECT SUM(d.quantity * p.price)
FROM order_details d
         JOIN products p ON d.product_id = p.id;

-- №85 Количество клиентов
SELECT COUNT(*) FROM customers;

-- №86 Количество товаров
SELECT COUNT(*) FROM products;

-- №87 Количество заказов
SELECT COUNT(*) FROM orders;

-- №88 Количество поставщиков
SELECT COUNT(*) FROM suppliers;

-- №89 Самый дешевый товар
SELECT MIN(price) FROM products;

-- №90 Самый дорогой товар
SELECT MAX(price) FROM products;

-- №91 Средняя зарплата сотрудников
SELECT AVG(salary) FROM employees;

-- №92 Конкатенация имени клиента
SELECT first_name || ' ' || last_name FROM customers;

-- №93 Длина имени клиента
SELECT first_name, LENGTH(first_name)
FROM customers;

-- №94 Верхний регистр имени
SELECT UPPER(first_name)
FROM customers;

-- №95 Заказы с количеством товаров и суммой
SELECT o.id, SUM(d.quantity) AS quantity_sum, SUM(d.quantity * p.price) AS total_sum
FROM orders o
         JOIN order_details d ON o.id = d.order_id
         JOIN products p ON d.product_id = p.id
GROUP BY o.id
ORDER BY total_sum;

-- №96 Клиенты и их последний заказ
SELECT c.id, MAX(o.date)
FROM customers c
         JOIN orders o ON c.id = o.customer_id
GROUP BY c.id;

-- №97 Поставщики и их самый дорогой товар
SELECT s.company_name, MAX(p.price)
FROM suppliers s
         JOIN products p ON s.id = p.supplier_id
GROUP BY s.company_name;

-- №98 Количество заказов и платежей
SELECT o.id, COUNT(p.id)
FROM orders o
         LEFT JOIN payments p ON o.id = p.order_id
GROUP BY o.id;

-- №99 Заказы с количеством разных товаров
SELECT o.id, COUNT(DISTINCT d.product_id)
FROM orders o
         JOIN order_details d ON o.id = d.order_id
GROUP BY o.id;

-- №100 Топ 3 клиента по сумме заказов
SELECT c.id, c.first_name,  SUM(p.amount)
FROM customers c
         JOIN orders o ON c.id = o.customer_id
         JOIN payments p ON o.id = p.order_id
GROUP BY c.id
ORDER BY SUM(p.amount) DESC
LIMIT 3;

-- №101
SELECT DISTINCT p.category_id
FROM products p;
-- №102
SELECT DISTINCT o.customer_id
FROM orders o;

--№103 Natural Join
SELECT *
FROM orders
NATURAL JOIN customers;

--№104 many to many
SELECT o.id, p.name
FROM orders o
JOIN order_details d
ON o.id = d.order_id
JOIN products p
ON d.product_id = p.id;


-- №105 Количество заказов по клиентам

WITH order_counts AS (
    SELECT customer_id, COUNT(*) AS total_orders
    FROM orders
    GROUP BY customer_id
)
SELECT *
FROM order_counts
WHERE total_orders > 1;

--Топ клиентов по сумме покупок
WITH customer_spending AS (
    SELECT o.customer_id, SUM(p.amount) AS total_spent
    FROM orders o
             JOIN payments p ON o.id = p.order_id
    GROUP BY o.customer_id
)
SELECT *
FROM customer_spending
ORDER BY total_spent DESC
LIMIT 100;


CREATE TABLE old_categories
(
    id          SERIAL PRIMARY KEY,
    name        VARCHAR,
    description VARCHAR
);

INSERT INTO old_categories(name, description) VALUES ('Plastic', 'Plastic materials');

INSERT INTO categories(name, description)
SELECT name, description
FROM old_categories oc;

SELECT string_agg(c.first_name, ',')
FROM customers c;


EXPLAIN
SELECT
    c.id                                        AS customer_id,
    c.first_name || ' ' || c.last_name         AS customer_name,
    COUNT(DISTINCT o.id)                        AS total_orders,
    COUNT(DISTINCT od.product_id)               AS unique_products,
    SUM(p.amount)                               AS total_paid,
    ROUND(AVG(r.rating), 2)                     AS avg_rating
FROM customers c
         JOIN orders o        ON o.customer_id = c.id
         JOIN order_details od ON od.order_id = o.id
         JOIN payments p      ON p.order_id = o.id
         LEFT JOIN reviews r  ON r.customer_id = c.id
WHERE
    o.status = 'completed'
  AND o.date >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY
    c.id, c.first_name, c.last_name
HAVING
    COUNT(DISTINCT o.id) > 3
   AND SUM(p.amount) > 10000
ORDER BY
    total_paid DESC
LIMIT 100;



SELECT
    c.first_name || ' ' || c.last_name          AS customer_name,
    cat.name                                     AS category,
    sup.company_name                             AS supplier,
    COUNT(DISTINCT o.id)                         AS orders_count,
    COUNT(DISTINCT od.product_id)                AS unique_products,
    SUM(od.quantity)                             AS total_quantity,
    SUM(od.quantity * p.price)                   AS total_sum,
    ROUND(AVG(r.rating), 2)                      AS avg_rating,
    MAX(pay.amount)                              AS max_payment,
    MIN(pay.amount)                              AS min_payment,
    COUNT(DISTINCT del.id)                       AS deliveries_count
FROM customers c
         JOIN orders o          ON o.customer_id = c.id
         JOIN order_details od  ON od.order_id = o.id
         JOIN products p        ON p.id = od.product_id
         JOIN categories cat    ON cat.id = p.category_id
         JOIN suppliers sup     ON sup.id = p.supplier_id
         JOIN payments pay      ON pay.order_id = o.id
         JOIN deliveries del    ON del.order_id = o.id
         LEFT JOIN reviews r    ON r.product_id = p.id AND r.customer_id = c.id
WHERE
    o.date BETWEEN CURRENT_DATE - INTERVAL '2 years' AND CURRENT_DATE
  AND p.price > 100
  AND o.status IN ('completed', 'processing')
GROUP BY
    c.id, c.first_name, c.last_name,
    cat.id, cat.name,
    sup.id, sup.company_name
HAVING
    SUM(od.quantity * p.price) > 1000
   AND COUNT(DISTINCT o.id) >= 1
ORDER BY
    total_sum DESC,
    avg_rating DESC NULLS LAST
LIMIT 50;