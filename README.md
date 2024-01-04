![Netflix Background](./photo-1574375927938-d5a98e8ffe85.avif)
# Netflix Shows Analysis

Step by Step Guide to a Data Analysis Project: Uncovering Based on Genre

Tool used: #PostgreSQL #Tableau

[Datasets Used](https://www.kaggle.com/datasets/victorsoeiro/netflix-tv-shows-and-movies?select=titles.csv)

**Business Problem:** The purpose of this analysis is to gather insightful info about the rating of Netflix shows and series, based on rating, popularity on imbd, dmdb. 

**How I Plan On Solving the Problem:** uncover key metrics such as viewer ratings, popularity trends, genre preferences, and viewership patterns. Once the data has been extracted and prepared, I will leverage Tableau to present the findings. 

The dataset consists of 2 files:
- titles: shows, series by their names, genres and rating (id is primary key)
- credit: people, contributor in the shows by their names and roles (id foreign key) 

## Loading resources to database to PostgreSQL

```sql
--check version
select version()
```

In the command line: 

```bash
psql -U user_name -d database_name
```


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
\COPY titles FROM '/Users/admin/Documents/data analysis/netflix-shows/titles.csv' WITH ( FORMAT CSV, HEADER true, DELIMITER ',');

```

Note: the ‘\’ backlash means operating on client-side psql

## Exploratory Data Analysis
```sql
--count distinct input
SELECT count(distinct title) FROM titles
```


```sql
--count  input
SELECT count( title) FROM titles
```

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