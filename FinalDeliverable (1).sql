-- Final Project Assignment #4: Database implementation
-- Project Group BB2
-- Group names: Cherish Chen, Nathan Nguyen, Aakash Baheti, Molly Banks

-- [Q0]
-- Database name: nnguye95_db
-- Table Names: artist, album, users, playlist, playlist_songs, streams,
-- songs_on_albums

-- [Q1] Create table statements implementing schema

-- creates artist table
CREATE TABLE artist (
artist_id int PRIMARY KEY,
artist_name varchar(100),
record_label varchar(75)
);

-- creates album table
CREATE TABLE album (
album_id int PRIMARY KEY,
album_name varchar(100),
artist_id int NOT NULL,
release_date date,
FOREIGN KEY (artist_id) REFERENCES artist(artist_id)
);

-- creates user table
CREATE TABLE users (
user_id int PRIMARY KEY,
username varchar(10) UNIQUE NOT NULL,
email varchar(250) NOT NULL,
plan_type varchar(50) NOT NULL,
dob date,
user_since date,
city varchar(250),
CONSTRAINT check_plan_type CHECK (plan_type IN ('premium_family', 'premium_duo',
  'premium_individual', 'premium_student', 'free'))
);

-- creates playlist table
CREATE TABLE playlist (
playlist_id int PRIMARY KEY,
playlist_name varchar(250),
creator_name varchar(10) NOT NULL,
created_date date,
FOREIGN KEY (creator_name) REFERENCES users(username) ON DELETE CASCADE
);

-- creates songs table
CREATE TABLE songs (
song_id int PRIMARY KEY,
title varchar(250),
artist_id int,
length time,
genre varchar(50),
FOREIGN KEY (artist_id) REFERENCES artist(artist_id)
);

-- creates intermediate table to represent many to many relationship between
-- songs and playlists
CREATE TABLE playlist_songs (
playlist_id int,
song_id int,
FOREIGN KEY (playlist_id) REFERENCES playlist(playlist_id) ON DELETE CASCADE,
FOREIGN KEY (song_id) REFERENCES songs(song_id) ON DELETE CASCADE,
PRIMARY KEY (playlist_id, song_id)
);

-- creates intermediate table to represent many to many relationship between
-- songs and albums
CREATE TABLE songs_on_albums (
song_id int,
album_id int,
FOREIGN KEY (song_id) REFERENCES songs(song_id) ON DELETE CASCADE,
FOREIGN KEY (album_id) REFERENCES album(album_id) ON DELETE CASCADE,
PRIMARY KEY (song_id, album_id)
);

-- creates streams table to represent "stream" relationship between songs and users
CREATE TABLE streams (
stream_id int PRIMARY KEY,
song_id int,
user_id int,
stream_time timestamp,
source int, -- stream source- either streamed from playlist or album
source_type varchar(10) NOT NULL,
download_status boolean,
FOREIGN KEY (song_id) REFERENCES songs(song_id),
FOREIGN KEY (user_id) REFERENCES users(user_id),
CONSTRAINT check_plan_type CHECK (source_type IN ('playlist', 'album')),
CONSTRAINT fk_streams_playlist FOREIGN KEY (source) REFERENCES playlist(playlist_id) ON DELETE CASCADE,
CONSTRAINT fk_streams_album FOREIGN KEY (source) REFERENCES album(album_id) ON DELETE CASCADE
);

-- 10 SQL Queries
--1. For each user, returns their most streamed song and its download status.

WITH streams_per_user as (SELECT user_id, song_id,
                                 count(stream_id) as num_streams
                          FROM streams
                          GROUP BY user_id, song_id),
	most_streamed_song as (select user_id, max(num_streams) as max_streams
                            FROM streams_per_user
                            GROUP BY user_id)
SELECT u.user_id, u.song_id, s.download_status
FROM streams_per_user u
JOIN streams s ON u.user_id = s.user_id
              AND u.song_id = s.song_id
JOIN most_streamed_song m ON u.user_id = m.user_id
                              AND u.num_streams = m.max_streams;


--2. Returns the average number of songs per playlist.

WITH songs_per_playlist as (SELECT count(song_id) as num_songs
                            FROM playlist_songs
                            GROUP BY playlist_id)
SELECT avg(s.num_songs)
FROM songs_per_playlist s;



--3. For each user, returns the number of playlists they have with less than 5 songs.
WITH playlist_less_than_5_songs as (SELECT playlist_id
                                    FROM playlist_songs
                                    GROUP BY playlist_id
                                    HAVING count(song_id) < 5)
SELECT p.creator_name, count(s.playlist_id) as num_playlists
FROM playlist p
JOIN playlist_less_than_5_songs s ON p.playlist_id = s.playlist_id
GROUP BY p.creator_name;

-- 4. Returns the top 5 longest duration songs from the jazz genre.

SELECT s.title, s.length
FROM songs s
WHERE s.genre = 'jazz'
ORDER BY s.length DESC
LIMIT 5;

-- 5. Returns the number of playlists containing over 20 songs
-- created since Jan 1st 2020

SELECT COUNT(*) AS num_playlists_over_20_songs
FROM (
    SELECT playlist_id, COUNT(song_id) AS num_songs
    FROM playlist_songs ps
    GROUP BY playlist_id
    HAVING COUNT(song_id) > 20
) AS playlists_over_20
INNER JOIN playlist p ON playlists_over_20.playlist_id = p.playlist_id
WHERE p.created_date >= '2020-01-01';

-- 6. Returns the three most recently released songs where the album genre is pop.

SELECT s.title, a.release_date
FROM songs s
JOIN songs_on_albums sa ON s.song_id = sa.song_id
JOIN album a ON sa.album_id = a.album_id
WHERE a.release_date IS NOT NULL
AND a.release_date <= CURRENT_DATE
AND s.genre = 'pop'
ORDER BY a.release_date DESC
LIMIT 3;

-- 7. Returns the number of unique song genres in each user-made playlist.
select playlist_name, count(distinct genre) as unique_genre_count
from playlist_songs
join songs on playlist_songs.song_id = songs.song_id
join playlist on playlist_songs.playlist_id = playlist.playlist_id
group by playlist_name;

--8 Returns the number of unique users that have streamed a particular artist(‘Drake’)
-- within a particular year(‘2020’).

SELECT COUNT(DISTINCT streams.user_id) AS unique_users
FROM streams
JOIN songs ON streams.song_id = songs.song_id
JOIN artist ON songs.artist_id = artist.artist_id
WHERE artist.artist_name = 'Drake'
AND EXTRACT(YEAR FROM streams.stream_time) = 2020;

--9 For each city, returns the most streamed genre.

SELECT city, genre, MAX(stream_count) AS stream_count
FROM (
    SELECT u.city, s.genre, COUNT(*) AS stream_count
    FROM streams st
    JOIN songs s ON st.song_id = s.song_id
    JOIN users u ON st.user_id = u.user_id
    GROUP BY u.city, s.genre
) AS genre_streams
GROUP BY city, genre;

--10 Returns the most recent album released by a given artist('Coldplay').

SELECT album_name, MAX(release_date) AS release_date
FROM album
JOIN artist ON album.artist_id = artist.artist_id
WHERE artist.artist_name = 'Coldplay'
Group By album_name;



--[Q3] Demo Queries

-- Molly Banks' Demo Query
--1. For each user, returns the number of playlists they have with less than 5 songs.

WITH playlist_less_than_5_songs as (SELECT playlist_id
                                    FROM playlist_songs
                                    GROUP BY playlist_id
                                    HAVING count(song_id) < 5)
SELECT p.creator_name, count(s.playlist_id) as num_playlists
FROM playlist p
JOIN playlist_less_than_5_songs s ON p.playlist_id = s.playlist_id
GROUP BY p.creator_name
LIMIT 5;

-- Output: (creator_name, num_playlists)
-- "sophia_miller"	1
-- "olivia_brown"	1
-- "john_doe"	2
-- "michael_jones"	1
-- "emma_smith"	1


-- Aakash Baheti Demo Query
--2. Returns three most recently released songs where the album genre is pop.
SELECT s.title, a.release_date
FROM songs s
JOIN songs_on_albums sa ON s.song_id = sa.song_id
JOIN album a ON sa.album_id = a.album_id
WHERE a.release_date IS NOT NULL
AND a.release_date <= CURRENT_DATE
AND s.genre = 'pop'
ORDER BY a.release_date DESC
LIMIT 3;

-- output: (title, release_date)
--"Shape of You"	"2017-03-03"
--"Halo"	"2016-04-23"
--"Rolling in the Deep"	"2011-01-19"

--Cherish Chen Demo Query
--3. For each city, returns the most streamed genre.
SELECT city, genre, MAX(stream_count) AS stream_count
FROM (
  SELECT u.city, s.genre, COUNT(*) AS stream_count
  FROM streams st
  JOIN songs s ON st.song_id = s.song_id
  JOIN users u ON st.user_id = u.user_id
  GROUP BY u.city, s.genre
) AS genre_streams
GROUP BY city, genre
LIMIT 10;

-- output: (city, genre, stream_count)
--"Berlin"	"alternative"	1
--"Berlin"	"pop"	1
--"Berlin"	"r&b"	1
--"Chicago"	"country"	1
--"Chicago"	"hip hop"	1
--"Chicago"	"pop"	1
--"Chicago"	"r&b"	2
--"London"	"alternative"	1
--"London"	"pop"	3
--"London"	"r&b"	3

-- Nathan’s' Demo Query
--4. Returns the number of unique song genres in each user-made playlist.
select playlist_name, count(distinct genre) as unique_genre_count
from playlist_songs
join songs on playlist_songs.song_id = songs.song_id
join playlist on playlist_songs.playlist_id = playlist.playlist_id
group by playlist_name;

-- output: (playlist_name, unique_genre_count)
--"Chill Vibes"	2
--"Driving Beats"	1
--"Favorites"	2
--"Morning Jams"	1
--"Party Mix"	1
--"Relaxation"	1
--"Road Trip"	2
--"Study Tunes"	3
--"Workout"	2

-- [Q4] Reflection on what we learned and challenges

-- Our project builds a database system for the music streaming industry,
-- using Spotify as an example. It stores and manages user data like listening habits,
-- playlists, genre preferences, and demographics from the Spotify platform.
-- The primary goal is to enhance the user experience through data analysis,
-- enabling personalized recommendations, intelligent playlists, and other services.
-- The data also helps Spotify analysts, curators, and artists understand user
-- preferences for product and marketing decisions.

-- In our design stage, we learned how different design decisions determine
-- the ways our data is understood in the context of our database. For example,
-- we had to wrestle with how we wanted streams to be represented.
-- At first, we thought of streams as an entity set, but we learned though feedback
-- and experience that streams was a relationship between users and songs that
-- would be ultimately implemented as a table in our database. We also had to make
-- tricky decisions about the kinds of data we wanted to represent in order to align
-- with the use cases we predicted in our project outline. We learned to consider
-- the kinds of queries that would be useful in our business context and make
-- intentional design decisions in our ERD to reflect those considerations.
--
-- In the implementation stage, we learned to be thoughtful about translating
-- our ERD into our relational database. In troubleshooting check constraints
-- and triggers, we learned to think through the implementation logically to
-- make well-informed decisions. Building queries was more straightforward
-- when we had a solid understanding of our database and the relationships
-- between our tables. By making thoughtful design choices, we were able to
-- implement a solid set of queries that showcased the use cases of our database.
--
-- Despite our success in this project, there were also some minor road bumps
-- along the way. For example, we faced confusion in regards to adding or not
-- adding check constraints to our create table statements as check constraints
-- could be hopeful to limit the value range that could be placed in a column.
-- We found difficulty identifying areas in the create table statements where check
-- constraints would be appropriate. After receiving feedback on our design from
-- Professor Lucy Wang and our peers during lab section, we also had to find ways
-- to implement the feedback without it conflicting with our own requirements for
-- the project. Additionally, since it had been a while since last using Figma,
-- when developing the ERD, it was a bit rough to start off.
--
-- Working on our database design and implementation, the process persisted with
-- many challenges, including redundancy and consistency in our ERD and database
-- schemas. How we were able to address redundancy in both our design and data
-- implementation is taking into account the feedback we got from both our peers
-- and instructor. An example of this was for our ERD, we ended up changing up
-- its structure and removed/added attributes where it was necessary such as getting
-- rid of the streams table and changing to a relationship with attributes attached
-- to it. We addressed the challenges of maintaining consistency in data
-- implementation in our database by working together to ensure that the
-- insert statements were consistent with our create table statements so there
-- would be no conflicts in the data values for the different schemas in our database.
