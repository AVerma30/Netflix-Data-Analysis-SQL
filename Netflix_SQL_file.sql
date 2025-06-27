-- Netflix Project
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id VARCHAR(10),
	type VARCHAR(10),
	title  VARCHAR(150),
	director VARCHAR(210),
	casts  VARCHAR(1000),
	country  VARCHAR(180),
	date_added VARCHAR(100),
	release_year INT, 
	rating  VARCHAR(10),
	duration VARCHAR(10),
	listed_in VARCHAR(150),
	description VARCHAR(300)
);

SELECT * FROM netflix;
-- To check teh total number/ or if the complete data has been imported
SELECT COUNT (*) as total_content FROM netflix;

-- 15 Business Problems

-- 1. Count the number of Movies vs TV Shows

SELECT type,
  COUNT(*) as total_counts
  FROM netflix
 GROUP BY type

 -- 2. Find the most common rating for movies and TV Shows
SELECT
type, rating
FROM

(SELECT 
 type,
 rating,
 COUNT (*),
 RANK() OVER(PARTITION BY TYPE ORDER BY COUNT(*) DESC) as ranking
 FROM netflix
 GROUP BY 1,2 
 ) as t1
 WHERE ranking IN (1); 

-- 3. List all movies released in a specific year ( e.g 2021)
SELECT * FROM netflix
WHERE 
	type = 'Movie'
	AND
	release_year = 2021

-- 4. Find the top 5 countries with the most content on Netflix

SELECT
	UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- 5. Identify the longest movie 

SELECT * FROM netflix
WHERE 
	type='Movie'
	AND
	duration = (SELECT MAX(duration) FROM netflix)


-- 6. Find the content added in the last 6 year

SELECT *
FROM netflix
WHERE
    CASE
        WHEN date_added IS NULL THEN NULL -- Handle NULLs gracefully
        WHEN date_added ~ '^[0-9]{1,2}-[A-Za-z]{3}-[0-9]{2}$' THEN TO_DATE(date_added, 'DD-Mon-YY') -- For 'DD-Mon-YY'
        WHEN date_added ~ '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$' THEN TO_DATE(TRIM(date_added), 'Month DD, YYYY') -- For 'Month DD, YYYY'
        ELSE NULL                   -- For any other unexpected formats, treat as NULL or handle as needed
    END >= CURRENT_DATE - INTERVAL '6 years'
;

-- 7. Find all the movies/ TV Shows directed by 'Rajiv Chilaka' !!

SELECT * FROM netflix
WHERE director LIKE '%Rajiv Chilaka%'

-- 8. List all the TV Shows with more than 5 seasons

SELECT *
FROM netflix
WHERE
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ',1):: numeric >= 5

-- 9. Count the number of content items in each genre

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS Different_genre,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1

 -- 10. Find each year and teh average number of content release by India on netflix, 
  		-- return top 5 year with highest average content release!!

SELECT
    EXTRACT(YEAR FROM (
        CASE
            WHEN date_added IS NULL THEN NULL
            WHEN date_added ~ '^[0-9]{1,2}-[A-Za-z]{3}-[0-9]{2}$' THEN TO_DATE(date_added, 'DD-Mon-YY')
            WHEN date_added ~ '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$' THEN TO_DATE(TRIM(date_added), 'Month DD,YYYY'::text)
            ELSE NULL
        END
    )) AS release_year,
    COUNT(*) AS number_of_content_releases 
FROM netflix
WHERE country = 'India'
GROUP BY
    EXTRACT(YEAR FROM (
        CASE
            WHEN date_added IS NULL THEN NULL
            WHEN date_added ~ '^[0-9]{1,2}-[A-Za-z]{3}-[0-9]{2}$' THEN TO_DATE(date_added, 'DD-Mon-YY')
            WHEN date_added ~ '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$' THEN TO_DATE(TRIM(date_added), 'Month DD,YYYY'::text)
            ELSE NULL
        END )) 
ORDER BY
    COUNT(*) DESC 
LIMIT 5; 

 -- 11. List all movies that are docuentaries

 SELECT * FROM netflix
 WHERE
 	listed_in ILIKE '%documentaries%'
 
  -- 12. Find all conten without a Director

SELECT * FROM netflix
WHERE
	director IS NULL

  -- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!!

SELECT * FROM netflix
WHERE
	casts ILIKE '%salman khan%'
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

	-- 14. Find the top 10 actors who have appeared in teh highest number of movies produced in India.

SELECT 
	UNNEST ( STRING_TO_ARRAY(casts, ',')) as actors,
	COUNT(*) as total_content
FROM netflix
WHERE
	country ILIKE '%india%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

-- 15. Categorize the contetn based on the presence of teh keywords 'kill' and 'violence' in
--      the description. Label content contailing these keywords as 'Adult' and all otehr  content as
--      'Public'. Count how many of them fall into each category.

WITH new_table
AS
(
SELECT *,
	CASE
	WHEN
		description ILIKE 'Kill'
		OR
		description ILIKE 'killed'
		OR
		description ILIKE 'kill'
		OR
		description ILIKE '%violence%' THEN 'Adult Content'
		ELSE 'Public Release Permitted'
	END category
FROM netflix
)
SELECT category,
 	COUNT(*) as Total_count
	FROM new_table
	GROUP BY 1