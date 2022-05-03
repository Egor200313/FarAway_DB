-- 4. SELECT запросы

-- Куда и за сколько пересадок можно добраться из Дубая менее, чем за 5 пересадок
WITH RECURSIVE bfs(current_port, dest_port, len) AS (
    SELECT origin, destination, 0
    FROM faraway.route
    WHERE origin = 'DXB'
    UNION ALL
    SELECT origin, destination, len + 1
    FROM faraway.route, bfs
    WHERE origin = dest_port AND len < 5
)
SELECT city, min(t.transits) FROM (
    SELECT dest_port, city, min(len) AS transits
    FROM bfs INNER JOIN faraway.airport on dest_port = name
    WHERE dest_port <> 'DXB'
    GROUP BY dest_port, city
    ORDER BY min(len)
) as t
GROUP BY city
ORDER BY min(t.transits);

-- Аэропорты по количеству прямых маршрутов
SELECT airport, city, count(airport) FROM (
    SELECT origin as airport from faraway.route
    UNION ALL
    SELECT destination as airport from faraway.route
) as t
INNER JOIN faraway.airport ON name = airport
GROUP BY airport, city
ORDER BY count(airport) DESC;

-- Сколько каждый пассажир потратил суммарно денег на перелеты
SELECT first_name as name, last_name as surname, sum(price) as total FROM
faraway.ticket
INNER JOIN faraway.customer ON owner = customer.email
INNER JOIN faraway.flight USING (flightid)
INNER JOIN faraway.route USING (routeid)
GROUP BY (owner, first_name, last_name);

-- Куда и за какую суммарную стоимость можно добраться из России не более чем за 5 пересадок
WITH RECURSIVE bfs(current_port, dest_port, total_cost, len) AS (
    SELECT origin, destination, CAST(0 AS FLOAT), 0
    FROM faraway.route INNER JOIN faraway.airport on origin = name
    WHERE country = 'Russia'
    UNION ALL
    SELECT origin, destination, total_cost + price, len + 1
    FROM faraway.route, bfs
    WHERE origin = dest_port AND len < 5
)
SELECT city, min(t.total) total_cost FROM (
    SELECT dest_port, city, min(total_cost) AS total
    FROM bfs INNER JOIN faraway.airport on dest_port = name
    WHERE dest_port NOT IN (
        SELECT name from faraway.airport
        WHERE country = 'Russia'
    )
    GROUP BY dest_port, city
    ORDER BY min(total_cost)
) as t
WHERE total > 0
GROUP BY city
ORDER BY min(t.total);

-- Сколько всего билетов куплено на каждое направление (A->B и B->A одно и то же)
SELECT af.city as A, at.city as B, sum(tickets) sold_tickets FROM (
    SELECT origin as port_from,
           destination as port_to,
           CASE WHEN NOT flightid IS NULL THEN totaltickets - flight.avtickets
           ELSE 0
           END tickets
    FROM faraway.route LEFT JOIN faraway.flight USING (routeid)
    WHERE origin < route.destination
    UNION ALL
    SELECT origin as port_from,
           destination as port_to,
           CASE WHEN NOT flightid IS NULL THEN totaltickets - flight.avtickets
           ELSE 0
           END tickets
    FROM faraway.route LEFT JOIN faraway.flight USING (routeid)
    WHERE origin > route.destination
) as t
INNER JOIN faraway.airport af ON port_from = af.name
INNER JOIN faraway.airport at ON port_to = at.name
GROUP BY af.city, at.city;

-- История перелетов Alex Brown
SELECT af.city city_from, at.city city_to, deptime::date as trip_date FROM (
    SELECT origin, destination, deptime
    FROM faraway.ticket INNER JOIN faraway.flight USING (flightid)
    INNER JOIN faraway.route USING (routeid)
    WHERE owner = (
        SELECT email FROM faraway.customer
        WHERE first_name = 'Alex' AND last_name = 'Brown'
        )
) as t
INNER JOIN faraway.airport af ON origin = af.name
INNER JOIN faraway.airport at ON destination = at.name
ORDER BY deptime DESC;

-- Считаем для аэропортов число исходящих маршрутов
SELECT DISTINCT origin, city, count(destination) OVER (PARTITION BY origin)
FROM faraway.route INNER JOIN faraway.airport ON name=route.origin;

-- Ранжируем маршруты по стране прибытия, выводим город вылета, город прилета и
-- ранк маршрута без разрыва в нумерации при однаковых странах прилета
SELECT DISTINCT af.city city_from, at.city city_to, dense_rank() OVER (ORDER BY at.country) rank
FROM faraway.route INNER JOIN faraway.airport af on origin=af.name
INNER JOIN faraway.airport at on destination=at.name
ORDER BY rank;