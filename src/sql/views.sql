-- Представление с расширенной информацией о проданных билетах для удобной работы
CREATE VIEW faraway.tickets_overview AS
    SELECT ticketid, owner, origin, destination, deptime, price
    FROM faraway.ticket INNER JOIN faraway.flight USING (flightid)
    INNER JOIN faraway.route USING (routeid);

-- Число продаж по месяцам
CREATE VIEW faraway.month_sells AS
    SELECT date_part('month', deptime) as month_no,
           to_char(deptime, 'Month') as month,
           count(flightid) as tickets_sold
    FROM faraway.flight
    GROUP BY date_part('month', deptime), to_char(deptime, 'Month')
    ORDER BY month_no;

-- Список всех доступных рейсов с количеством доступных билетов, их ценой и городами, аэропортами вылета и прилета
-- отсортированный по времени вылета
CREATE VIEW faraway.flights_list AS
    SELECT DISTINCT deptime, af.city city_from, af.name airport_from, at.city city_to, at.name airport_to, avTickets, price
    FROM faraway.ticket
    INNER JOIN faraway.flight USING (flightid)
    INNER JOIN faraway.route USING (routeid)
    INNER JOIN faraway.airport af on af.name=route.origin
    INNER JOIN faraway.airport at on at.name=route.destination
    ORDER BY deptime;

-- Все имеющиеся маршруты без служебной информации
CREATE VIEW faraway.routes_view AS
    SELECT af.city as city_from, af.country as country_from, at.city as city_to, at.country as counrty_to
    FROM faraway.route INNER JOIN faraway.airport af ON af.name=route.origin
    INNER JOIN faraway.airport at ON at.name=route.destination;

-- Таблица обычных пользователей со скрытыми почтами
CREATE VIEW faraway.customer_list AS
    SELECT first_name name,
           last_name surname,
           regexp_replace(email, '.*@', '****@') email_view
    FROM faraway.customer
    WHERE NOT isadmin;

-- Таблица налета самолетов
CREATE VIEW faraway.aircraft_usage AS
   SELECT aircraftid,
          model,
          company,
          CASE WHEN count(flightid) IS NOT NULL THEN count(flightid)
          ELSE 0
          END flights
    FROM faraway.aircraft LEFT JOIN faraway.flight USING(aircraftid)
    GROUP BY aircraftid, model, company;




