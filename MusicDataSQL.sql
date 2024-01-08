SELECT * FROM MusicStoreProject..album;

-- Senior most employee based on the job title

SELECT TOP 1 * 
FROM employee
ORDER BY levels DESC;

-- Countries having most num of invoices

SELECT COUNT(*) AS NumOfInvoices, billing_country
FROM invoice
GROUP BY billing_country
ORDER BY NumOfInvoices DESC;

-- Top 3 totals of invoices

SELECT TOP 3 total
FROM invoice
ORDER BY total DESC;

-- City which has highest sum of invoice totals

SELECT TOP 1 billing_city, SUM(total) AS SumOfInvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY SumOfInvoiceTotal DESC;

-- Customer who has spent the most money

SELECT TOP 1 C.customer_id, SUM(I.total) AS TotalSpent, C.first_name, C.last_name
FROM customer C
JOIN invoice I ON C.customer_id = I.customer_id
GROUP BY C.customer_id, C.first_name, C.last_name
ORDER BY TotalSpent DESC;

-- Query to return email, firstname, lastname, and Genre of all rock music listeners. Order it by email

SELECT DISTINCT C.email, C.first_name, C.last_name
FROM customer C
JOIN invoice I ON C.customer_id = I.invoice_id
JOIN invoice_line IL ON I.invoice_id = IL.invoice_id
WHERE track_id IN (
	SELECT track_id
	FROM track T
	JOIN genre G ON T.genre_id = G.genre_id
	WHERE G.name = 'Rock')
ORDER BY email;

-- Top 10 Artist that have written the most songs in the Rock genre 

SELECT TOP 10 ART.name, COUNT(ART.artist_id) AS NoOfSongs
FROM track T
JOIN genre G ON G.genre_id = T.genre_id
JOIN album A ON A.album_id = T.album_id
JOIN artist ART ON ART.artist_id = A.artist_id
WHERE G.name = 'Rock'
GROUP BY ART.name
ORDER BY NoOfSongs DESC;

-- All the tracks that have the song length than the avg song length

SELECT name, milliseconds
FROM track
WHERE milliseconds > ( SELECT AVG(milliseconds) AS AvgSongLength
					   FROM track)
ORDER BY milliseconds DESC;

-- How much amount is spent by each customer on artists 

WITH BestSellingArtists AS(
SELECT TOP 1 ART.artist_id AS ArtistID, ART.name AS ArtistName, SUM(IL.unit_price * IL.quantity) AS TotalSales
FROM invoice I
JOIN invoice_line IL ON I.invoice_id = IL.invoice_id
JOIN track T ON T.track_id = IL.track_id
JOIN album Al ON AL.album_id = T.album_id
JOIN artist ART ON ART.artist_id = AL.artist_id
GROUP BY ART.artist_id, ART.name
ORDER BY 3 DESC)

SELECT C.customer_id, C.first_name, C.last_name, BSA.ArtistName, SUM(IL.unit_price * IL.quantity) AS TotalSales
FROM invoice I
JOIN invoice_line IL ON I.invoice_id = IL.invoice_id
JOIN track T ON T.track_id = IL.track_id
JOIN album Al ON AL.album_id = T.album_id
JOIN artist ART ON ART.artist_id = AL.artist_id
JOIN customer C ON C.customer_id = I.customer_id
JOIN BestSellingArtists BSA ON BSA.ArtistID = ART.artist_id
GROUP BY C.customer_id, C.first_name, C.last_name, BSA.ArtistName
ORDER BY 5 DESC;

-- Most Popular Genre by Country

 Most Popular Genre by Country
WITH PopularGenre AS(
SELECT COUNT(IL.quantity) AS purchases, C.country, G.genre_id,
ROW_NUMBER() OVER(PARTITION BY C.country ORDER BY COUNT(IL.quantity)) AS RowNum
FROM invoice I
JOIN invoice_line IL ON I.invoice_id = IL.invoice_id
JOIN track T ON T.track_id = IL.track_id
JOIN genre G ON G.genre_id = T.genre_id
JOIN customer C ON C.customer_id = I.customer_id
GROUP BY C.country, G.genre_id
ORDER BY 2 ASC, 1 DESC)

SELECT *
FROM PopularGenre
WHERE RowNum <= 1;
