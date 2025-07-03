-- Active: 1734903239123@@127.0.0.1@5432@uni_ddl_uebungen@sakila
-- Sakila Sample Database Schema
-- Version 1.5

-- Copyright (c) 2006, 2025, Oracle and/or its affiliates.

-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are
-- met:

-- * Redistributions of source code must retain the above copyright notice,
--   this list of conditions and the following disclaimer.
-- * Redistributions in binary form must reproduce the above copyright
--   notice, this list of conditions and the following disclaimer in the
--   documentation and/or other materials provided with the distribution.
-- * Neither the name of Oracle nor the names of its contributors may be used
--   to endorse or promote products derived from this software without
--   specific prior written permission.

-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
-- IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
-- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
-- EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
-- PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
-- LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
-- NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

SET search_path to sakila;

/* **************************************************************************************** 
 Views
  **************************************************************************************** */ 
--
-- View structure for view `customer_list`
--
CREATE VIEW customer_list
AS
SELECT cu.customer_id AS ID, CONCAT(cu.first_name, ' ', cu.last_name) AS name, a.address AS address, a.postal_code AS zip_code,
	a.phone AS phone, city.city AS city, country.country AS country, 
  CASE WHEN cu.active = true THEN 'active' ELSE '' END AS note,
  cu.store_id AS store
  FROM customer AS cu 
  JOIN address AS a ON cu.address_id = a.address_id 
  JOIN city ON a.city_id = city.city_id
  JOIN country ON city.country_id = country.country_id
;
--
-- View structure for view `film_list`
--
-- PostgreSQL-specific syntax for string aggregation 
CREATE VIEW film_list
AS
SELECT film.film_id AS FID, film.title AS title, film.description AS description, category.name AS category,
 film.rental_rate AS price,	film.length AS length, film.rating AS rating, 
  STRING_AGG(CONCAT(actor.first_name, ' ', actor.last_name), ', ') AS actors
FROM film
LEFT JOIN film_category ON film_category.film_id = film.film_id
LEFT JOIN category ON category.category_id = film_category.category_id 
LEFT JOIN film_actor ON film.film_id = film_actor.film_id LEFT JOIN actor ON
  film_actor.actor_id = actor.actor_id
GROUP BY film.film_id, category.name;



--
-- View structure for view `staff_list`
--
CREATE VIEW staff_list
AS
SELECT s.staff_id AS ID, CONCAT(s.first_name, ' ', s.last_name) AS name, a.address AS address, a.postal_code AS "zip code", a.phone AS phone,
	city.city AS city, country.country AS country, s.store_id AS SID
FROM staff AS s 
JOIN address AS a ON s.address_id = a.address_id 
JOIN city ON a.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
;

--
-- View structure for view `sales_by_store`
--
CREATE VIEW sales_by_store
AS
SELECT CONCAT(c.city, ', ', cy.country) AS store
, CONCAT(m.first_name, ' ', m.last_name) AS manager
, SUM(p.amount) AS total_sales
FROM payment AS p
INNER JOIN rental AS r ON p.rental_id = r.rental_id
INNER JOIN inventory AS i ON r.inventory_id = i.inventory_id
INNER JOIN store AS s ON i.store_id = s.store_id
INNER JOIN address AS a ON s.address_id = a.address_id
INNER JOIN city AS c ON a.city_id = c.city_id
INNER JOIN country AS cy ON c.country_id = cy.country_id
INNER JOIN staff AS m ON s.manager_staff_id = m.staff_id
GROUP BY c.city, cy.country, s.store_id, m.first_name, m.last_name
ORDER BY cy.country, c.city
;

--
-- View structure for view `sales_by_film_category`
--
-- Note that total sales will add up to >100% because
-- some titles belong to more than 1 category
--

CREATE VIEW sales_by_film_category
AS
SELECT
c.name AS category
, SUM(p.amount) AS total_sales
FROM payment AS p
INNER JOIN rental AS r ON p.rental_id = r.rental_id
INNER JOIN inventory AS i ON r.inventory_id = i.inventory_id
INNER JOIN film AS f ON i.film_id = f.film_id
INNER JOIN film_category AS fc ON f.film_id = fc.film_id
INNER JOIN category AS c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY total_sales DESC;


-- view to get favorite category per customer
CREATE OR REPLACE VIEW v_customer_fav_cat AS
SELECT 
  cust.customer_id, 
  cust.first_name, 
  cust.last_name, 
  cat.category_id, 
  cat.name AS category_name,
  COUNT(fc.film_id) AS sum_movies,
  DENSE_RANK() OVER (PARTITION BY cust.customer_id ORDER BY count(fc.film_id) DESC) AS cat_rank
  FROM customer AS cust
  INNER JOIN rental AS rent ON cust.customer_id = rent.customer_id
  INNER JOIN inventory AS i ON rent.inventory_id = i.inventory_id
  INNER JOIN film AS f ON i.film_id = f.film_id 
  INNER JOIN film_category AS fc ON f.film_id = fc.film_id
  INNER JOIN category AS cat ON fc.category_id = cat.category_id
  GROUP BY 1, 2, 3, 4, 5
  ORDER BY cust.customer_id ASC
         , cat_rank ASC
 ;

-- testing the view to get favorite category per customer
SELECT customer_id, last_name, category_name, sum_movies, cat_rank
  FROM v_customer_fav_cat
  WHERE cat_rank = 1
    AND customer_id BETWEEN 1 and 10
 ;
