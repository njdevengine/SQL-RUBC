-- Homework Assignment 06-SQL
USE sakila;
-- 1a. Display the first and last names of all actors from the table `actor`.
SELECT actor.first_name, actor.last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT actor.first_name, actor.last_name , CONCAT(UPPER(actor.first_name) ,' ',UPPER( actor.last_name)) AS ActorName
FROM actor;


-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE 
first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters `GEN`
SELECT *
FROM actor
WHERE 
last_name LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order
SELECT *
FROM actor
WHERE 
last_name LIKE "%LI%"
ORDER BY last_name, first_name;

-- Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China
SELECT country_id, country
FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");


-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD COLUMN DESCRIPTION blob AFTER last_name;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
DROP column DESCRIPTION;

-- 4a. List the last names of actors, as well as how many actors have that last name
SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY(last_name);

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY(last_name)
HAVING COUNT(last_name) > 1;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE  actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO";

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

CREATE TABLE
IF NOT EXISTS `address`
(
  `address_id` SMALLINT
(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` VARCHAR
(50) NOT NULL,
  `address2` VARCHAR
(50) DEFAULT NULL,
  `district` VARCHAR
(20) NOT NULL,
  `city_id` SMALLINT
(5) unsigned NOT NULL,
  `postal_code` VARCHAR
(10) DEFAULT NULL,
  `phone` VARCHAR
(20) NOT NULL,
  `location` GEOMETRY NOT NULL,
  `last_update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON
UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY
(`address_id`),
  KEY `idx_fk_city_id`
(`city_id`),
  SPATIAL KEY `idx_location`
(`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY
(`city_id`) REFERENCES `city`
(`city_id`) ON
UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET
=utf8;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`
SELECT first_name, last_name, address.address
FROM
    staff JOIN address ON staff.address_id = address.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT staff.staff_id, first_name, last_name, sum(amount)
FROM staff JOIN payment ON staff.staff_id = payment.staff_id
GROUP BY staff.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT film.film_id, film.title, film.release_year, count(actor_id) AS Number_of_Actors
FROM film JOIN film_actor ON film_actor.film_id = film.film_id
GROUP BY (film.film_id);

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT film.title, count(inventory.inventory_id) AS Number_of_Copies
FROM inventory JOIN film ON inventory.film_id = film.film_id
WHERE film.title = "Hunchback Impossible";

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name
SELECT payment.customer_id, concat(first_name,' ', customer.last_name) AS customer_name, sum(amount)
FROM
    payment JOIN customer ON payment.customer_id = customer.customer_id
GROUP BY customer_id;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT *
FROM film
WHERE
title IN (SELECT title
FROM film
WHERE (title LIKE "K%" OR title LIKE "Q%") AND (language_id = 1));

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT *
FROM film join film_actor
    ON film.film_id = film_actor.film_id
WHERE film.title in (SELECT title
FROM film
WHERE
film.title = "Alone Trip");

-- You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT *
FROM customer JOIN address
    ON customer.address_id = address.address_id
WHERE
city_id IN (SELECT city_id
FROM city JOIN country ON city.country_id = country.country_id
WHERE country.country_id IN (SELECT country_id
FROM country
WHERE country = "Canada"))
;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT *
FROM film JOIN film_category
    ON film.film_id = film_category.film_id
WHERE category_id IN (SELECT category_id
FROM category
WHERE category.name = "Family");

-- 7e. Display the most frequently rented movies in descending order.
SELECT film.title, count(*) AS times_rented
FROM sakila.rental JOIN film
    ON film.film_id = rental.inventory_id
GROUP BY inventory_id
ORDER BY times_rented DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store_id, sum(amount) AS total_sales
FROM payment JOIN staff
    ON payment.staff_id = staff.staff_id
WHERE store_id IN 
(SELECT store.store_id
FROM staff JOIN store
    ON store.store_id = staff.store_id )
group by store_id;

--  7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, country, city
FROM country
    JOIN city ON country.country_id = city.country_id
    JOIN address ON address.city_id = city.city_id
    JOIN store ON store.address_id = address.address_id;

-- 7h. List the top five genres in gross revenue in descending order.
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT category.category_id, name, sum(amount) AS category_revenue
FROM rental
    JOIN payment ON payment.rental_id = rental.rental_id
    JOIN inventory ON inventory.inventory_id = rental.inventory_id
    JOIN film_category ON film_category.film_id = inventory.film_id
    JOIN category ON category.category_id = film_category.category_id
GROUP BY category_id
ORDER BY category_revenue DESC
LIMIT 5;
                             
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_five_films AS (
SELECT category.name AS 'Top 5 Genres', sum(payment.amount) as 'Total Revenue'
FROM category
JOIN film_category ON category.category_id = film_category.category_id
JOIN inventory ON film_category.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY category.name
ORDER BY sum(payment.amount) LIMIT 5);
                             
-- 8b. How would you display the view that you created in 8a?
SELECT *
FROM top_5_geners;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW IF EXISTS
    top_5_geners;
