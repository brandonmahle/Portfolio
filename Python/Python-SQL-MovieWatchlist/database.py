import datetime
import psycopg2
import psycopg2.extras

CREATE_MOVIES_TABLE = """ 
CREATE TABLE IF NOT EXISTS public.movies (
    id SERIAL PRIMARY KEY,
    title VARCHAR(55),
    release_timestamp REAL
);"""

CREATE_USERS_TABLE = """ 
CREATE TABLE IF NOT EXISTS public. users (
    username VARCHAR(55) PRIMARY KEY
);"""

CREATE_WATCHED_TABLE = """ 
CREATE TABLE IF NOT EXISTS public.watched (
    user_username VARCHAR(55),
    movie_id INTEGER,
    FOREIGN KEY(user_username) REFERENCES public.users(username),
    FOREIGN KEY(movie_id) REFERENCES public.movies(id)
);"""

INSERT_MOVIES = "INSERT INTO public.movies (title, release_timestamp) VALUES (%s, %s);"
INSERT_USER = "INSERT INTO public.users (username) VALUES (%s);"
DELETE_MOVIE = "DELETE FROM public.movies WHERE title = %s;"
SELECT_ALL_MOVIES = "SELECT * FROM public.movies;"
SELECT_UPCOMING_MOVIES = "SELECT * FROM public.movies WHERE release_timestamp > %s;"
SELECT_WATCHED_MOVIES = """
SELECT movies.* FROM public.movies
JOIN public.watched ON movies.id = watched.movie_id
JOIN public.users ON users.username = watched.user_username
WHERE users.username = %s
ORDER BY movies.id ASC;"""
INSERT_WATCHED_MOVIE = "INSERT INTO public.watched (user_username, movie_id) VALUES (%s, %s)"
SET_MOVIE_WATCHED = "UPDATE public.movies SET watched = 1 WHERE title = %s;"
SEARCH_MOVIES = "SELECT * FROM public.movies where title like %s;"
CREATE_RELEASE_INDEX = "CREATE INDEX IF NOT EXISTS idx_movies_release ON public.movies (release_timestamp);"

# information needed to connection to PostgreSQL database
db_hostname = "localhost"
db_database = "movies"
db_username = "postgres"
db_pwd = "password"
db_port_id = 5432
db_conn = None

connection = psycopg2.connect(
    host=db_hostname,
    dbname=db_database,
    user=db_username,
    password=db_pwd,
    port=db_port_id)


def create_table():
    with connection:
        with connection.cursor() as cursor:
            cursor.execute(CREATE_MOVIES_TABLE)
            cursor.execute(CREATE_USERS_TABLE)  # this must be created second because of the foreign keys in watched
            cursor.execute(CREATE_WATCHED_TABLE)
            cursor.execute(CREATE_RELEASE_INDEX)


def add_user(username):
    with connection:
        with connection.cursor() as cursor:
            cursor.execute(INSERT_USER, (username,))


def add_movie(title, release_timestamp):
    with connection:
        with connection.cursor() as cursor:
            cursor.execute(INSERT_MOVIES, (title, release_timestamp))


def get_movies(upcoming=False):
    with connection:
        with connection.cursor() as cursor:
            if upcoming:
                today_timestamp = datetime.datetime.today().timestamp()
                cursor.execute(SELECT_UPCOMING_MOVIES, (today_timestamp,))
            else:
                cursor.execute(SELECT_ALL_MOVIES)  # could also do cursor = connection.execute(SELECT_ALL_MOVIES)
            return cursor.fetchall()


def watch_movie(username, movie_id):
    with connection:
        with connection.cursor() as cursor:
            cursor.execute(INSERT_WATCHED_MOVIE, (username, movie_id))


def get_watched_movies(username):
    with connection:
        with connection.cursor() as cursor:
            cursor.execute(SELECT_WATCHED_MOVIES, (username,))
            return cursor.fetchall()


def search_movies(search_term):
    with connection:
        with connection.cursor() as cursor:
            cursor.execute(SEARCH_MOVIES, (f"%{search_term}%",))
            return cursor.fetchall()
