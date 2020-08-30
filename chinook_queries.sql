-- Independent Project 2: Music Store Analysts

-- Which tracks appeared in the most playlists? 
-- How many playlists did they appear in?

SELECT 
	tracks.Name AS 'Title',
	COUNT(*) AS '# of Playlists'
FROM playlist_track
JOIN tracks
	ON playlist_track.TrackId=tracks.TrackId
GROUP BY playlist_track.TrackId
ORDER BY 2 DESC
LIMIT 100;


--Which track generated the most revenue? 

SELECT 
	tracks.name,
	SUM(invoice_items.UnitPrice) AS 'Total Revenue'
FROM tracks
JOIN invoice_items
	ON tracks.TrackId=invoice_items.TrackId
GROUP BY tracks.TrackId
ORDER BY 2 DESC
LIMIT 10;


--Which album generated the most revenue? 

SELECT 
	albums.Title,
	SUM(invoice_items.UnitPrice) AS 'Total Revenue'
FROM invoice_items
JOIN tracks
	ON tracks.TrackId=invoice_items.TrackId
JOIN albums
	ON albums.AlbumId=tracks.AlbumId
GROUP BY albums.AlbumId
ORDER BY 2 DESC
LIMIT 10;


--Which genre generated the most revenue?

SELECT 
	genres.Name,
	ROUND(SUM(invoice_items.UnitPrice),2) AS 'Total Revenue'
FROM tracks
JOIN invoice_items
	ON tracks.TrackId=invoice_items.TrackId
JOIN genres
	ON genres.GenreId=tracks.GenreId
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;


--Which countries have the highest sales revenue?
-- What percent of total revenue does each country make up?

SELECT 
	invoices.BillingCountry,
	ROUND(SUM(invoices.Total),2) AS 'Total Revenue',
	ROUND(SUM(invoices.Total) * 100 /
	(SELECT SUM(invoices.Total) FROM invoices),2) AS 'Percent of Revenue'
FROM invoices
GROUP BY 1
ORDER BY 2 DESC;

--How many customers did each employee support?
--what is the average revenue for each sale, and what is their total sale?

SELECT
	employees.EmployeeId,
	employees.FirstName,
	employees.LastName,
	COUNT(customers.CustomerId) AS '# of Customers Supported',
	ROUND(AVG(invoices.Total),2) AS 'Average Revenue Per Sale',
	ROUND(SUM(invoices.Total),2) AS 'Total Sales'
FROM employees
JOIN customers
	ON employees.EmployeeId = customers.SupportRepId
JOIN invoices
	ON invoices.CustomerId = customers.CustomerId
GROUP BY 1;


--Do longer or shorter length albums tend to generate more revenue?

WITH album_length AS(
	SELECT 
	tracks.albumId AS 'AlbumId',
	COUNT(*) AS 'TrackCount'
FROM tracks
GROUP BY 1
)
SELECT 
	album_length.TrackCount AS 'Track Count',
	ROUND(SUM(invoice_items.UnitPrice),2) AS 'Total Revenue',
	COUNT(DISTINCT album_length.AlbumId) AS 'Total # of Albums',
	ROUND(SUM(invoice_items.UnitPrice)/COUNT(DISTINCT album_length.AlbumId),2) AS 'Average Revenue Per Album'
FROM invoice_items
JOIN tracks
	ON tracks.TrackId = invoice_items.TrackId
JOIN album_length
	ON album_length.AlbumId = tracks.AlbumId
GROUP BY 1;

	
--Is the number of times a track appear in any playlist a good indicator of sales?

WITH playlist_count AS (
	SELECT 
	playlist_track.TrackId AS 'TrackId',
	COUNT(*) AS 'pl_count'
	FROM playlist_track
	GROUP BY 1
	ORDER BY 2 DESC
)
SELECT 
	playlist_count.pl_count AS '# of Playlists',
	ROUND(SUM(invoice_items.UnitPrice)/COUNT(DISTINCT(playlist_count.TrackId)),2) AS 'Average Track Revenue'
FROM playlist_count
JOIN tracks
	ON playlist_count.TrackId = tracks.TrackId
JOIN invoice_items
	ON invoice_items.TrackId = tracks.TrackId
GROUP BY 1;

		
--How much revenue is generated each year, and what is its percent change from the previous year?


WITH revenue AS(
	SELECT 
		CAST(strftime('%Y', invoices.InvoiceDate) AS int)-1 AS 'PrevYear',
		CAST(strftime('%Y', invoices.InvoiceDate) AS int) AS 'ThisYear',
		ROUND(SUM(invoices.Total),2) AS 'TotalRevenue'
	FROM invoices
	GROUP BY 2
)
SELECT 
	cur.PrevYear,
	prev.TotalRevenue,
	cur.ThisYear,
	cur.TotalRevenue,
	ROUND((cur.TotalRevenue-prev.TotalRevenue) /
		prev.TotalRevenue * 100, 2) AS 'Percent Change from Previous Year'
FROM revenue cur
JOIN revenue prev
	ON prev.ThisYear = cur.PrevYear;

