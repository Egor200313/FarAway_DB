-- 1. Создаем таблицы

CREATE schema faraway;

CREATE TABLE faraway.airport (
    name VARCHAR(3) PRIMARY KEY CHECK ( name SIMILAR TO '[A-Z][A-Z][A-Z]' ),
    city VARCHAR(20) NOT NULL,
    country VARCHAR(20) NOT NULL
);

CREATE TABLE faraway.aircraft (
    aircraftid INTEGER PRIMARY KEY,
    model VARCHAR(20) NOT NULL,
    company VARCHAR(20) NOT NULL
);

CREATE TABLE faraway.route (
    routeid INTEGER PRIMARY KEY,
    origin VARCHAR(3),
    CONSTRAINT origin_fk FOREIGN KEY (origin) REFERENCES faraway.airport(name) ON DELETE CASCADE,
    destination VARCHAR(3),
    CONSTRAINT dest_fk FOREIGN KEY (destination) REFERENCES faraway.airport(name) ON DELETE CASCADE,
    price FLOAT CHECK ( price > 0 ),
    duration FLOAT CHECK ( duration > 0 )
);

CREATE TABLE faraway.flight (
    flightid INTEGER PRIMARY KEY,
    routeid INTEGER,
    CONSTRAINT route_fk FOREIGN KEY(routeid) REFERENCES faraway.route(routeid) ON DELETE CASCADE,
    deptime TIMESTAMP NOT NULL,
    aircraftid INTEGER,
    CONSTRAINT aircraft_fk FOREIGN KEY (aircraftid) REFERENCES faraway.aircraft(aircraftid) ON DELETE CASCADE,
    totalTickets INTEGER CHECK ( totalTickets >= 0 ),
    avTickets INTEGER CHECK ( avTickets <= faraway.flight.totalTickets )
);

CREATE TABLE faraway.customer (
    email VARCHAR(30) PRIMARY KEY CHECK ( email LIKE '%_@__%.__%' ),
    passwordHash VARCHAR(60) NOT NULL,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30),
    isAdmin BOOLEAN NOT NULL
);

CREATE TABLE faraway.ticket (
    ticketid INTEGER PRIMARY KEY,
    flightid INTEGER,
    CONSTRAINT flight_fk FOREIGN KEY (flightid) REFERENCES faraway.flight(flightid) ON DELETE CASCADE,
    owner VARCHAR(30),
    CONSTRAINT owner_fk FOREIGN KEY (owner) REFERENCES faraway.customer(email) ON DELETE CASCADE
);

-- 2. Заполняем таблицы
-- Пусть для простоты пароль у всех пользователей "abcd"
-- и его хэш $2a$14$qDPyvx.k77WZX3/rXNKXJ.0iZVRlHsSQ3dSVMOPmlZRyhqd12KUp2
INSERT INTO faraway.customer VALUES
('john@gmail.com', '$2a$14$qDPyvx.k77WZX3/rXNKXJ.0iZVRlHsSQ3dSVMOPmlZRyhqd12KUp2', 'John', 'Doe', false),
('bob@gmail.com', '$2a$14$qDPyvx.k77WZX3/rXNKXJ.0iZVRlHsSQ3dSVMOPmlZRyhqd12KUp2', 'Bob', 'Chan', false),
('alex@gmail.com', '$2a$14$qDPyvx.k77WZX3/rXNKXJ.0iZVRlHsSQ3dSVMOPmlZRyhqd12KUp2', 'Alex', 'Brown', false),
('bill@gmail.com', '$2a$14$qDPyvx.k77WZX3/rXNKXJ.0iZVRlHsSQ3dSVMOPmlZRyhqd12KUp2', 'Bill', 'Watson', false),
('steve@gmail.com', '$2a$14$qDPyvx.k77WZX3/rXNKXJ.0iZVRlHsSQ3dSVMOPmlZRyhqd12KUp2', 'Steve', 'Rogers', false),
('mark@gmail.com', '$2a$14$qDPyvx.k77WZX3/rXNKXJ.0iZVRlHsSQ3dSVMOPmlZRyhqd12KUp2', 'Mark', 'White', false),
('alice@gmail.com', '$2a$14$qDPyvx.k77WZX3/rXNKXJ.0iZVRlHsSQ3dSVMOPmlZRyhqd12KUp2', 'Alice', 'Snow', false),
('eva@gmail.com', '$2a$14$qDPyvx.k77WZX3/rXNKXJ.0iZVRlHsSQ3dSVMOPmlZRyhqd12KUp2', 'Eva', 'Black', false),
('ivan@gmail.com', '$2a$14$qDPyvx.k77WZX3/rXNKXJ.0iZVRlHsSQ3dSVMOPmlZRyhqd12KUp2', 'Ivan', 'Petrov', false),
('peter@gmail.com', '$2a$14$qDPyvx.k77WZX3/rXNKXJ.0iZVRlHsSQ3dSVMOPmlZRyhqd12KUp2', 'Peter', 'Ivanov', false),
('admin@gmail.com', '$2a$14$qDPyvx.k77WZX3/rXNKXJ.0iZVRlHsSQ3dSVMOPmlZRyhqd12KUp2', 'Arthur', 'Brown', true)
;

INSERT INTO faraway.airport VALUES ('JFK', 'New York', 'USA'),
                                   ('SWE', 'Moscow', 'Russia'),
                                   ('LAX', 'Los Angeles', 'USA'),
                                   ('YVR', 'Vancouver', 'Canada'),
                                   ('DME', 'Moscow', 'Russia'),
                                   ('DXB', 'Dubai', 'UAE'),
                                   ('LIS', 'Lisbon', 'Portugal'),
                                   ('LHR', 'London', 'UK'),
                                   ('CDG', 'Paris', 'France'),
                                   ('MEL', 'Melbourne', 'Australia'),
                                   ('AKL', 'Auckland', 'New Zealand'),
                                   ('SIN', 'Singapore', 'Singapore');

INSERT INTO faraway.route VALUES (1, 'SWE', 'JFK', 1000.0, 10.25),
                                 (2, 'JFK', 'LAX', 6500.0, 6.5),
                                 (3, 'JFK', 'YVR', 5000.0, 5.2),
                                 (4, 'YVR', 'CDG', 1000.0, 10.2),
                                 (5, 'DXB', 'DME', 5300.0, 5.3),
                                 (6, 'SWE', 'CDG', 3500.0, 3.75),
                                 (7, 'CDG', 'LIS', 2500.0, 2.3),
                                 (8, 'LHR', 'DXB', 7200.0, 7.0),
                                 (9, 'YVR', 'LAX', 3000.0, 2.75),
                                 (10, 'CDG', 'LIS', 2400.0, 2.3),
                                 (11, 'DXB', 'SIN', 7600.0, 7.5),
                                 (12, 'SIN', 'MEL', 8000.0, 7.6),
                                 (13, 'MEL', 'AKL', 3500.0, 4.0),
                                 (14, 'DME', 'LHR', 4300.0, 4.25);

INSERT INTO faraway.aircraft VALUES (1111, 'A330', 'Airbus'),
                                    (1212, 'A380', 'Airbus'),
                                    (3151, 'A320', 'Airbus'),
                                    (7654, '777', 'Boeing'),
                                    (1234, '747', 'Boeing'),
                                    (4444, '787', 'Boeing');

INSERT INTO faraway.flight VALUES (1, 6, '2022-09-16 15:06:00', 1111, 150, 147),
                                  (2, 10, '2022-09-10 19:19:00', 4444, 180, 180),
                                  (3, 8, '2022-10-13 22:03:00', 3151, 210, 209),
                                  (4, 2, '2022-08-24 22:51:00', 1212, 140, 139),
                                  (5, 13, '2021-12-20 14:16:00', 4444, 100, 98),
                                  (6, 12, '2021-08-16 06:41:00', 1111, 220, 219),
                                  (7, 5, '2022-01-16 16:33:00', 3151, 215, 214),
                                  (8, 1, '2021-09-02 12:53:00', 1234, 190, 188),
                                  (9, 9, '2022-05-02 07:36:00', 1111, 175, 174);

INSERT INTO faraway.ticket VALUES (1, 5, 'alex@gmail.com'),
                                  (2, 5, 'ivan@gmail.com'),
                                  (3, 1, 'ivan@gmail.com'),
                                  (4, 8, 'bill@gmail.com'),
                                  (5, 8, 'alice@gmail.com'),
                                  (6, 1, 'bob@gmail.com'),
                                  (7, 6, 'alex@gmail.com'),
                                  (8, 7, 'bill@gmail.com'),
                                  (9, 1, 'alice@gmail.com'),
                                  (10, 3, 'peter@gmail.com'),
                                  (11, 4, 'alex@gmail.com'),
                                  (12, 9, 'peter@gmail.com');

-- 3. UPDATE, DELETE запросы

-- Ошиблись с ценами, исправляем
UPDATE faraway.route SET price = price / 10
WHERE price > 1000.0;

-- Рейс 9 отменен
DELETE FROM faraway.ticket WHERE flightid = 9;

-- Alice сдает свои билеты
DELETE FROM faraway.ticket WHERE owner = 'alice@gmail.com';

-- Добавим доступых билетов на рейсы от которых отказалась Alice
UPDATE faraway.flight SET avTickets = avTickets + 1
WHERE flightid IN (
    SELECT flightid
    FROM faraway.ticket
    WHERE owner = 'alice@gmail.com'
);

-- Сдвигаем время вылета всех рейсов с 24 августа
UPDATE faraway.flight SET deptime = deptime + INTERVAL '1 hour'
WHERE deptime > '2022-08-24 22:51:00';

-- Зарегистрировался новый пользователь
INSERT INTO faraway.customer
VALUES ('clark@yahoo.com', '$2a$14$qDPyvx.k77WZX3/rXNKXJ.0iZVRlHsSQ3dSVMOPmlZRyhqd12KUp2', 'Clark', NULL, false);

-- Купил билет New York - Los Angeles
INSERT INTO faraway.ticket VALUES (13, 4, 'clark@yahoo.com');

-- Уменьшим число доступных билетов на этот рейс
UPDATE faraway.flight SET avTickets = avTickets - 1
WHERE flightid = 10;

-- Полеты из России в Великобританию отменяются все
DELETE FROM faraway.route
WHERE origin IN (
    SELECT name
    FROM faraway.airport
    WHERE country = 'Russia'
) AND destination IN (
    SELECT name
    FROM faraway.airport
    WHERE country = 'UK'
);

-- Добавим аэропорт Барселоны
INSERT INTO faraway.airport VALUES ('BCN', 'Barcelona', 'Spain');


-- 5. Индексы


-- 6. VIEW


-- 7. Procedures


-- 8. Triggers




