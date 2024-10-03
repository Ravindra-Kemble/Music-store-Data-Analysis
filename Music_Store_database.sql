-- Who is the senior most employee based on job title?

SELECT * FROM employee
order by levels desc
limit 1

-- Which countries have the most Invoices?

Select count(*) as c, billing_country
from invoice
group by billing_country
order by c desc

-- What are top 3 values of total invoice?

Select total from invoice
order by total desc
limit 3

-- which city has the best customers? we would like to throw a promotional music festival in the city 
-- we made the most money. Write a query that returns one city that has the highest 
-- sum 0f invoice totals. return both the city and sum of all invoice totals

Select sum(total) as s, billing_city from invoice
group by billing_city
order by s desc
limit 1

-- who is the best customer? The customer who has spent the most money will be
-- declared the best customer. write a query that return the person who has spent the most money

Select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
from customer
JOIN invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1

-- write query to return the email, first name, last name, and genre of all rock music listeners.
-- return tour list ordered alphabetically by email starting with A

select * from genre

select Distinct email, first_name, last_name 
from customer
JOIN invoice on customer.customer_id = invoice.customer_id
JOIN invoice_line on invoice_line.invoice_id = invoice.invoice_id
Where track_id in(
    Select track_id from track
	Join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock'
)
order by email;

-- lets invite the artists who have written the most rock music in our dataset,
-- write a query that returns the artist name and total track count of the top
-- rocks bands

Select artist.artist_id, artist.name, count(artist.artist_id) as num_of_songs
from track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by num_of_songs desc


-- Return all the track names that have a song lenght than the average song length.
-- Return the name and Milliseconds for each track .Order by the song length with the longest 
-- songs listed first

Select name, milliseconds from track
where milliseconds > (
	select AVG(milliseconds) as Avg_track_lenght
	from track
)
order by milliseconds desc;

-- Find how much amount spent by each customer on astists? write a 
-- query to return customer name, astist name and total spent

with best_selling_artist as(
	SELECT artist.artist_id as artist_id, artist.name as artist_name,
	sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
	From invoice_line
	JOIN track On track.track_id = invoice_line.invoice_id
	JOIN album on album.album_id = track.album_id
	JOIN artist on artist.artist_id = album.artist_id
	group by 1
	order by 3 desc
	limit 1
)

SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
sum(il.unit_price*il.quantity) as amount_spent
from invoice i
JOIN customer c On c.customer_id = i.customer_id
JOIN invoice_line il on il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.invoice_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
group by 1,2,3,4
Order by 5 Desc

-- We want to find out the most popular music Genre for each country. We determined the most
-- popular genre as the genre with the highest amount of purchases.write a query that returns each country
-- along with the top Genre. For countries where the maximum number of purchases is shared return 
-- all Genres


with popular_genres as (
	Select count(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id,
	ROW_NUMBER() OVER(PARTITION BY customer.country order by count(invoice_line.quantity) Desc) as RowNo
	From Invoice_line
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	Group by 2, 3, 4
	order by 2 asc, 1 desc
)
SELECT * FROM popular_genres Where RowNo <= 1

-- Write a query that determines the customer that has spent the most on music for each country.
-- Write a query that returns the country along with the top customer and how much they spent. for
-- countries where the top amount spent is shared, provide all customers who spent his amount.


With RECURSIVE 
	customer_with_country as (
		SELECT customer.customer_id, customer.first_name,last_name,billing_country, Sum(total) as total_spending
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		Group by 1,2,3,4
		order by 5 desc),
	
	country_max_spending as (
		SELECT billing_country, max(total_spending) as max_spending
		From customer_with_country
		group by billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name
from customer_with_country cc
JOIN country_max_spending ms
On cc.billing_country = ms.billing_country
where cc.total_spending = ms.max_spending
order by 1;
