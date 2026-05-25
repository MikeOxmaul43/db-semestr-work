-- =========================================================
-- 1. Клиенты и суммы оплат
-- =========================================================

EXPLAIN ANALYZE
SELECT c.id, c.first_name, SUM(p.amount)
FROM customers c
         JOIN orders o ON c.id = o.customer_id
         JOIN payments p ON o.id = p.order_id
WHERE o.customer_id = 100
GROUP BY c.id, c.first_name;

CREATE INDEX idx_orders_customer_id
    ON orders(customer_id);

CREATE INDEX idx_payments_order_id
    ON payments(order_id);

DROP INDEX idx_orders_customer_id;
DROP INDEX idx_payments_order_id;


-- =========================================================
-- 2. Сумма заказа по товару
-- =========================================================

EXPLAIN ANALYZE
SELECT o.id, SUM(d.quantity * p.price)
FROM orders o
         JOIN order_details d ON o.id = d.order_id
         JOIN products p ON d.product_id = p.id
WHERE d.product_id = 50
GROUP BY o.id;

CREATE INDEX idx_order_details_product_id
    ON order_details(product_id);

CREATE INDEX idx_order_details_order_id
    ON order_details(order_id);

DROP INDEX idx_order_details_product_id;
DROP INDEX idx_order_details_order_id;


-- =========================================================
-- 3. Клиент, заказы, товары, платежи
-- =========================================================

EXPLAIN ANALYZE
SELECT *
FROM customers c
         JOIN orders o ON c.id = o.customer_id
         JOIN order_details od ON o.id = od.order_id
         JOIN payments p ON o.id = p.order_id
WHERE c.id = 500;

CREATE INDEX idx_orders_customer_id
    ON orders(customer_id);

CREATE INDEX idx_order_details_order_id
    ON order_details(order_id);

CREATE INDEX idx_payment_order_id
    ON payments(order_id);

DROP INDEX idx_orders_customer_id;
DROP INDEX idx_order_details_order_id;
DROP INDEX idx_payment_order_id;


-- =========================================================
-- 4. Большой аналитический запрос
-- =========================================================

EXPLAIN ANALYZE
SELECT
    c.first_name || ' ' || c.last_name     AS customer_name,
    cat.name                               AS category,
    sup.company_name                       AS supplier,
    COUNT(DISTINCT o.id)                   AS orders_count,
    COUNT(DISTINCT od.product_id)          AS unique_products,
    SUM(od.quantity)                       AS total_quantity,
    SUM(od.quantity * p.price)             AS total_sum,
    ROUND(AVG(r.rating), 2)                AS avg_rating,
    MAX(pay.amount)                        AS max_payment,
    MIN(pay.amount)                        AS min_payment,
    COUNT(DISTINCT del.id)                 AS deliveries_count
FROM customers c
         JOIN orders o         ON o.customer_id = c.id
         JOIN order_details od ON od.order_id = o.id
         JOIN products p       ON p.id = od.product_id
         JOIN categories cat   ON cat.id = p.category_id
         JOIN suppliers sup    ON sup.id = p.supplier_id
         JOIN payments pay     ON pay.order_id = o.id
         JOIN deliveries del   ON del.order_id = o.id
         LEFT JOIN reviews r
                   ON r.product_id = p.id
                       AND r.customer_id = c.id
WHERE
    o.date BETWEEN CURRENT_DATE - INTERVAL '2 years' AND CURRENT_DATE
  AND p.price > 100
  AND o.status IN ('completed', 'processing')
GROUP BY
    c.id,
    c.first_name,
    c.last_name,
    cat.id,
    cat.name,
    sup.id,
    sup.company_name
HAVING SUM(od.quantity * p.price) > 1000
ORDER BY total_sum DESC, avg_rating DESC NULLS LAST
LIMIT 50;

CREATE INDEX IF NOT EXISTS idx_orders_status_date
    ON orders(status, date);

CREATE INDEX IF NOT EXISTS idx_orders_customer_id
    ON orders(customer_id);

CREATE INDEX IF NOT EXISTS idx_order_details_order_id
    ON order_details(order_id);

CREATE INDEX IF NOT EXISTS idx_order_details_product_id
    ON order_details(product_id);

CREATE INDEX IF NOT EXISTS idx_payments_order_id
    ON payments(order_id);

CREATE INDEX IF NOT EXISTS idx_deliveries_order_id
    ON deliveries(order_id);

CREATE INDEX IF NOT EXISTS idx_reviews_product_customer
    ON reviews(product_id, customer_id);

CREATE INDEX IF NOT EXISTS idx_products_price
    ON products(price);

CREATE INDEX IF NOT EXISTS idx_products_category_id
    ON products(category_id);

CREATE INDEX IF NOT EXISTS idx_products_supplier_id
    ON products(supplier_id);

DROP INDEX idx_orders_status_date;
DROP INDEX idx_orders_customer_id;
DROP INDEX idx_order_details_order_id;
DROP INDEX idx_order_details_product_id;
DROP INDEX idx_payments_order_id;
DROP INDEX idx_deliveries_order_id;
DROP INDEX idx_reviews_product_customer;
DROP INDEX idx_products_price;
DROP INDEX idx_products_category_id;
DROP INDEX idx_products_supplier_id;


-- =========================================================
-- 5. Заказы клиента за последний месяц
-- =========================================================

EXPLAIN ANALYZE
SELECT
    o.id,
    o.date,
    o.status,
    p.amount,
    p.payment_method
FROM orders o
         JOIN payments p
              ON p.order_id = o.id
WHERE
    o.customer_id = 500
  AND o.date >= CURRENT_DATE - INTERVAL '1 month'
ORDER BY o.date DESC;

CREATE INDEX idx_orders_customer_date
    ON orders(customer_id, date);

CREATE INDEX idx_payments_order_id
    ON payments(order_id);

DROP INDEX idx_orders_customer_date;
DROP INDEX idx_payments_order_id;


--Процедуры

CREATE OR REPLACE PROCEDURE place_order(
    p_customer_id INT,
    p_employee_id INT,
    p_product_id  INT,
    p_quantity    INT
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_order_id   INT;
    v_stock      INT;
    v_price      NUMERIC(10,2);
BEGIN
    -- Проверяем остаток на складе
    SELECT quantity INTO v_stock
    FROM storages
    WHERE product_id = p_product_id;

    IF v_stock IS NULL THEN
        RAISE EXCEPTION 'Товар с id % не найден на складе', p_product_id;
    END IF;

    IF v_stock < p_quantity THEN
        RAISE EXCEPTION 'Недостаточно товара на складе. Доступно: %', v_stock;
    END IF;

    INSERT INTO orders (status, employee_id, customer_id)
    VALUES ('new', p_employee_id, p_customer_id)
    RETURNING id INTO v_order_id;

    INSERT INTO order_details (order_id, product_id, quantity)
    VALUES (v_order_id, p_product_id, p_quantity);

    UPDATE storages
    SET quantity = quantity - p_quantity
    WHERE product_id = p_product_id;

    RAISE NOTICE 'Заказ % успешно создан', v_order_id;
END;
$$;

-- Вызов:
CALL place_order(1, 1, 1, 3);


CREATE OR REPLACE PROCEDURE update_order_status(
    p_order_id  INT,
    p_new_status VARCHAR
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_current_status VARCHAR;
    v_allowed        BOOLEAN := FALSE;
BEGIN
    SELECT status INTO v_current_status
    FROM orders
    WHERE id = p_order_id;

    IF v_current_status IS NULL THEN
        RAISE EXCEPTION 'Заказ с id % не найден', p_order_id;
    END IF;

    v_allowed := CASE v_current_status
                     WHEN 'new'        THEN p_new_status IN ('processing', 'cancelled')
                     WHEN 'processing' THEN p_new_status IN ('delivered', 'cancelled')
                     WHEN 'delivered'  THEN p_new_status IN ('completed')
                     ELSE FALSE
        END;

    IF NOT v_allowed THEN
        RAISE EXCEPTION 'Недопустимый переход статуса: % → %',
            v_current_status, p_new_status;
    END IF;

    UPDATE orders
    SET status = p_new_status
    WHERE id = p_order_id;

    RAISE NOTICE 'Статус заказа % изменён: % → %',
        p_order_id, v_current_status, p_new_status;
END;
$$;

SELECT * FROM orders
    WHERE id = 101011;
CALL update_order_status(101011, 'delivered');
SELECT * FROM orders
WHERE id = 101010;

CREATE OR REPLACE PROCEDURE restock_product(
    p_product_id INT,
    p_quantity   INT
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_exists  INT;
    v_new_qty INT;
BEGIN
    IF p_quantity <= 0 THEN
        RAISE EXCEPTION 'Количество должно быть положительным';
    END IF;

    SELECT COUNT(*) INTO v_exists
    FROM storages
    WHERE product_id = p_product_id;

    IF v_exists = 0 THEN
        INSERT INTO storages (product_id, quantity, updated_at)
        VALUES (p_product_id, p_quantity, CURRENT_TIMESTAMP);

        v_new_qty := p_quantity;
        RAISE NOTICE 'Создана новая запись склада. Количество: %', v_new_qty;
    ELSE
        UPDATE storages
        SET quantity = quantity + p_quantity,
        updated_at = CURRENT_TIMESTAMP
        WHERE product_id = p_product_id
        RETURNING quantity INTO v_new_qty;

        RAISE NOTICE 'Склад пополнен. Новый остаток: %', v_new_qty;
    END IF;
END;
$$;

SELECT *
    FROM storages
        WHERE product_id = 1;
CALL restock_product(1, 100);
SELECT *
FROM storages
WHERE product_id = 1;

--Функции
CREATE OR REPLACE FUNCTION get_customer_total(
    p_customer_id INT
)
    RETURNS NUMERIC
    LANGUAGE plpgsql
AS $$
DECLARE
    v_total NUMERIC(10,2);
BEGIN
    SELECT COALESCE(SUM(p.amount), 0) INTO v_total
    FROM orders o
             JOIN payments p ON o.id = p.order_id
    WHERE o.customer_id = p_customer_id;

    RETURN v_total;
END;
$$;

SELECT get_customer_total(555);



CREATE OR REPLACE FUNCTION get_customer_category(
    p_customer_id INT
)
    RETURNS VARCHAR
    LANGUAGE plpgsql
AS $$
DECLARE
    v_total    NUMERIC(10,2);
    v_category VARCHAR;
BEGIN
    v_total := get_customer_total(p_customer_id);

    IF v_total >= 50000 THEN
        v_category := 'VIP';
    ELSIF v_total >= 10000 THEN
        v_category := 'Regular';
    ELSIF v_total > 0 THEN
        v_category := 'New';
    ELSE
        v_category := 'No orders';
    END IF;

    RETURN v_category;
END;
$$;

SELECT id, first_name, get_customer_category(id) AS category
FROM customers;


CREATE OR REPLACE FUNCTION get_order_summary(
    p_order_id INT
)
    RETURNS TEXT
    LANGUAGE plpgsql
AS $$
DECLARE
    v_status     VARCHAR;
    v_total      NUMERIC(10,2) := 0;
    v_item_count INT := 0;
    v_row        RECORD;
    v_result     TEXT;
BEGIN
    SELECT status INTO v_status
    FROM orders WHERE id = p_order_id;

    IF v_status IS NULL THEN
        RETURN 'Заказ не найден';
    END IF;

    FOR v_row IN
        SELECT od.quantity, p.price
        FROM order_details od
                 JOIN products p ON od.product_id = p.id
        WHERE od.order_id = p_order_id
        LOOP
            v_total      := v_total + (v_row.quantity * v_row.price);
            v_item_count := v_item_count + 1;
        END LOOP;

    v_result := format(
            'Заказ #%s | Статус: %s | Позиций: %s | Сумма: %s руб.',
            p_order_id, v_status, v_item_count, v_total
                );

    RETURN v_result;
END;
$$;

SELECT get_order_summary(552);

--Views
CREATE OR REPLACE VIEW view_active_orders AS
SELECT
    o.id           AS order_id,
    o.date,
    o.status,
    c.first_name || ' ' || c.last_name  AS customer_name,
    c.phone_number                       AS customer_phone,
    e.first_name || ' ' || e.last_name  AS employee_name
FROM orders o
         JOIN customers c ON o.customer_id = c.id
         LEFT JOIN employees e ON o.employee_id = e.id
WHERE o.status NOT IN ('completed', 'cancelled');

SELECT * FROM view_active_orders;



CREATE OR REPLACE VIEW view_stock AS
SELECT
    p.id           AS product_id,
    p.name         AS product_name,
    p.price,
    c.name         AS category,
    s.company_name AS supplier,
    st.quantity    AS stock_quantity
FROM products p
         JOIN categories c  ON p.category_id = c.id
         JOIN suppliers s   ON p.supplier_id = s.id
         JOIN storages st   ON p.id = st.product_id
ORDER BY st.quantity;

SELECT * FROM view_stock;

SELECT * FROM view_stock WHERE stock_quantity = 0;


CREATE OR REPLACE VIEW view_customer_stats AS
SELECT
    c.id,
    c.first_name || ' ' || c.last_name  AS customer_name,
    c.email,
    COUNT(DISTINCT o.id)                AS orders_count,
    COALESCE(SUM(p.amount), 0)          AS total_spent,
    get_customer_category(c.id)         AS category
FROM customers c
         LEFT JOIN orders o    ON c.id = o.customer_id
         LEFT JOIN payments p  ON o.id = p.order_id
GROUP BY c.id, c.first_name, c.last_name, c.email
ORDER BY total_spent DESC;

SELECT * FROM view_customer_stats;

SELECT * FROM view_customer_stats WHERE category = 'VIP';


CREATE OR REPLACE FUNCTION trg_decrease_stock()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
DECLARE
    v_stock INT;
BEGIN
    SELECT quantity INTO v_stock
    FROM storages
    WHERE product_id = NEW.product_id;

    IF v_stock IS NULL THEN
        RAISE EXCEPTION 'Товар id=% отсутствует на складе', NEW.product_id;
    END IF;

    IF v_stock < NEW.quantity THEN
        RAISE EXCEPTION
            'Недостаточно товара id=% на складе. Доступно: %, запрошено: %',
            NEW.product_id, v_stock, NEW.quantity;
    END IF;

    UPDATE storages
    SET quantity   = quantity - NEW.quantity,
        updated_at = CURRENT_TIMESTAMP
    WHERE product_id = NEW.product_id;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_order_details_insert
    BEFORE INSERT ON order_details
    FOR EACH ROW
EXECUTE FUNCTION trg_decrease_stock();

INSERT INTO orders (
    status,
    employee_id,
    customer_id
)
VALUES (
           'new',
           1,
           1
       )
RETURNING id;


SELECT product_id, quantity, updated_at
FROM storages
WHERE product_id = 2;

INSERT INTO order_details (
    order_id,
    product_id,
    quantity
)
VALUES (
           119937,
           2,
           100
       );

SELECT product_id, quantity, updated_at
FROM storages
WHERE product_id = 2;
