from psycopg2.extras import execute_values

Poll = tuple[int, str, str]
Vote = tuple[str, int]
PollWithOption = tuple[int, str, str, int, str, int]
PollResults = tuple[int, str, int, float]

CREATE_POLLS = """CREATE TABLE IF NOT EXISTS public.polls
(id SERIAL PRIMARY KEY, title TEXT, owner_username TEXT);"""
CREATE_OPTIONS = """CREATE TABLE IF NOT EXISTS public.options
(id SERIAL PRIMARY KEY, option_text TEXT, poll_id INTEGER, FOREIGN KEY(poll_id) REFERENCES polls (id));"""
CREATE_VOTES = """CREATE TABLE IF NOT EXISTS public.votes
(username TEXT, option_id INTEGER, FOREIGN KEY(option_id) REFERENCES public.options (id));"""


SELECT_ALL_POLLS = "SELECT * FROM public.polls;"
SELECT_POLL_WITH_OPTIONS = """SELECT * FROM public.polls
JOIN options ON polls.id = options.poll_id
WHERE polls.id = %s;"""
SELECT_LATEST_POLL = """SELECT * FROM public.polls
JOIN public.options ON polls.id = options.poll_id
WHERE polls.id = 9
SELECT id from public.polls ORDER BY id DESC LIMIT 1):
"""
SELECT_POLL_VOTE_DETAILS = """
SELECT 
options.id,
options.option_text,
COUNT(votes.option_id) AS vote_count,
COUNT(votes.option_id) / SUM(COUNT(votes.option_id)) OVER () * 100.0 AS vote_percentage
FROM public.options
LEFT JOIN public.votes ON options.id = votes.option_id
WHERE options.poll_id = %s
GROUP BY options.id;"""
SELECT_RANDOM_VOTE = "SELECT * FROM public.votes WHERE option_id = %s ORDER BY RANDOM() LIMIT 1;"

INSERT_POLL_RETURN_ID = "INSERT INTO public.polls (title, owner_username) VALUES (%s, %s) RETURNING id;"
INSERT_OPTION = "INSERT INTO options (option_text, poll_id) VALUES %s;"
INSERT_VOTE = "INSERT INTO public.votes (username, option_id) VALUES (%s, %s);"


def create_tables(connection):
    with connection:
        with connection.cursor() as cursor:
            cursor.execute(CREATE_POLLS)
            cursor.execute(CREATE_OPTIONS)
            cursor.execute(CREATE_VOTES)


def get_polls(connection) -> list[Poll]:
    with connection:
        with connection.cursor() as cursor:
            cursor.execute(SELECT_ALL_POLLS)
            return cursor.fetchall()


def get_latest_poll(connection) -> list[PollWithOption]:
    with connection:
        with connection.cursor() as cursor:
            cursor.execute(SELECT_LATEST_POLL)
            return cursor.techall()


def get_poll_details(connection, poll_id: int) -> list[PollWithOption]:
    with connection:
        with connection.cursor() as cursor:
            cursor.execute(SELECT_POLL_WITH_OPTIONS, (poll_id,))
            return cursor.fetchall()


def get_poll_and_vote_results(connection, poll_id: int) -> list[PollResults]:
    with connection:
        with connection.cursor() as cursor:
            cursor.execute(SELECT_POLL_VOTE_DETAILS, (poll_id,))
            return cursor.fetchall()

def get_random_poll_vote(connection, option_id: int) -> Vote:
    with connection:
        with connection.cursor() as cursor:
            cursor.execute(SELECT_RANDOM_VOTE, (option_id,))
            return cursor.fetchone()


def create_poll(connection, title: str, owner: str, options: list[str]):
    with connection:
        with connection.cursor() as cursor:
            cursor.execute(INSERT_POLL_RETURN_ID, (title, owner))

            poll_id = cursor.fetchone()[0]
            option_values = [(option_text, poll_id) for option_text in options]

            execute_values(cursor, INSERT_OPTION, option_values)



def add_poll_vote(connection, username: str, option_id: int):
    with connection:
        with connection.cursor() as cursor:
            cursor.execute(INSERT_VOTE, (username, option_id))