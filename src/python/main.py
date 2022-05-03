import psycopg2


def get_user_by_email(conn, email: str):
    with conn.cursor() as cur:
        cur.execute("SELECT first_name, last_name FROM faraway.customer WHERE email='{}';".format(email))
        name, surname = cur.fetchone()
        return name, surname


def get_available_tickets(conn, city_from: str, city_to: str, date: str):
    with conn.cursor() as cur:
        cur.execute(
            '''
            SELECT flightid, deptime, price
            FROM faraway.route INNER JOIN faraway.flight USING (routeid)
            INNER JOIN faraway.airport af ON af.name=route.origin
            INNER JOIN faraway.airport at ON at.name=route.destination
            WHERE af.city='{0}' AND at.city='{1}'
            AND avTickets > 0
            AND deptime::date = CAST('{2}' AS DATE);
            '''.format(city_from, city_to, date)
        )
        return cur.fetchall()


def get_last_ticket(cur) -> int:
    cur.execute(
        '''
        SELECT max(ticketid) FROM faraway.ticket;
        '''
    )
    return int(cur.fetchone()[0])


def buy_ticket(conn, email: str, flightid: int):
    with conn.cursor() as cur:
        sql = '''INSERT INTO faraway.ticket VALUES({0}, {1}, '{2}');
            '''.format(get_last_ticket(cur) + 1, flightid, email)
        cur.execute(sql)
        conn.commit()


def try_buy(city_from, city_to, conn, date, email):
    tickets = get_available_tickets(conn, city_from, city_to, date)
    if len(tickets) == 0:
        print("Sorry, on tickets found! Please, choose another date")
        return False
    else:
        buy_ticket(conn, email, tickets[0][0])
        print("Ticket is bought successfully!")
        return True


def main():
    with psycopg2.connect(database="faraway_db", user="postgres", password="postgres",
                          host="docker", port="5432") as conn:
        print("Connected")

        email = "steve@gmail.com"
        name, surname = get_user_by_email(conn, email)
        print("Welcome, {} {}!".format(name, surname))

        # Wants to buy ticket to New York from Moscow on 2021-09-02
        city_from = "Moscow"
        city_to = "New York"
        date = "2021-09-02"
        assert try_buy(city_from, city_to, conn, date, email) is True

        # Tickets are available
        city_from = "Singapore"
        city_to = "Melbourne"
        date = "2021-08-16"
        assert try_buy(city_from, city_to, conn, date, email) is True

        # No tickets
        city_from = "Omsk"
        city_to = "New York"
        date = "2021-09-02"
        assert try_buy(city_from, city_to, conn, date, email) is False


if __name__ == "__main__":
    main()
