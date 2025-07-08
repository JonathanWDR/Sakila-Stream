
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
	insert into content_stream (content_type_id)
	select content_type_id from content_type
	where content_ty_name = 'Film';


UPDATE content_stream
SET content_type_id = (
    SELECT content_type_id
    FROM content_type
    WHERE content_ty_name = 'Film'
    LIMIT 1
);

Select * from content_stream;







