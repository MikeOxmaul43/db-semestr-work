CREATE DATABASE shop_db;

CREATE TABLE supplier (
                          id SERIAL PRIMARY KEY,
                          company_name VARCHAR(150) NOT NULL,
                          contact_person VARCHAR(100),
                          email VARCHAR(100) UNIQUE,
                          phone_number VARCHAR(20),
                          address TEXT
);
CREATE TABLE category (
                          id SERIAL PRIMARY KEY,
                          name VARCHAR(100) NOT NULL,
                          description TEXT
);


CREATE TABLE product (
                         id SERIAL PRIMARY KEY,
                         name VARCHAR(150) NOT NULL,
                         unit VARCHAR(50),
                         description TEXT,
                         price NUMERIC(10, 2) NOT NULL CHECK ( price >= 0 ),
                         category_id INTEGER REFERENCES category(id),
                         supplier_id INTEGER UNIQUE REFERENCES supplier(id)
);

CREATE TABLE storage (
                         id SERIAL PRIMARY KEY ,
                         product_id INTEGER UNIQUE REFERENCES product(id) ON DELETE CASCADE ,
                         quantity INTEGER NOT NULL CHECK ( quantity >= 0 ),
                         updated_at timestamp DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE customer (
                          id SERIAL PRIMARY KEY ,
                          first_name VARCHAR(100) NOT NULL ,
                          last_name VARCHAR(100) NOT NULL,
                          address TEXT,
                          email VARCHAR(100) UNIQUE ,
                          phone_number VARCHAR(20)
);

CREATE TABLE employee (
                          id SERIAL PRIMARY KEY ,
                          first_name VARCHAR(100) NOT NULL ,
                          last_name VARCHAR(100) NOT NULL,
                          phone_number VARCHAR(20),
                          salary INTEGER NOT NULL CHECK ( salary >= 0 )
);

CREATE TABLE "order" (
                         id SERIAL PRIMARY KEY ,
                         status VARCHAR(30),
                         date date default CURRENT_DATE,
                         employee_id INTEGER REFERENCES employee(id),
                         customer_id INTEGER REFERENCES customer(id)
);

CREATE TABLE order_detail (
                              order_id INTEGER REFERENCES "order"(id) ON DELETE CASCADE ,
                              product_id INTEGER REFERENCES product(id),
                              quantity INTEGER NOT NULL CHECK ( quantity > 0 ),
                              PRIMARY KEY (order_id, product_id)
);

CREATE TABLE payment(
                        id SERIAL PRIMARY KEY ,
                        date DATE DEFAULT CURRENT_DATE,
                        amount NUMERIC(10, 2) NOT NULL CHECK ( amount >= 0 ),
                        payment_method VARCHAR(50),
                        order_id INTEGER REFERENCES "order"(id) ON DELETE CASCADE
);

CREATE TABLE delivery (
                          id SERIAL PRIMARY KEY ,
                          courier_name VARCHAR(20) NOT NULL ,
                          comment TEXT,
                          expected_time TIMESTAMP,
                          real_time TIMESTAMP,
                          courier_phone_number VARCHAR(20),
                          order_id INTEGER REFERENCES "order"(id) ON DELETE CASCADE
);

CREATE TABLE review(
    id SERIAL PRIMARY KEY ,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    customer_id INTEGER REFERENCES customer(id) ON DELETE CASCADE ,
    product_id INTEGER REFERENCES product(id) ON DELETE CASCADE
)
