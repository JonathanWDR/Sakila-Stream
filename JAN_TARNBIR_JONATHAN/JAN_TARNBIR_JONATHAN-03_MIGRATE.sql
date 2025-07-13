SET search_path TO sakila;



-- Customer migration -> srv_customer_allocation     - mustn't be executed multiple times (results in duplicates)
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
		r.return_date as completion_date,
		r.last_update
	
	FROM rental AS r
	join customer as c
	on r.customer_id = c.customer_id
	where c.active = TRUE;


-- filme -> content

INSERT INTO content_stream
  (content_id,
   content_type_id,
   title,
   release_year,
   original_language_id,
   length)
SELECT
  f.film_id,
  (SELECT content_type_id FROM content_type WHERE content_ty_name = 'Film') AS content_type_id,
  f.title,
  f.release_year,
  f.original_language_id,
  f.length
FROM film AS f;


--- film category -> content_category
INSERT INTO content_category (content_id, category_id)
SELECT film_id, category_id
FROM film_category;

--- film_special_feature -> content_special_feature
INSERT INTO content_stream
(content_id, content_type_id) -- nothing else, because the data doesn't exist yet
SELECT content_id, 5
FROM film_special_feature;




--- film_actor -> content_actor
INSERT INTO content_actor (actor_id, content_id)
SELECT actor_id, film_id
FROM film_actor;

--- Foreign keys for content_id -- after migrating, add these to create

ALTER TABLE content_actor
  add constraint fk_content_id
    foreign key (content_id)
	references content_stream (content_id);

ALTER TABLE content_category
  add constraint fk_content_id
    foreign key (content_id)
	references content_stream (content_id);

AlTER TABLE content_special_feature
  add CONSTRAINT fk_content_id
	foreign key (content_id) references content_stream (content_id);
  -- no special_feature_id!





