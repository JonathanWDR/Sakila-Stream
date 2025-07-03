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

-- Active: 1734903239123@@127.0.0.1@5432@uni_ddl_uebungen@sakila
/* **************************************************************************************** 
 Trigger Function
  **************************************************************************************** */ 
DROP TRIGGER IF EXISTS tr_actor_last_update ON actor;
DROP TRIGGER IF EXISTS tr_customer_last_update ON customer;
DROP TRIGGER IF EXISTS tr_film_last_update ON film;  
DROP FUNCTION IF EXISTS tf_last_update;

DROP FUNCTION IF EXISTS tf_create_date;

CREATE OR REPLACE FUNCTION tf_last_update( ) 
RETURNS trigger AS $$
BEGIN
       NEW.last_update = current_timestamp;
       RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION tf_create_date( ) 
RETURNS trigger AS $$
BEGIN
       NEW.create_date = current_timestamp;
       RETURN NEW;
END;
$$ LANGUAGE plpgsql;

/* **************************************************************************************** 
 Trigger
  **************************************************************************************** */ 

CREATE TRIGGER tr_actor_last_update
  BEFORE UPDATE ON actor  
    FOR EACH ROW 
    EXECUTE function tf_last_update();
  
CREATE TRIGGER tr_customer_last_update
  BEFORE UPDATE ON customer 
    FOR EACH ROW 
    EXECUTE function tf_last_update();

CREATE TRIGGER tr_film_last_update
  BEFORE UPDATE ON film
    FOR EACH ROW 
    EXECUTE function tf_last_update();

--
-- Trigger to enforce create dates on INSERT
--
CREATE TRIGGER tr_customer_create_date
  BEFORE UPDATE ON film
    FOR EACH ROW 
    EXECUTE function tf_create_date();
