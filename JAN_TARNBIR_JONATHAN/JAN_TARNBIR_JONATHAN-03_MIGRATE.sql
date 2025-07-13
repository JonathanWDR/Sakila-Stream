SET search_path TO sakila;

-- mustn't be executed multiple times (results in duplicates)




-- filme -> content
CREATE EXTENSION IF NOT EXISTS pgcrypto; -- for random uuid generation

INSERT INTO content_stream
  (content_id,
   content_type_id,
   title,
   release_year,
   original_language_id,
   length,
   stream_uuid)
SELECT
   film_id,
   (SELECT content_type_id FROM content_type WHERE content_ty_name = 'Film'),
   title,
   release_year,
   original_language_id,
   length,
   gen_random_uuid() -- nach Aufg. 1: "Der Streamingdienstleister richtet sich nach unseren UUIDs".
FROM film;


-- Customer migration -> srv_customer_allocation
	INSERT INTO SRV_CUSTOMER_ALLOCATION (
	    srv_cust_alloc_id,
	    service_type_id,
	    srv_reference_id,
	    customer_id,
	    video_quality,
	    start_date,
	    end_date,
	    active,
	    last_update
	)
	SELECT
	    ROW_NUMBER() OVER () AS srv_cust_alloc_id,
	    -- Get service type ID for 'Subscription'
	    (
	        SELECT t.service_type_id
	        FROM service_type AS t
	        WHERE t.service_type_name = 'Subscription'
	    ) AS service_type_id,
	    -- Get subscription ID for 'Free Trial'
	    (
	        SELECT s.subscr_id
	        FROM subscription AS s
	        WHERE s.subscr_name = 'Free Trial'
	    ) AS srv_reference_id,
	    -- Active customers
	    c.customer_id,
	    -- Get video quality ID for 'SD'
	    (
	        SELECT v.video_quality_id
	        FROM video_quality AS v
	        WHERE v.vidquality_label = 'SD'
	    ) AS video_quality,
	    CURRENT_TIMESTAMP AS start_date,
	    CURRENT_TIMESTAMP + INTERVAL '30 days' AS end_date,
	    TRUE AS active,
	    CURRENT_TIMESTAMP AS last_update
	FROM customer AS c
	WHERE c.active = TRUE;





-- migrate rental data -> customer watch activity        - mustn't be executed multiple times (results in duplicates)

	INSERT INTO cust_watch_act (
		cust_watch_act_id,
	    customer_id,
	    content_id,
	    start_date,
	    completion_date,
	    last_update
	)
	SELECT
	    ROW_NUMBER() OVER () AS cust_watch_act_id,
	    r.customer_id,
	    (
	        SELECT i.film_id
	        FROM inventory AS i
	        WHERE i.inventory_id = r.inventory_id
	    ) AS content_id,
	    r.rental_date,
		r.return_date AS completion_date,
		r.last_update
	FROM rental AS r
	JOIN customer AS c
	ON r.customer_id = c.customer_id
	WHERE c.active = TRUE;





--- film category -> content_category
INSERT INTO content_category (content_id, category_id)
SELECT film_id, category_id
FROM film_category;

--- film_special_feature -> content_special_feature
CREATE SEQUENCE IF NOT EXISTS content_id_seq START WITH 1;
SELECT setval('content_id_seq', (SELECT MAX(content_id) FROM content_stream));

WITH source_data AS (
    SELECT 
        film_id,
        special_feature_type,
        nextval('content_id_seq') as new_content_id
    FROM film_special_feature
),
content_inserts AS (
    INSERT INTO content_stream (content_id, content_type_id, stream_uuid)
    SELECT new_content_id, 5, gen_random_uuid()
    FROM source_data
    RETURNING content_id
)
INSERT INTO content_special_feature (content_id, special_feature_type, special_feature_id)
SELECT 
    film_id,
    special_feature_type,
    new_content_id
FROM source_data;

--- film_actor -> content_actor
INSERT INTO content_actor (actor_id, content_id)
SELECT actor_id, film_id
FROM film_actor;

--- Foreign keys for content_id -- after migrating, add these to create
ALTER TABLE content_actor
  ADD CONSTRAINT fk_content_id
    FOREIGN KEY (content_id)
	REFERENCES content_stream (content_id);

ALTER TABLE content_category
  ADD CONSTRAINT fk_content_id
    FOREIGN KEY (content_id)
	REFERENCES content_stream (content_id);

AlTER TABLE content_special_feature
  ADD CONSTRAINT fk_content_id
  	FOREIGN KEY (content_id) REFERENCES content_stream (content_id),
  ADD CONSTRAINT fk_spec_feat_id
	FOREIGN KEY (special_feature_id) REFERENCES content_stream (content_id);






