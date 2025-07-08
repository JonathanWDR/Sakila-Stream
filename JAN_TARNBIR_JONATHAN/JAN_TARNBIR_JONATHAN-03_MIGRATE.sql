SET search_path TO sakila;
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
