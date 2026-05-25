CREATE DATABASE library;

CREATE TABLE author (
    id      SERIAL PRIMARY KEY,
    name    VARCHAR,
    country VARCHAR
);

CREATE TABLE storage_location (
    id             SERIAL PRIMARY KEY,
    cabinet_number INTEGER,
    shelf_number   INTEGER,
    room_number    INTEGER
);

CREATE TABLE publisher (
    id           SERIAL PRIMARY KEY,
    name         VARCHAR,
    email        VARCHAR,
    phone_number VARCHAR,
    address      TEXT
);

CREATE TABLE book (
    id                  SERIAL PRIMARY KEY,
    name                VARCHAR,
    publishing_date     DATE,
    copies_count        INTEGER,
    ISBN                VARCHAR,
    publisher_id        INTEGER REFERENCES publisher(id),
    storage_location_id INTEGER REFERENCES storage_location(id)
);

CREATE TABLE writed_by (
    author_id       INTEGER REFERENCES author(id),
    book_id         INTEGER REFERENCES book(id),
    date_of_writing DATE
);

CREATE TABLE student (
    id           SERIAL PRIMARY KEY,
    name         VARCHAR,
    class        INTEGER,
    phone_number VARCHAR,
    fines_count  INTEGER
);

CREATE TABLE librarian (
    id           SERIAL PRIMARY KEY,
    name         VARCHAR,
    phone_number VARCHAR,
    email        VARCHAR
);

CREATE TABLE book_delivery (
    id            SERIAL PRIMARY KEY,
    delivery_date DATE,
    supplier      VARCHAR,
    is_delivered  BOOLEAN,
    librarian_id  INTEGER REFERENCES librarian(id)
);

CREATE TABLE fine (
    id        SERIAL PRIMARY KEY,
    reason    TEXT,
    sanction  TEXT,
    fine_date DATE,
    is_valid  BOOLEAN
);

CREATE TABLE loan (
    id          SERIAL PRIMARY KEY,
    issue_date  DATE,
    return_date DATE
);

CREATE TABLE reservation (
    id         SERIAL PRIMARY KEY,
    start_date DATE,
    end_date   DATE
);

CREATE TABLE imposition_of_fine (
    fine_id      INTEGER REFERENCES fine(id),
    librarian_id INTEGER REFERENCES librarian(id),
    student_id   INTEGER REFERENCES student(id)
);

CREATE TABLE lending (
    loan_id      INTEGER REFERENCES loan(id),
    librarian_id INTEGER REFERENCES librarian(id),
    student_id   INTEGER REFERENCES student(id)
);

CREATE TABLE booking (
    reservation_id INTEGER REFERENCES reservation(id),
    librarian_id   INTEGER REFERENCES librarian(id),
    student_id     INTEGER REFERENCES student(id)
);

CREATE TABLE fine_for_book (
    fine_id INTEGER REFERENCES fine(id),
    book_id INTEGER REFERENCES book(id),
    count   INTEGER
);

CREATE TABLE loan_for_book (
    loan_id INTEGER REFERENCES loan(id),
    book_id INTEGER REFERENCES book(id),
    count   INTEGER
);

CREATE TABLE reservation_for_book (
    reservation_id INTEGER REFERENCES reservation(id),
    book_id        INTEGER REFERENCES book(id),
    count          INTEGER
);

CREATE TABLE delivery_for_book (
    delivery_id INTEGER REFERENCES book_delivery(id),
    book_id     INTEGER REFERENCES book(id),
    count       INTEGER
);


INSERT INTO author (name, country)
VALUES ('Лев Толстой', 'Россия');

INSERT INTO storage_location (cabinet_number, shelf_number, room_number)
VALUES (3, 2, 1);

INSERT INTO publisher (name, email, phone_number, address)
VALUES ('Эксмо', 'info@eksmo.ru', '+74951234567', 'Москва, ул. Лесная, 5');

INSERT INTO book (name, publishing_date, copies_count, ISBN, publisher_id, storage_location_id)
VALUES ('Война и мир', '1869-01-01', 5, '978-5-04-101234-5', 1, 1);

INSERT INTO writed_by (author_id, book_id, date_of_writing)
VALUES (1, 1, '1863-01-01');

INSERT INTO student (name, class, phone_number, fines_count)
VALUES ('Иванов Иван', 10, '+79161234567', 0);

INSERT INTO librarian (name, phone_number, email)
VALUES ('Петрова Мария', '+79031234567', 'petrova@library.ru');

INSERT INTO fine (reason, sanction, fine_date, is_valid)
VALUES ('Просрочка возврата', 'Предупреждение', '2024-03-15', TRUE);

INSERT INTO loan (issue_date, return_date)
VALUES ('2024-03-01', '2024-03-15');

INSERT INTO loan_for_book (loan_id, book_id, count)
VALUES (1, 1, 1);


ALTER TABLE author
    ADD COLUMN birth_date DATE;

ALTER TABLE student
    ADD COLUMN patronymic VARCHAR;

ALTER TABLE fine
    ADD COLUMN note TEXT;

ALTER TABLE student
    ALTER COLUMN class TYPE VARCHAR USING class::VARCHAR;

ALTER TABLE student
    DROP COLUMN patronymic;

ALTER TABLE book
    ALTER COLUMN copies_count SET DEFAULT 1;

ALTER TABLE booking
    ADD CONSTRAINT fk_booking_student
    FOREIGN KEY (student_id) REFERENCES student(id);

ALTER TABLE imposition_of_fine
    ADD CONSTRAINT fk_imposition_fine
    FOREIGN KEY (fine_id) REFERENCES fine(id);

ALTER TABLE booking
    DROP CONSTRAINT fk_booking_student;

ALTER TABLE booking
    ADD CONSTRAINT fk_booking_student
    FOREIGN KEY (student_id) REFERENCES student(id) ON DELETE CASCADE;

ALTER TABLE imposition_of_fine
    DROP CONSTRAINT fk_imposition_fine;

ALTER TABLE writed_by
    ADD CONSTRAINT pk_writed_by PRIMARY KEY (author_id, book_id);

ALTER TABLE writed_by
    DROP CONSTRAINT pk_writed_by;

ALTER TABLE writed_by
    ADD COLUMN id SERIAL PRIMARY KEY;

ALTER TABLE book
    ADD CONSTRAINT uq_book_isbn UNIQUE (ISBN);

ALTER TABLE book
    ADD CONSTRAINT chk_copies_count CHECK (copies_count >= 0);

ALTER TABLE book
    DROP CONSTRAINT chk_copies_count;


ALTER TABLE writed_by
    RENAME TO authored_by;

ALTER TABLE publisher
    RENAME COLUMN address TO full_address;

ALTER TABLE student
    RENAME COLUMN name TO full_name;

DROP TABLE IF EXISTS delivery_for_book;
DROP TABLE IF EXISTS reservation_for_book;
DROP TABLE IF EXISTS loan_for_book;
DROP TABLE IF EXISTS fine_for_book;
DROP TABLE IF EXISTS booking;
DROP TABLE IF EXISTS lending;
DROP TABLE IF EXISTS imposition_of_fine;
DROP TABLE IF EXISTS reservation;
DROP TABLE IF EXISTS loan;
DROP TABLE IF EXISTS fine;
DROP TABLE IF EXISTS book_delivery;
DROP TABLE IF EXISTS writed_by;
DROP TABLE IF EXISTS book;
DROP TABLE IF EXISTS publisher;
DROP TABLE IF EXISTS storage_location;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS librarian;
DROP TABLE IF EXISTS author;
    
DROP DATABASE IF EXISTS library;


INSERT INTO fine(reason, sanction, fine_date, is_valid, note)
VALUES ('Просрочка возврата', 'Запрет на выдачу', '2025-01-01', true, '...');

UPDATE fine
SET sanction = 'Предупреждение'
WHERE id = 2;

ALTER TABLE fine
    DROP COLUMN note;

DELETE FROM fine WHERE id = 1;