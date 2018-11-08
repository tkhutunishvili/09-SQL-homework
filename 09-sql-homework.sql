USE sakila;
-- 1a. Display the first and last names of all actors from the table actor.
SELECT 
    first_name, last_name
FROM
    actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT 
    UPPER(CONCAT(a.first_name, ' ', a.last_name)) AS 'Actor Name'
FROM
    actor a;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    first_name LIKE 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT 
    *
FROM
    actor
WHERE
    last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT 
    *
FROM
    actor
WHERE
    last_name LIKE '%LI%'
ORDER BY last_name AND first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT 
    country_id, country
FROM
    country
WHERE
    country IN ('Afghanistan' , 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

ALTER TABLE actor ADD description BLOB;
select * from actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor DROP description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT 
    last_name, COUNT(last_name) AS 'Last Name Count'
FROM
    actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor 
SET 
    first_name = 'HARPO'
WHERE
    first_name = 'GROUCHO'
        AND last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor 
SET 
    first_name = 'GROUCHO'
WHERE
    first_name = 'HARPO'
        AND last_name = 'WILLIAMS';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
show create table address;
describe address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT 
    staff.first_name, staff.last_name, address.address
FROM
    staff
        INNER JOIN
    address ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT 
    staff.first_name, SUM(payment.amount) AS 'Total Amount'
FROM
    staff
        INNER JOIN
    payment ON staff.staff_id = payment.staff_id
WHERE
    payment_date LIKE '2005-08%'
GROUP BY first_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT 
    film.title, COUNT(film_actor.film_id) AS 'Number of Actors'
FROM
    film
        INNER JOIN
    film_actor ON film.film_id = film_actor.film_id
GROUP BY title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT 
    film.title, COUNT(inventory.inventory_id) AS 'Copies'
FROM
    film
        INNER JOIN
    inventory ON film.film_id = inventory.film_id
WHERE
    title = 'Hunchback Impossible'
GROUP BY title;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT 
    c.first_name, c.last_name, SUM(p.amount) AS 'Total Paid'
FROM
    customer c
        INNER JOIN
    payment p ON c.customer_id = p.customer_id
GROUP BY first_name,last_name
ORDER BY last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT 
    title,
    (SELECT 
            name
        FROM
            language
        WHERE
            film.language_id = language.language_id) as 'Language'
FROM 
    film
WHERE
    title LIKE 'K%' OR title LIKE 'Q%';

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name,last_name from actor where actor_id in
(
select actor_id from film_actor where film_id in
(select film_id from film where title = 'Alone Trip')
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select c.first_name, c.last_name, c.email 
from customer c
inner join address a on a.address_id = c.address_id
inner join city ct on ct.city_id = a.city_id
inner join country cr on cr.country_id = ct.country_id where cr.country='canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select title from film where film_id in
(
select film_id from film_category where category_id in
(select category_id from category where name='Family')
);

-- 7e. Display the most frequently rented movies in descending order.
select f.title, r.rental_date from film f
inner join inventory i on i.film_id=f.film_id
inner join rental r on r.inventory_id=i.inventory_id
order by rental_date desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select sum(p.amount) as 'Total Amount', i.store_id from payment p
inner join rental r on r.rental_id=p.rental_id
inner join inventory i on i.inventory_id=r.inventory_id
group by i.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id, ct.city,  cr.country from country cr
inner join city ct on ct.country_id=cr.country_id
inner join address a on a.city_id=ct.city_id
inner join store s on s.address_id=a.address_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select c.name, sum(p.amount) as 'Total' from category c 
inner join film_category f on f.category_id=c.category_id
inner join inventory i on i.film_id=f.film_id
inner join rental r on r.inventory_id=i.inventory_id
inner join payment p on p.rental_id=r.rental_id
group by name 
order by Total desc;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
-- 8b. How would you display the view that you created in 8a?
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.


