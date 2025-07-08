INSERT INTO srv_customer_allocation (
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
    st.service_type_id,
    sub.subscr_id,
    c.customer_id,
    vq.video_quality_id,
    current_timestamp,
    current_timestamp + INTERVAL '30 days',
    TRUE,
    current_timestamp
FROM customer c
-- nur aktive Kunden
WHERE c.active = TRUE
-- Abo-Service-Typ ermitteln
CROSS JOIN (
    SELECT service_type_id
    FROM service_type
    WHERE service_type_name = 'Subscription'
    LIMIT 1
) AS st
-- Free-Trial-Referenz
CROSS JOIN (
    SELECT subscr_id
    FROM subscription
    WHERE subscr_name = 'Free Trial'
    LIMIT 1
) AS sub
-- SD-Qualität
CROSS JOIN (
    SELECT video_quality_id
    FROM video_quality
    WHERE quality_code = 'SD'
    LIMIT 1
) AS vq
;
