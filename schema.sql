--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5 (Postgres.app)
-- Dumped by pg_dump version 17.5 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: sakila; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA sakila;


ALTER SCHEMA sakila OWNER TO postgres;

--
-- Name: tf_create_date(); Type: FUNCTION; Schema: sakila; Owner: postgres
--

CREATE FUNCTION sakila.tf_create_date() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
       NEW.create_date = current_timestamp;
       RETURN NEW;
END;
$$;


ALTER FUNCTION sakila.tf_create_date() OWNER TO postgres;

--
-- Name: tf_last_update(); Type: FUNCTION; Schema: sakila; Owner: postgres
--

CREATE FUNCTION sakila.tf_last_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
       NEW.last_update = current_timestamp;
       RETURN NEW;
END;
$$;


ALTER FUNCTION sakila.tf_last_update() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: content_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.content_type (
    content_type_id smallint NOT NULL,
    content_ty_name character varying(64) NOT NULL,
    additional_info character varying(255)
);


ALTER TABLE public.content_type OWNER TO postgres;

--
-- Name: actor; Type: TABLE; Schema: sakila; Owner: postgres
--

CREATE TABLE sakila.actor (
    actor_id smallint NOT NULL,
    first_name character varying(45) NOT NULL,
    last_name character varying(45) NOT NULL,
    last_update timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE sakila.actor OWNER TO postgres;

--
-- Name: address; Type: TABLE; Schema: sakila; Owner: postgres
--

CREATE TABLE sakila.address (
    address_id smallint NOT NULL,
    address character varying(50) NOT NULL,
    address2 character varying(50) DEFAULT NULL::character varying,
    district character varying(20) NOT NULL,
    city_id smallint NOT NULL,
    postal_code character varying(10) DEFAULT NULL::character varying,
    phone character varying(20) NOT NULL,
    last_update timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE sakila.address OWNER TO postgres;

--
-- Name: category; Type: TABLE; Schema: sakila; Owner: postgres
--

CREATE TABLE sakila.category (
    category_id smallint NOT NULL,
    name character varying(25) NOT NULL,
    last_update timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE sakila.category OWNER TO postgres;

--
-- Name: city; Type: TABLE; Schema: sakila; Owner: postgres
--

CREATE TABLE sakila.city (
    city_id smallint NOT NULL,
    city character varying(50) NOT NULL,
    country_id smallint NOT NULL,
    last_update timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE sakila.city OWNER TO postgres;

--
-- Name: country; Type: TABLE; Schema: sakila; Owner: postgres
--

CREATE TABLE sakila.country (
    country_id smallint NOT NULL,
    country character varying(50) NOT NULL,
    last_update timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE sakila.country OWNER TO postgres;

--
-- Name: customer; Type: TABLE; Schema: sakila; Owner: postgres
--

CREATE TABLE sakila.customer (
    customer_id smallint NOT NULL,
    store_id smallint NOT NULL,
    first_name character varying(45) NOT NULL,
    last_name character varying(45) NOT NULL,
    email character varying(50) DEFAULT NULL::character varying,
    address_id smallint NOT NULL,
    active boolean DEFAULT true NOT NULL,
    create_date timestamp without time zone NOT NULL,
    last_update timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE sakila.customer OWNER TO postgres;

--
-- Name: customer_list; Type: VIEW; Schema: sakila; Owner: postgres
--

CREATE VIEW sakila.customer_list AS
 SELECT cu.customer_id AS id,
    concat(cu.first_name, ' ', cu.last_name) AS name,
    a.address,
    a.postal_code AS zip_code,
    a.phone,
    city.city,
    country.country,
        CASE
            WHEN (cu.active = true) THEN 'active'::text
            ELSE ''::text
        END AS note,
    cu.store_id AS store
   FROM (((sakila.customer cu
     JOIN sakila.address a ON ((cu.address_id = a.address_id)))
     JOIN sakila.city ON ((a.city_id = city.city_id)))
     JOIN sakila.country ON ((city.country_id = country.country_id)));


ALTER VIEW sakila.customer_list OWNER TO postgres;

--
-- Name: film; Type: TABLE; Schema: sakila; Owner: postgres
--

CREATE TABLE sakila.film (
    film_id smallint NOT NULL,
    title character varying(128) NOT NULL,
    description text,
    release_year smallint DEFAULT 1900,
    language_id smallint NOT NULL,
    original_language_id smallint,
    rental_duration smallint DEFAULT 3 NOT NULL,
    rental_rate numeric(4,2) DEFAULT 4.99 NOT NULL,
    length smallint,
    replacement_cost numeric(5,2) DEFAULT 19.99 NOT NULL,
    rating character varying(6) DEFAULT 'G'::character varying NOT NULL,
    last_update timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_film_rating CHECK (((rating)::text = ANY ((ARRAY['G'::character varying, 'PG'::character varying, 'PG-13'::character varying, 'R'::character varying, 'NC-17'::character varying])::text[]))),
    CONSTRAINT film_release_year_check CHECK (((release_year >= 1850) AND (release_year <= 2155)))
);


ALTER TABLE sakila.film OWNER TO postgres;

--
-- Name: film_actor; Type: TABLE; Schema: sakila; Owner: postgres
--

CREATE TABLE sakila.film_actor (
    actor_id smallint NOT NULL,
    film_id smallint NOT NULL,
    last_update timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE sakila.film_actor OWNER TO postgres;

--
-- Name: film_category; Type: TABLE; Schema: sakila; Owner: postgres
--

CREATE TABLE sakila.film_category (
    film_id smallint NOT NULL,
    category_id smallint NOT NULL,
    last_update timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE sakila.film_category OWNER TO postgres;

--
-- Name: film_list; Type: VIEW; Schema: sakila; Owner: postgres
--

CREATE VIEW sakila.film_list AS
SELECT
    NULL::smallint AS fid,
    NULL::character varying(128) AS title,
    NULL::text AS description,
    NULL::character varying(25) AS category,
    NULL::numeric(4,2) AS price,
    NULL::smallint AS length,
    NULL::character varying(6) AS rating,
    NULL::text AS actors;


ALTER VIEW sakila.film_list OWNER TO postgres;

--
-- Name: film_special_feature; Type: TABLE; Schema: sakila; Owner: postgres
--

CREATE TABLE sakila.film_special_feature (
    film_id smallint NOT NULL,
    special_feature_type smallint NOT NULL,
    last_update timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE sakila.film_special_feature OWNER TO postgres;

--
-- Name: inventory; Type: TABLE; Schema: sakila; Owner: postgres
--

CREATE TABLE sakila.inventory (
    inventory_id integer NOT NULL,
    film_id smallint NOT NULL,
    store_id smallint NOT NULL,
    last_update timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE sakila.inventory OWNER TO postgres;

--
-- Name: language; Type: TABLE; Schema: sakila; Owner: postgres
--

CREATE TABLE sakila.language (
    language_id smallint NOT NULL,
    name character(20) NOT NULL,
    last_update timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE sakila.language OWNER TO postgres;

--
-- Name: payment; Type: TABLE; Schema: sakila; Owner: postgres
--

CREATE TABLE sakila.payment (
    payment_id integer NOT NULL,
    customer_id smallint NOT NULL,
    staff_id smallint NOT NULL,
    rental_id integer,
    amount numeric(5,2) NOT NULL,
    payment_date timestamp without time zone NOT NULL,
    last_update timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE sakila.payment OWNER TO postgres;

--
-- Name: rental; Type: TABLE; Schema: sakila; Owner: postgres
--

CREATE TABLE sakila.rental (
    rental_id integer NOT NULL,
    rental_date timestamp without time zone NOT NULL,
    inventory_id integer NOT NULL,
    customer_id smallint NOT NULL,
    return_date timestamp without time zone,
    staff_id smallint NOT NULL,
    last_update timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE sakila.rental OWNER TO postgres;

--
-- Name: sales_by_film_category; Type: VIEW; Schema: sakila; Owner: postgres
--

CREATE VIEW sakila.sales_by_film_category AS
 SELECT c.name AS category,
    sum(p.amount) AS total_sales
   FROM (((((sakila.payment p
     JOIN sakila.rental r ON ((p.rental_id = r.rental_id)))
     JOIN sakila.inventory i ON ((r.inventory_id = i.inventory_id)))
     JOIN sakila.film f ON ((i.film_id = f.film_id)))
     JOIN sakila.film_category fc ON ((f.film_id = fc.film_id)))
     JOIN sakila.category c ON ((fc.category_id = c.category_id)))
  GROUP BY c.name
  ORDER BY (sum(p.amount)) DESC;


ALTER VIEW sakila.sales_by_film_category OWNER TO postgres;

--
-- Name: staff; Type: TABLE; Schema: sakila; Owner: postgres
--

CREATE TABLE sakila.staff (
    staff_id smallint NOT NULL,
    first_name character varying(45) NOT NULL,
    last_name character varying(45) NOT NULL,
    address_id smallint NOT NULL,
    email character varying(50) DEFAULT NULL::character varying,
    store_id smallint NOT NULL,
    active boolean DEFAULT true NOT NULL,
    username character varying(16) NOT NULL,
    password character varying(40) DEFAULT NULL::character varying,
    last_update timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE sakila.staff OWNER TO postgres;

--
-- Name: store; Type: TABLE; Schema: sakila; Owner: postgres
--

CREATE TABLE sakila.store (
    store_id smallint NOT NULL,
    manager_staff_id smallint NOT NULL,
    address_id smallint,
    last_update timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE sakila.store OWNER TO postgres;

--
-- Name: sales_by_store; Type: VIEW; Schema: sakila; Owner: postgres
--

CREATE VIEW sakila.sales_by_store AS
 SELECT concat(c.city, ', ', cy.country) AS store,
    concat(m.first_name, ' ', m.last_name) AS manager,
    sum(p.amount) AS total_sales
   FROM (((((((sakila.payment p
     JOIN sakila.rental r ON ((p.rental_id = r.rental_id)))
     JOIN sakila.inventory i ON ((r.inventory_id = i.inventory_id)))
     JOIN sakila.store s ON ((i.store_id = s.store_id)))
     JOIN sakila.address a ON ((s.address_id = a.address_id)))
     JOIN sakila.city c ON ((a.city_id = c.city_id)))
     JOIN sakila.country cy ON ((c.country_id = cy.country_id)))
     JOIN sakila.staff m ON ((s.manager_staff_id = m.staff_id)))
  GROUP BY c.city, cy.country, s.store_id, m.first_name, m.last_name
  ORDER BY cy.country, c.city;


ALTER VIEW sakila.sales_by_store OWNER TO postgres;

--
-- Name: special_feature; Type: TABLE; Schema: sakila; Owner: postgres
--

CREATE TABLE sakila.special_feature (
    special_feature_type smallint NOT NULL,
    feature_type_name character varying(50) NOT NULL,
    last_update timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE sakila.special_feature OWNER TO postgres;

--
-- Name: staff_list; Type: VIEW; Schema: sakila; Owner: postgres
--

CREATE VIEW sakila.staff_list AS
 SELECT s.staff_id AS id,
    concat(s.first_name, ' ', s.last_name) AS name,
    a.address,
    a.postal_code AS "zip code",
    a.phone,
    city.city,
    country.country,
    s.store_id AS sid
   FROM (((sakila.staff s
     JOIN sakila.address a ON ((s.address_id = a.address_id)))
     JOIN sakila.city ON ((a.city_id = city.city_id)))
     JOIN sakila.country ON ((city.country_id = country.country_id)));


ALTER VIEW sakila.staff_list OWNER TO postgres;

--
-- Name: v_customer_fav_cat; Type: VIEW; Schema: sakila; Owner: postgres
--

CREATE VIEW sakila.v_customer_fav_cat AS
 SELECT cust.customer_id,
    cust.first_name,
    cust.last_name,
    cat.category_id,
    cat.name AS category_name,
    count(fc.film_id) AS sum_movies,
    dense_rank() OVER (PARTITION BY cust.customer_id ORDER BY (count(fc.film_id)) DESC) AS cat_rank
   FROM (((((sakila.customer cust
     JOIN sakila.rental rent ON ((cust.customer_id = rent.customer_id)))
     JOIN sakila.inventory i ON ((rent.inventory_id = i.inventory_id)))
     JOIN sakila.film f ON ((i.film_id = f.film_id)))
     JOIN sakila.film_category fc ON ((f.film_id = fc.film_id)))
     JOIN sakila.category cat ON ((fc.category_id = cat.category_id)))
  GROUP BY cust.customer_id, cust.first_name, cust.last_name, cat.category_id, cat.name
  ORDER BY cust.customer_id, (dense_rank() OVER (PARTITION BY cust.customer_id ORDER BY (count(fc.film_id)) DESC));


ALTER VIEW sakila.v_customer_fav_cat OWNER TO postgres;

--
-- Name: content_type pk_content_type; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.content_type
    ADD CONSTRAINT pk_content_type PRIMARY KEY (content_type_id);


--
-- Name: actor pk_actor; Type: CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.actor
    ADD CONSTRAINT pk_actor PRIMARY KEY (actor_id);


--
-- Name: address pk_address; Type: CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.address
    ADD CONSTRAINT pk_address PRIMARY KEY (address_id);


--
-- Name: category pk_category; Type: CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.category
    ADD CONSTRAINT pk_category PRIMARY KEY (category_id);


--
-- Name: city pk_city; Type: CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.city
    ADD CONSTRAINT pk_city PRIMARY KEY (city_id);


--
-- Name: country pk_country; Type: CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.country
    ADD CONSTRAINT pk_country PRIMARY KEY (country_id);


--
-- Name: customer pk_customer; Type: CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.customer
    ADD CONSTRAINT pk_customer PRIMARY KEY (customer_id);


--
-- Name: film pk_film; Type: CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.film
    ADD CONSTRAINT pk_film PRIMARY KEY (film_id);


--
-- Name: film_actor pk_film_actor; Type: CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.film_actor
    ADD CONSTRAINT pk_film_actor PRIMARY KEY (actor_id, film_id);


--
-- Name: film_category pk_film_category; Type: CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.film_category
    ADD CONSTRAINT pk_film_category PRIMARY KEY (film_id, category_id);


--
-- Name: film_special_feature pk_film_special_feature; Type: CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.film_special_feature
    ADD CONSTRAINT pk_film_special_feature PRIMARY KEY (film_id, special_feature_type);


--
-- Name: inventory pk_inventory; Type: CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.inventory
    ADD CONSTRAINT pk_inventory PRIMARY KEY (inventory_id);


--
-- Name: language pk_language; Type: CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.language
    ADD CONSTRAINT pk_language PRIMARY KEY (language_id);


--
-- Name: payment pk_payment; Type: CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.payment
    ADD CONSTRAINT pk_payment PRIMARY KEY (payment_id);


--
-- Name: rental pk_rental; Type: CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.rental
    ADD CONSTRAINT pk_rental PRIMARY KEY (rental_id);


--
-- Name: special_feature pk_special_feature; Type: CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.special_feature
    ADD CONSTRAINT pk_special_feature PRIMARY KEY (special_feature_type);


--
-- Name: staff pk_staff; Type: CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.staff
    ADD CONSTRAINT pk_staff PRIMARY KEY (staff_id);


--
-- Name: store pk_store; Type: CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.store
    ADD CONSTRAINT pk_store PRIMARY KEY (store_id);


--
-- Name: rental uq_rental_date_inv; Type: CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.rental
    ADD CONSTRAINT uq_rental_date_inv UNIQUE (rental_date, inventory_id, customer_id);


--
-- Name: idx_actor_last_name; Type: INDEX; Schema: sakila; Owner: postgres
--

CREATE INDEX idx_actor_last_name ON sakila.actor USING btree (last_name);


--
-- Name: idx_address_city_id; Type: INDEX; Schema: sakila; Owner: postgres
--

CREATE INDEX idx_address_city_id ON sakila.address USING btree (city_id);


--
-- Name: idx_city_fk_country_id; Type: INDEX; Schema: sakila; Owner: postgres
--

CREATE INDEX idx_city_fk_country_id ON sakila.city USING btree (country_id);


--
-- Name: idx_customer__fk_address_id; Type: INDEX; Schema: sakila; Owner: postgres
--

CREATE INDEX idx_customer__fk_address_id ON sakila.customer USING btree (address_id);


--
-- Name: idx_customer_fk_store_id; Type: INDEX; Schema: sakila; Owner: postgres
--

CREATE INDEX idx_customer_fk_store_id ON sakila.customer USING btree (store_id);


--
-- Name: idx_customer_last_name; Type: INDEX; Schema: sakila; Owner: postgres
--

CREATE INDEX idx_customer_last_name ON sakila.customer USING btree (last_name);


--
-- Name: idx_film_actor_film_id; Type: INDEX; Schema: sakila; Owner: postgres
--

CREATE INDEX idx_film_actor_film_id ON sakila.film_actor USING btree (film_id);


--
-- Name: idx_fk_language_id; Type: INDEX; Schema: sakila; Owner: postgres
--

CREATE INDEX idx_fk_language_id ON sakila.film USING btree (language_id);


--
-- Name: idx_fk_original_language_id; Type: INDEX; Schema: sakila; Owner: postgres
--

CREATE INDEX idx_fk_original_language_id ON sakila.film USING btree (original_language_id);


--
-- Name: idx_inv_film_id; Type: INDEX; Schema: sakila; Owner: postgres
--

CREATE INDEX idx_inv_film_id ON sakila.inventory USING btree (film_id);


--
-- Name: idx_inv_store_id_film_id; Type: INDEX; Schema: sakila; Owner: postgres
--

CREATE INDEX idx_inv_store_id_film_id ON sakila.inventory USING btree (store_id, film_id);


--
-- Name: idx_payment_customer_id; Type: INDEX; Schema: sakila; Owner: postgres
--

CREATE INDEX idx_payment_customer_id ON sakila.payment USING btree (customer_id);


--
-- Name: idx_payment_staff_id; Type: INDEX; Schema: sakila; Owner: postgres
--

CREATE INDEX idx_payment_staff_id ON sakila.payment USING btree (staff_id);


--
-- Name: idx_rental_customer_id; Type: INDEX; Schema: sakila; Owner: postgres
--

CREATE INDEX idx_rental_customer_id ON sakila.rental USING btree (customer_id);


--
-- Name: idx_rental_inventory_id; Type: INDEX; Schema: sakila; Owner: postgres
--

CREATE INDEX idx_rental_inventory_id ON sakila.rental USING btree (inventory_id);


--
-- Name: idx_rental_staff_id; Type: INDEX; Schema: sakila; Owner: postgres
--

CREATE INDEX idx_rental_staff_id ON sakila.rental USING btree (staff_id);


--
-- Name: idx_store_fk_address_id; Type: INDEX; Schema: sakila; Owner: postgres
--

CREATE INDEX idx_store_fk_address_id ON sakila.store USING btree (address_id);


--
-- Name: idx_title; Type: INDEX; Schema: sakila; Owner: postgres
--

CREATE INDEX idx_title ON sakila.film USING btree (title);


--
-- Name: film_list _RETURN; Type: RULE; Schema: sakila; Owner: postgres
--

CREATE OR REPLACE VIEW sakila.film_list AS
 SELECT film.film_id AS fid,
    film.title,
    film.description,
    category.name AS category,
    film.rental_rate AS price,
    film.length,
    film.rating,
    string_agg(concat(actor.first_name, ' ', actor.last_name), ', '::text) AS actors
   FROM ((((sakila.film
     LEFT JOIN sakila.film_category ON ((film_category.film_id = film.film_id)))
     LEFT JOIN sakila.category ON ((category.category_id = film_category.category_id)))
     LEFT JOIN sakila.film_actor ON ((film.film_id = film_actor.film_id)))
     LEFT JOIN sakila.actor ON ((film_actor.actor_id = actor.actor_id)))
  GROUP BY film.film_id, category.name;


--
-- Name: actor tr_actor_last_update; Type: TRIGGER; Schema: sakila; Owner: postgres
--

CREATE TRIGGER tr_actor_last_update BEFORE UPDATE ON sakila.actor FOR EACH ROW EXECUTE FUNCTION sakila.tf_last_update();


--
-- Name: film tr_customer_create_date; Type: TRIGGER; Schema: sakila; Owner: postgres
--

CREATE TRIGGER tr_customer_create_date BEFORE UPDATE ON sakila.film FOR EACH ROW EXECUTE FUNCTION sakila.tf_create_date();


--
-- Name: customer tr_customer_last_update; Type: TRIGGER; Schema: sakila; Owner: postgres
--

CREATE TRIGGER tr_customer_last_update BEFORE UPDATE ON sakila.customer FOR EACH ROW EXECUTE FUNCTION sakila.tf_last_update();


--
-- Name: film tr_film_last_update; Type: TRIGGER; Schema: sakila; Owner: postgres
--

CREATE TRIGGER tr_film_last_update BEFORE UPDATE ON sakila.film FOR EACH ROW EXECUTE FUNCTION sakila.tf_last_update();


--
-- Name: address fk_address_city; Type: FK CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.address
    ADD CONSTRAINT fk_address_city FOREIGN KEY (city_id) REFERENCES sakila.city(city_id) ON UPDATE CASCADE;


--
-- Name: city fk_city_country; Type: FK CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.city
    ADD CONSTRAINT fk_city_country FOREIGN KEY (country_id) REFERENCES sakila.country(country_id) ON UPDATE CASCADE;


--
-- Name: customer fk_customer_address; Type: FK CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.customer
    ADD CONSTRAINT fk_customer_address FOREIGN KEY (address_id) REFERENCES sakila.address(address_id) ON UPDATE CASCADE;


--
-- Name: customer fk_customer_store; Type: FK CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.customer
    ADD CONSTRAINT fk_customer_store FOREIGN KEY (store_id) REFERENCES sakila.store(store_id) ON UPDATE CASCADE;


--
-- Name: film_actor fk_film_actor_actor; Type: FK CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.film_actor
    ADD CONSTRAINT fk_film_actor_actor FOREIGN KEY (actor_id) REFERENCES sakila.actor(actor_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: film_actor fk_film_actor_film; Type: FK CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.film_actor
    ADD CONSTRAINT fk_film_actor_film FOREIGN KEY (film_id) REFERENCES sakila.film(film_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: film_category fk_film_category_category; Type: FK CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.film_category
    ADD CONSTRAINT fk_film_category_category FOREIGN KEY (category_id) REFERENCES sakila.category(category_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: film_category fk_film_category_film; Type: FK CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.film_category
    ADD CONSTRAINT fk_film_category_film FOREIGN KEY (film_id) REFERENCES sakila.film(film_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: film fk_film_language; Type: FK CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.film
    ADD CONSTRAINT fk_film_language FOREIGN KEY (language_id) REFERENCES sakila.language(language_id) ON UPDATE CASCADE;


--
-- Name: film fk_film_language_original; Type: FK CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.film
    ADD CONSTRAINT fk_film_language_original FOREIGN KEY (original_language_id) REFERENCES sakila.language(language_id) ON UPDATE CASCADE;


--
-- Name: film_special_feature fk_film_special_feature_film; Type: FK CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.film_special_feature
    ADD CONSTRAINT fk_film_special_feature_film FOREIGN KEY (film_id) REFERENCES sakila.film(film_id);


--
-- Name: film_special_feature fk_film_special_feature_special_feature; Type: FK CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.film_special_feature
    ADD CONSTRAINT fk_film_special_feature_special_feature FOREIGN KEY (special_feature_type) REFERENCES sakila.special_feature(special_feature_type);


--
-- Name: inventory fk_inventory_film; Type: FK CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.inventory
    ADD CONSTRAINT fk_inventory_film FOREIGN KEY (film_id) REFERENCES sakila.film(film_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: inventory fk_inventory_store; Type: FK CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.inventory
    ADD CONSTRAINT fk_inventory_store FOREIGN KEY (store_id) REFERENCES sakila.store(store_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: payment fk_payment_customer; Type: FK CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.payment
    ADD CONSTRAINT fk_payment_customer FOREIGN KEY (customer_id) REFERENCES sakila.customer(customer_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: payment fk_payment_rental; Type: FK CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.payment
    ADD CONSTRAINT fk_payment_rental FOREIGN KEY (rental_id) REFERENCES sakila.rental(rental_id) ON UPDATE CASCADE;


--
-- Name: payment fk_payment_staff; Type: FK CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.payment
    ADD CONSTRAINT fk_payment_staff FOREIGN KEY (staff_id) REFERENCES sakila.staff(staff_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: rental fk_rental_customer; Type: FK CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.rental
    ADD CONSTRAINT fk_rental_customer FOREIGN KEY (customer_id) REFERENCES sakila.customer(customer_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: rental fk_rental_inventory; Type: FK CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.rental
    ADD CONSTRAINT fk_rental_inventory FOREIGN KEY (inventory_id) REFERENCES sakila.inventory(inventory_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: rental fk_rental_staff; Type: FK CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.rental
    ADD CONSTRAINT fk_rental_staff FOREIGN KEY (staff_id) REFERENCES sakila.staff(staff_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: staff fk_staff_address; Type: FK CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.staff
    ADD CONSTRAINT fk_staff_address FOREIGN KEY (address_id) REFERENCES sakila.address(address_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: staff fk_staff_store; Type: FK CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.staff
    ADD CONSTRAINT fk_staff_store FOREIGN KEY (store_id) REFERENCES sakila.store(store_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: store fk_store_address; Type: FK CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.store
    ADD CONSTRAINT fk_store_address FOREIGN KEY (address_id) REFERENCES sakila.address(address_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: store fk_store_staff; Type: FK CONSTRAINT; Schema: sakila; Owner: postgres
--

ALTER TABLE ONLY sakila.store
    ADD CONSTRAINT fk_store_staff FOREIGN KEY (manager_staff_id) REFERENCES sakila.staff(staff_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

