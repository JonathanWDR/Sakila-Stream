-- Active: 1734903239123@@127.0.0.1@5432@uni_ddl_uebungen
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


DROP SCHEMA IF EXISTS sakila; --CASCADE; 
CREATE SCHEMA sakila;
SET search_path to sakila;

--
-- Table structure for table `actor`
--

CREATE TABLE actor (
  actor_id SMALLINT NOT NULL,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  constraint pk_actor PRIMARY KEY  (actor_id)
) ;

CREATE INDEX idx_actor_last_name ON actor (last_name);

--
-- Table structure for table `country`
--
CREATE TABLE country (
  country_id SMALLINT NOT NULL,
  country VARCHAR(50) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_country PRIMARY KEY  (country_id)
) ;
--
-- Table structure for table `city`
--
CREATE TABLE city (
  city_id SMALLINT NOT NULL,
  city VARCHAR(50) NOT NULL,
  country_id SMALLINT NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  constraint pk_city PRIMARY KEY (city_id),
  CONSTRAINT fk_city_country FOREIGN KEY (country_id) REFERENCES country (country_id) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE index idx_city_fk_country_id ON city (country_id);

--
-- Table structure for table `address`
--

CREATE TABLE address (
  address_id SMALLINT NOT NULL,
  address VARCHAR(50) NOT NULL,
  address2 VARCHAR(50) DEFAULT NULL,
  district VARCHAR(20) NOT NULL,
  city_id SMALLINT NOT NULL,
  postal_code VARCHAR(10) DEFAULT NULL,
  phone VARCHAR(20) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_address PRIMARY KEY (address_id),
  CONSTRAINT fk_address_city FOREIGN KEY (city_id) REFERENCES city (city_id) ON DELETE NO ACTION ON UPDATE CASCADE
) ;

CREATE INDEX idx_address_city_id ON address (city_id);

--
-- Table structure for table `store`
--

CREATE TABLE store (
  store_id SMALLINT NOT NULL,
  manager_staff_id SMALLINT NOT NULL,
  address_id SMALLINT,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  CONSTRAINT pk_store PRIMARY KEY  (store_id),
  CONSTRAINT fk_store_address FOREIGN KEY (address_id) REFERENCES address (address_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ;
CREATE INDEX idx_store_fk_address_id ON store (address_id);
--
-- Table structure for table `category`
--

CREATE TABLE category (
  category_id SMALLINT NOT NULL,
  name VARCHAR(25) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  constraint pk_category PRIMARY KEY  (category_id)
) ;

--
-- Table structure for table `language`
--

CREATE TABLE language (
  language_id SMALLINT NOT NULL,
  name CHAR(20) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_language PRIMARY KEY (language_id)
) ;

--
-- Table structure for table `customer`
--

CREATE TABLE customer (
  customer_id SMALLINT NOT NULL,
  store_id SMALLINT NOT NULL,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  email VARCHAR(50) DEFAULT NULL,
  address_id SMALLINT NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  create_date TIMESTAMP NOT NULL,
  last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ,
  CONSTRAINT pk_customer PRIMARY KEY  (customer_id),
  CONSTRAINT fk_customer_address FOREIGN KEY (address_id) REFERENCES address (address_id) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT fk_customer_store FOREIGN KEY (store_id) REFERENCES store (store_id) ON DELETE NO ACTION ON UPDATE CASCADE
) ;

CREATE INDEX idx_customer_fk_store_id ON customer (store_id);
CREATE INDEX idx_customer__fk_address_id ON customer (address_id);
CREATE INDEX idx_customer_last_name ON customer (last_name);

--
-- Table structure for table `film`
--

CREATE TABLE film (
  film_id SMALLINT NOT NULL ,
  title VARCHAR(128) NOT NULL,
  description TEXT DEFAULT NULL,
  release_year SMALLINT DEFAULT 1900 check (release_year >= 1850 and release_year <= 2155),
  language_id SMALLINT NOT NULL,
  original_language_id SMALLINT DEFAULT NULL,
  rental_duration SMALLINT NOT NULL DEFAULT 3,
  rental_rate DECIMAL(4,2) NOT NULL DEFAULT 4.99,
  length SMALLINT DEFAULT NULL,
  replacement_cost DECIMAL(5,2) NOT NULL DEFAULT 19.99,
  rating varchar(6) NOT NULL DEFAULT 'G',
  special_features varchar(60) DEFAULT '',
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  constraint pk_film PRIMARY KEY (film_id),
  CONSTRAINT chk_film_rating CHECK (rating IN('G','PG','PG-13','R','NC-17') ),
  CONSTRAINT fk_film_language FOREIGN KEY (language_id) REFERENCES language (language_id) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT fk_film_language_original FOREIGN KEY (original_language_id) REFERENCES language (language_id) ON DELETE NO ACTION ON UPDATE CASCADE
) ;

  CREATE INDEX idx_title ON film (title);
  CREATE INDEX idx_fk_language_id ON film (language_id);
  CREATE INDEX idx_fk_original_language_id ON film (original_language_id);

--
-- Table structure for table `film_actor`
--
CREATE TABLE film_actor (
  actor_id SMALLINT NOT NULL,
  film_id SMALLINT  NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  constraint pk_film_actor PRIMARY KEY  (actor_id,film_id),
  CONSTRAINT fk_film_actor_actor FOREIGN KEY (actor_id) REFERENCES actor (actor_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_film_actor_film FOREIGN KEY (film_id) REFERENCES film (film_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ;

  CREATE index idx_film_actor_film_id ON film_actor (film_id);

--
-- Table structure for table `film_category`
--

CREATE TABLE film_category (
  film_id SMALLINT NOT NULL,
  category_id SMALLINT  NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  constraint pk_film_category PRIMARY KEY (film_id, category_id),
  CONSTRAINT fk_film_category_film FOREIGN KEY (film_id) REFERENCES film (film_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_film_category_category FOREIGN KEY (category_id) REFERENCES category (category_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ;

--
-- Table structure for table `inventory`
--

CREATE TABLE inventory (
  inventory_id INTEGER NOT NULL,
  film_id SMALLINT  NOT NULL,
  store_id SMALLINT NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_inventory PRIMARY KEY  (inventory_id),
  CONSTRAINT fk_inventory_store FOREIGN KEY (store_id) REFERENCES store (store_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_inventory_film FOREIGN KEY (film_id) REFERENCES film (film_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ;

  CREATE INDEX idx_inv_film_id ON inventory (film_id);
  CREATE INDEX idx_inv_store_id_film_id ON inventory (store_id,film_id);

--
-- Table structure for table `staff`
--

CREATE TABLE staff (
  staff_id SMALLINT NOT NULL,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  address_id SMALLINT NOT NULL,
  email VARCHAR(50) DEFAULT NULL,
  store_id SMALLINT NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  username VARCHAR(16) NOT NULL,
  password VARCHAR(40) DEFAULT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  CONSTRAINT pk_staff PRIMARY KEY (staff_id),
  CONSTRAINT fk_staff_store FOREIGN KEY (store_id) REFERENCES store (store_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_staff_address FOREIGN KEY (address_id) REFERENCES address (address_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ;

-- after creation of the "staff" table, we can add foreign key constraint to "store" for manager_staff_id
-- however, it would be better to fill both tables with valid data before enforcing "cicling" foreign key constraints
/* ALTER TABLE store
  ADD CONSTRAINT fk_store_staff FOREIGN KEY (manager_staff_id) 
      REFERENCES staff (staff_id) ON DELETE RESTRICT ON UPDATE CASCADE;
*/

--
-- Table structure for table `rental`
--

CREATE TABLE rental (
  rental_id INTEGER NOT NULL ,
  rental_date TIMESTAMP NOT NULL,
  inventory_id INTEGER  NOT NULL,
  customer_id SMALLINT  NOT NULL,
  return_date TIMESTAMP DEFAULT NULL,
  staff_id SMALLINT NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_rental PRIMARY KEY (rental_id),
  CONSTRAINT uq_rental_date_inv UNIQUE (rental_date,inventory_id,customer_id),
  CONSTRAINT fk_rental_staff FOREIGN KEY (staff_id) REFERENCES staff (staff_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_rental_inventory FOREIGN KEY (inventory_id) REFERENCES inventory (inventory_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_rental_customer FOREIGN KEY (customer_id) REFERENCES customer (customer_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ;

  CREATE INDEX idx_rental_inventory_id ON rental (inventory_id);
  CREATE INDEX idx_rental_customer_id ON rental (customer_id);
  CREATE INDEX idx_rental_staff_id ON rental (staff_id);


--
-- Table structure for table `payment`
--

CREATE TABLE payment (
  payment_id INTEGER NOT NULL,
  customer_id SMALLINT NOT NULL,
  staff_id SMALLINT NOT NULL,
  rental_id INTEGER DEFAULT NULL,
  amount DECIMAL(5,2) NOT NULL,
  payment_date TIMESTAMP NOT NULL,
  last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ,
  CONSTRAINT pk_payment PRIMARY KEY  (payment_id),
  CONSTRAINT fk_payment_rental FOREIGN KEY (rental_id) REFERENCES rental (rental_id) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT fk_payment_customer FOREIGN KEY (customer_id) REFERENCES customer (customer_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_payment_staff FOREIGN KEY (staff_id) REFERENCES staff (staff_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ;

  CREATE INDEX idx_payment_staff_id ON payment (staff_id);
  CREATE INDEX idx_payment_customer_id ON payment (customer_id);



