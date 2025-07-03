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

/* **************************************************** *
    Migration / Transformation
 * ***************************************************** */
 -- table film has non-normalized column --> "special_feature"
 -- what to do:
  -- create table special_feature
  -- create table film_special_feature
  -- insert into special_feature
  -- insert into film_special_feature
  -- alter table film drop column special_feature

DROP TABLE IF EXISTS film_special_feature;
DROP TABLE IF EXISTS special_feature;

  -- create table special_feature
CREATE TABLE IF NOT EXISTS special_feature (
  special_feature_type SMALLINT,
  feature_type_name VARCHAR(50) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  CONSTRAINT pk_special_feature PRIMARY KEY (special_feature_type)
) ;

-- table 'film_special_feature' establishes many-to-many relationship between films and their special features
CREATE TABLE IF NOT EXISTS film_special_feature ( 
  film_id SMALLINT,
  special_feature_type SMALLINT,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  CONSTRAINT pk_film_special_feature PRIMARY KEY (film_id, special_feature_type),
  CONSTRAINT fk_film_special_feature_film FOREIGN KEY (film_id) REFERENCES film(film_id),
  CONSTRAINT fk_film_special_feature_special_feature FOREIGN KEY(special_feature_type) REFERENCES special_feature(special_feature_type)
) ;

  -- insert into special_feature
INSERT INTO special_feature
    VALUES (1,'Trailers')
          ,(2,'Commentaries')
          ,(3,'Deleted Scenes')
          ,(4,'Behind the Scenes')
;
COMMIT;

INSERT INTO film_special_feature 
SELECT film_id,  special_feature_type FROM (
  (SELECT film_id, 1 as special_feature_type
    FROM film
    WHERE special_features IS NOT NULL
      AND special_features LIKE '%Trailers%')
  UNION
  (SELECT film_id, 2 as special_feature_type
    FROM film
    WHERE special_features IS NOT NULL
      AND special_features LIKE '%Commentaries%')
  UNION
  (SELECT film_id, 3 as special_feature_type
    FROM film
    WHERE special_features IS NOT NULL
      AND special_features LIKE '%Deleted Scenes%')
  UNION
  (SELECT film_id, 4 as special_feature_type
    FROM film
    WHERE special_features IS NOT NULL
      AND special_features LIKE '%Behind the Scenes%')
);
COMMIT;

-- double-check that all films with special features have been inserted
SELECT film_id
  FROM film as f
 WHERE special_features IS NOT NULL
   AND NOT EXISTS ( SELECT * FROM film_special_feature
                     WHERE film_special_feature.film_id = f.film_id )
;
  
-- alter table film drop column special_feature
ALTER TABLE film DROP COLUMN special_features;
