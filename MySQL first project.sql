CREATE DATABASE IF NOT EXISTS music_database;
USE music_database;

-- Q1: Who is the senior most employee based on job title?
SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1;

-- Q2: Which country have the most invoice? 
SELECT COUNT(*) AS C, billing_country
FROM invoice
GROUP BY billing_country
ORDER BY c DESC;

-- Q3: What are top 3 value of total invoice?
SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3;

-- Q4: Which city has the best customer? We would to like to throw a promotional music festival in the city we made the money most
-- write a query that return one city that has the highest sum of invoice totals. Retunt both the city name and sum of all invoice totals
SELECT SUM(total) as invoice_total , billing_city
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC;

-- Q5: Who is the best customer? The person who has spent the most money has declare as the best customer write a query that
-- returns the person who has spent the most money?
SELECT customer.customer_id , customer.first_name, customer.last_name,SUM(invoice.total) as total
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id,customer.first_name, customer.last_name
ORDER BY total DESC
LIMIT 1;


 -- Modarate Question --
 
 
 -- Q1: Write the query to return the email, first name,last name and Genre of all rock music listener.
-- Returned your list alphabetacally by email starting with A
SELECT DISTINCT email ,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
    SELECT track_id FROM track
    JOIN genre ON track.genre_id = genre.genre_id
    WHERE genre.name LIKE "Rock"
    )
ORDER by email;

-- Q2: Lets invite the artist who have written the most rock music in our dataset. Write a query
-- that returns the artist name and total track count of the top 10 rock bands
SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE "Rock"
GROUP BY artist.artist_id,artist.name
ORDER BY number_of_songs DESC
LIMIT 10;

-- Return all the track names that have a song length longer than the average song length. Return the names and the milliseconds 
-- for each track. Order by the song length with the longest songs listed first
SELECT name , milliseconds 
FROM track 
WHERE milliseconds >(
     SELECT AVG(milliseconds) AS avg_track_length
     FROM track
)
ORDER by milliseconds DESC;


-- Advance Question --


-- Q1: Find much amount spent by each customer or artist? Write a query to return 
-- customer name ,artist name and total spent
WITH best_selling_artist AS(
	SELECT artist.artist_id AS artist_id ,artist.name AS artist_name,
	SUM(invoice_line.unit_price *invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY artist.artist_id , artist.name
	ORDER BY total_sales DESC
	LIMIT 1
)
SELECT customer.customer_id ,customer.first_name , customer.last_name, best_selling_artist.artist_name, 
SUM(invoice_line.unit_price *invoice_line.quantity) AS amount_spent
FROM invoice
JOIN customer ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN album ON album.album_id = track.album_id
JOIN best_selling_artist ON  best_selling_artist.artist_id = album.artist_id
GROUP BY customer.customer_id ,customer.first_name , customer.last_name, best_selling_artist.artist_name
ORDER BY amount_spent DESC;

-- Q2: We want to find out the most popular music Genre each country. We determine the most popular 
-- as the genre with the highest amount of purcheses. Write a query that each country along with top Genre.
-- For countries where the maximum number of purchases is shared return all Genres.
WITH popular_genre AS(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
    ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNO
    FROM invoice_line
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer ON customer.customer_id = invoice.customer_id
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN genre ON genre.genre_id = track.genre_id
    GROUP BY customer.country, genre.name, genre.genre_id
    ORDER BY  customer.country ASC, purchases DESC
)
SELECT * FROM  popular_genre WHERE RowNo <=1

