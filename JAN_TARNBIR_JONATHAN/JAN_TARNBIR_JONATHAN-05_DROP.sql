SET search_path TO sakila;


DROP TABLE IF EXISTS staff CASCADE;

DROP TABLE IF EXISTS  inventory CASCADE;

DROP TABLE IF EXISTS  store CASCADE;

DROP TABLE IF EXISTS  rental CASCADE;

DROP TABLE IF EXISTS  film_actor;

DROP TABLE IF EXISTS film_category;

DROP TABLE IF EXISTS  film_special_feature;



ALTER TABLE payment
DROP COLUMN rental_id,
DROP COLUMN staff_id,
DROP COLUMN customer_id,
DROP COLUMN amount;

ALTER TABLE customer
DROP COLUMN IF EXISTS store_id CASCADE;
