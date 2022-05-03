-- Индексы

-- Создадим индекс по хэшу от города в таблице аэропортов, так как почти все города различны и
-- в каждом городе не больше 2-3 аэропортов хэширование будет хорошим выбором. Кроме того, запросы на получение
-- всех аэропортов в городе пишем через "=", следовательно попадаем под требования хэш индекса
CREATE INDEX city_hash_index ON faraway.airport USING hash(city);

-- Создадим индекс через b-tree для дат вылета в таблице рейсов, чаще всего мы ищем данные по временным промежуткам,
-- используя <, >, <=, >=, а значит нам лучше подойдет индекс на сбалансированном дереве
CREATE INDEX date_tree_index ON faraway.flight(deptime);

-- Создадим индекс через хэширование для поиска всех билетов определенного пассажира, так как email всех пассажиров
-- уникален и поиск происходит по условию "=", выбор хэширования оправдан
CREATE INDEX owner_hash_ticket_index ON faraway.ticket USING hash(owner);
--------------------------------------------------------------------------------------------------


-- Триггеры

-- Триггер на добавление проданного билета уменьшающий количество доступных и
-- на удаление проданного билета увеличивающий количество доступных в таблице рейсов

CREATE OR REPLACE FUNCTION process_tickets_count() RETURNS TRIGGER AS $tickets_count$
    BEGIN
        IF (TG_OP = 'INSERT') THEN
            UPDATE faraway.flight SET avtickets = avtickets - 1 WHERE flightid=NEW.flightid;
            RETURN NEW;
        ELSIF (TG_OP = 'DELETE') THEN
            UPDATE faraway.flight SET avtickets = avtickets + 1 WHERE flightid=OLD.flightid;
            RETURN OLD;
        END IF;
        RETURN NULL;
    END;
$tickets_count$ LANGUAGE plpgsql;

CREATE TRIGGER process_tickets_count
    AFTER INSERT OR DELETE ON faraway.ticket FOR EACH ROW EXECUTE FUNCTION process_tickets_count();

-- Триггер на назначение самолета на рейс, проверяющий что самолет еще можно использовать
-- а именно что перелетов у него было меньше 100
CREATE OR REPLACE FUNCTION check_aircraft() RETURNS TRIGGER AS $aircraft_check$
    BEGIN
        IF (
            (SELECT count(flightid) FROM faraway.flight
            WHERE aircraftid=NEW.aircraftid) >= 100
            ) THEN RAISE EXCEPTION '% aircraft overused!', NEW.aircraftid;
        ELSE RETURN NEW;
        END IF;
    END;
$aircraft_check$ LANGUAGE plpgsql;

CREATE TRIGGER check_aircraft_trigger
    BEFORE INSERT OR UPDATE ON faraway.flight FOR EACH ROW EXECUTE FUNCTION check_aircraft();

--------------------------------------------------------------------------------------------------
-- Хранимые функции

-- Изменение цены на рейсы между заданными странами. На вход подаются две страны и доля новой цены от старой
-- Например 0.9 означает понижение цены на 10%
CREATE OR REPLACE FUNCTION faraway.change_price(first_country VARCHAR(20), second_country VARCHAR(20), percent FLOAT)
RETURNS void AS
    '
        UPDATE faraway.route SET price = price * percent
        WHERE (origin=first_country AND destination=second_country) OR
              (origin=second_country AND destination=first_country);
    'LANGUAGE SQL;

SELECT faraway.change_price('Russia', 'USA', 1.1);

-- Выдать все доступные рейсы между заданными городами в заданный день и +- 5 дней от него
CREATE OR REPLACE FUNCTION faraway.get_routes(city_from VARCHAR(20), city_to VARCHAR(20), date text)
RETURNS TABLE(flightid INTEGER, deptime TIMESTAMP, price FLOAT) AS '
    SELECT flightid, deptime, price
    FROM faraway.route INNER JOIN faraway.flight USING (routeid)
    INNER JOIN faraway.airport af ON af.name=route.origin
    INNER JOIN faraway.airport at ON at.name=route.destination
    WHERE af.city=city_from AND at.city=city_to
    AND deptime::date BETWEEN (CAST(date AS DATE) - 5) AND (CAST(date AS DATE) + 5)
' LANGUAGE SQL;

SELECT flightid, deptime::timestamp(0), price 
FROM faraway.get_routes('Moscow', 'New York', '2021-09-02');
