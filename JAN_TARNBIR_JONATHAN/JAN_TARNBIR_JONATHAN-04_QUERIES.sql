SET search_path TO sakila;

-- 2.4.4 Zusätzliche Daten einfügen: Neue Kategorie 'Dramedy'

-- a. New Category 'Dramedy'
INSERT INTO category (category_id, name, last_update)
VALUES (
    (SELECT COALESCE(MAX(category_id), 0) + 1 FROM category),
    'Dramedy', 
    CURRENT_TIMESTAMP
);

-- b. Add new category to all content that is simultaneously assigned to both "Drama" and "Comedy" categories
INSERT INTO content_category (content_id, category_id)
SELECT DISTINCT 
    cc1.content_id,
    (SELECT category_id FROM category WHERE name = 'Dramedy') AS category_id
FROM content_category cc1
JOIN content_category cc2 ON cc1.content_id = cc2.content_id
WHERE cc1.category_id = (SELECT category_id FROM category WHERE name = 'Drama')
  AND cc2.category_id = (SELECT category_id FROM category WHERE name = 'Comedy');


-- 2.4.1 binge_flow
WITH RECURSIVE content_chain AS (
    -- Startpunkt: Anfangsinhalt mit CURRENT_ID = 4711 und franchise_id = 2
    SELECT 
        CURRENT_ID,
        NEXT_CONTENT,
        franchise_id
    FROM BINGE_FLOW
    WHERE CURRENT_ID = 4711
      AND franchise_id = 2
    UNION ALL
    -- Rekursiver Teil: Folgeinhalte suchen, indem NEXT_CONTENT = CURRENT_ID matcht
    SELECT 
        bf.CURRENT_ID,
        bf.NEXT_CONTENT,
        bf.franchise_id
    FROM BINGE_FLOW bf
    INNER JOIN content_chain cc ON bf.CURRENT_ID = cc.NEXT_CONTENT
    WHERE bf.franchise_id = 2)
SELECT * FROM content_chain;

-- 2.4.2 view to get favorite category per customer based on content activities
CREATE OR REPLACE VIEW v_cust_fav_content_cat AS
SELECT 
  customer_id, 
  first_name, 
  last_name, 
  category_id, 
  category_name,
  sum_movies,
  cat_rank
FROM (
  SELECT 
    cust.customer_id, 
    cust.first_name, 
    cust.last_name, 
    cat.category_id, 
    cat.name AS category_name,
    COUNT(cwa.cust_watch_act_id) AS sum_movies,
    DENSE_RANK() OVER (PARTITION BY cust.customer_id ORDER BY COUNT(cwa.cust_watch_act_id) DESC) AS cat_rank
  FROM customer AS cust
  INNER JOIN cust_watch_act AS cwa ON cust.customer_id = cwa.customer_id
  INNER JOIN content_stream AS cs ON cwa.content_id = cs.content_id
  INNER JOIN content_category AS cc ON cs.content_id = cc.content_id
  INNER JOIN category AS cat ON cc.category_id = cat.category_id
  GROUP BY cust.customer_id, cust.first_name, cust.last_name, cat.category_id, cat.name
) AS ranked_categories
WHERE cat_rank = 1
ORDER BY customer_id ASC;

-- 2.4.3 view for billing calculation by customer and date
CREATE OR REPLACE VIEW v_billing_cust_date AS
SELECT 
  bh.billing_id,
  bh.billing_date,
  bh.customer_id,
  SUM(bi.amount) AS total_amount
FROM billing_head AS bh
INNER JOIN billing_item AS bi ON bh.billing_id = bi.billing_id
GROUP BY bh.billing_id, bh.billing_date, bh.customer_id
ORDER BY bh.billing_id;
