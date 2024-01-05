![Netflix Background](./photo-1574375927938-d5a98e8ffe85.avif)
# Netflix Shows Analysis

Uncover insights about TV shows and Movies from user rating

Tool used: #PostgreSQL #Tableau

[Datasets Used](https://www.kaggle.com/datasets/victorsoeiro/netflix-tv-shows-and-movies?select=titles.csv)

**Business Problem:** To identify trends, audience taste by the type of shows, movies, genre, performers with high rating

**How I Plan On Solving the Problem:** uncover key metrics such as viewer ratings, popularity trends, genre preferences, and viewership patterns. Once the data has been extracted and prepared, I will leverage Tableau to present the findings. 

**The extra mile:** what is the type of visuals, music are getting higher upvotes

The dataset consists of 2 files:
- titles: shows, series by their names, genres and rating (id is primary key)
- credit: performer, contributor in the shows by their names and roles (id foreign key) 

## Loading resources to database to PostgreSQL

```sql
--check version
select version()
```
## Sidenote about PostgreSQL
There are 2 tools to use: 
- PSQL , which is like a command line, used to create table, import, copy records
- the Query Tool to write SQL queries

## Define tables and value types

**In the PSQL**

```sql
CREATE TABLE titles (   id TEXT PRIMARY KEY,  title TEXT,  show_type TEXT,  description TEXT,  release_year INT,  age_certification TEXT,  runtime FLOAT,  genres TEXT,  production_countries TEXT,  seasons FLOAT,  imdb_id FLOAT,  imdb_score FLOAT,  imdb_votes FLOAT,  tmdb_popularity FLOAT,  tmdb_score FLOAT);
```

To change the data type of an existing table

**In Query Tool**

```sql
ALTER TABLE titles ALTER COLUMN runtime TYPE FLOAT
ALTER TABLE titles ALTER COLUMN seasons TYPE FLOAT
ALTER TABLE titles ALTER COLUMN imdb_id TYPE FLOAT
ALTER TABLE titles ALTER COLUMN imdb_score TYPE TEXT
```

## Uploading CSV to PostgreSQL

**In PSQL Tool**

```sql
\COPY titles FROM '/Users/admin/Documents/data analysis/netflix-shows/data/titles.csv' WITH ( FORMAT CSV, HEADER true, DELIMITER ',');

```

Note: the ‘\’ backlash means operating on client-side psql

## Exploratory Data Analysis

### Is there any missing, duplicates in key fields?
```sql
--count distinct input
SELECT count(distinct title) FROM titles
```
Result: 5798 distinct titles

```sql
--count  input
SELECT count( title) FROM titles
```
Result: 5849 total titles
There are some null values and duplicates which we might need to deal with later

```sql
--count null title
SELECT count(*) FROM titles
WHERE title is null
```
Result: 1 null row
```sql
--count null input
SELECT count(*) FROM titles
WHERE imdb_score is null 
```
result: 482 null imdb_score

```sql
-- count number of shows vs movies
SELECT 
	SUM(CASE WHEN type = 'SHOW' THEN 1 ELSE 0 END) AS show_num,
	SUM(CASE WHEN type = 'MOVIE' THEN 1 ELSE 0 END) AS movie_num
FROM titles
```
![Screen Shot 2024-01-04 at 11.18.03 AM.png](./Screen%20Shot%202024-01-04%20at%2011.43.20%20AM.png)

```sql
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
```
![Screen Shot 2024-01-04 at 11.46.03 AM.png](./Screen%20Shot%202024-01-04%20at%2011.46.46%20AM.png)

There are a total of 19 genres in the database with with 'drama', 'comedy' as the top available

### What are the top 5 movies and shows by their ratings?
```sql
--top 5 movies by score
SELECT title, 
imdb_score,
"type", genres, runtime
FROM titles
WHERE "type" = 'MOVIE' AND imdb_score is not null
ORDER BY imdb_score DESC
```

![Screen Shot 2024-01-04 at 12.28.03 AM.png](./Screen%20Shot%202024-01-04%20at%2012.28.56%20PM.png)

```sql
--top 5 shows by score
SELECT title, 
imdb_score,
"type", genres, runtime
FROM titles
WHERE "type" = 'SHOW' AND imdb_score is not null
ORDER BY imdb_score DESC
```
![Screen Shot 2024-01-04 at 12.28.56 PM.png](./Screen%20Shot%202024-01-04%20at%208.42.42%20PM.png)

```sql
--top 5 shows by score
SELECT title, 
imdb_score,
"type", genres, runtime
FROM titles
WHERE "type" = 'SHOW' AND imdb_score is not null
ORDER BY imdb_score DESC
```

### How many series, movies are published by decades?
```sql
-- number of movies, series by release_year
SELECT CONCAT(FLOOR(release_year/10)*10,'s') as decades, 
        COUNT (*) as number_of_shows_released

FROM titles
WHERE title is not null
GROUP BY decades
ORDER BY decades
```