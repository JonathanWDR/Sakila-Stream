SET search_path TO sakila;


Drop table if exists staff cascade;

drop table if exists inventory cascade;

drop table if exists store cascade;

drop table if exists rental cascade;

drop table if exists film_actor;

drop table if exists film_category;

drop table if exists film_special_feature;



alter table payment
drop column rental_id,
drop column staff_id,
drop column customer_id,
drop column amount;

alter table customer
DROP COLUMN if exists store_id cascade;