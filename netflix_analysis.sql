select version()

ALTER TABLE titles ALTER COLUMN seasons TYPE FLOAT
ALTER TABLE titles ALTER COLUMN imdb_votes TYPE FLOAT
ALTER TABLE titles ALTER COLUMN imdb_score TYPE FLOAT

--count distinct input
SELECT count(distinct title) FROM titles

--count  input
SELECT count( title) FROM titles

--count null input
SELECT count(*) FROM titles
WHERE title is null

--count null input
SELECT count(*) FROM titles
WHERE imdb_score is null 

--count number of show/movie in the dataset
SELECT 
	SUM(CASE WHEN show_type = 'SHOW' THEN 1 ELSE 0 END) AS show_num,
	SUM(CASE WHEN show_type = 'MOVIE' THEN 1 ELSE 0 END) AS movie_num
FROM titles

-- What are the top 5 most popular genres

WITH unnested_genres  AS (
SELECT unnest(regexp_split_to_array(
	replace (replace(replace(genres,'[',''),']',''),' ','')
			, E',')) 
	AS genre
FROM titles )
SELECT genre
FROM unnested_genres
WHERE genre <> ''

WITH unnested_genres  AS (
SELECT unnest(regexp_split_to_array(
	replace (replace(replace(genres,'[',''),']',''),' ','')
			, E',')) 
	AS genre
FROM titles )
SELECT genre, COUNT(*) AS count
FROM unnested_genres
WHERE genre <> ''
GROUP BY genre
ORDER BY count DESC
LIMIT 5;

--top 5 movies by score
SELECT title, 
imdb_score,
"type", genres, runtime
FROM titles
WHERE "type" = 'MOVIE' AND imdb_score is not null
ORDER BY imdb_score DESC
LIMIT 5

--top 5 shows by score
SELECT title, 
imdb_score,
"type", genres, runtime
FROM titles
WHERE "type" = 'SHOW' AND imdb_score is not null
ORDER BY imdb_score DESC
LIMIT 5

-- number of movies, series by release_year
SELECT CONCAT(FLOOR(release_year/10)*10,'s') as decades, 
        COUNT (*) as number_of_shows_released

FROM titles
WHERE title is not null
GROUP BY decades
ORDER BY decades


-- number of movies, series by release_year
SELECT CONCAT(FLOOR(release_year/10)*10,'s') as decades, 
        ROUND(CAST(AVG(imdb_score) AS NUMERIC),2) as avg_score

FROM titles
WHERE title is not null
GROUP BY decades
ORDER BY avg_score



-- credit table
SELECT * FROM credit


-- right join 2 tables
SELECT * FROM titles
RIGHT JOIN credit
ON titles.id = credit.id

--get average score for each person/chracter
WITH score_by_person AS(
	-- average score by id
	WITH id_score AS (
		SELECT "id", ROUND(CAST(AVG(imdb_score) as numeric),2) as avg_score
		FROM titles 
		GROUP BY "id")
	SELECT * FROM id_score
	RIGHT JOIN credit
	ON id_score.id = credit.id)
SELECT "name", "role", ROUND(CAST(AVG(avg_score) as numeric),2) AS avg_score_by_person
FROM score_by_person
WHERE avg_score is not null and "role" = 'ACTOR'
GROUP BY "name", "role"
ORDER BY avg_score_by_person DESC

--get average score for each director
WITH score_by_person AS(
	-- average score by id
	WITH id_score AS (
		SELECT "id", ROUND(CAST(AVG(imdb_score) as numeric),2) as avg_score
		FROM titles 
		GROUP BY "id")
	SELECT * FROM id_score
	RIGHT JOIN credit
	ON id_score.id = credit.id)
SELECT "name", "role", ROUND(CAST(AVG(avg_score) as numeric),2) AS avg_score_by_person
FROM score_by_person
WHERE avg_score is not null and "role" = 'DIRECTOR'
GROUP BY "name", "role"
ORDER BY avg_score_by_person DESC

-- rating by runtime
SELECT (CASE 
            WHEN runtime < 30 THEN '< 30 mins'
            WHEN runtime < 50 THEN '30-50 mins'
            WHEN runtime < 100 THEN '50-100 mins'
            WHEN runtime < 150 THEN '100-150 mins'
            ELSE '>150 mins'
        END) as duration,
        ROUND(CAST(AVG(imdb_score) AS numeric),2) as avg_score
FROM titles
GROUP BY duration
ORDER BY avg_score