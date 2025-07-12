-- 2.4.4 Zusätzliche Daten einfügen: Neue Kategorie 'Dramedy'

-- a. Neue Kategorie 'Dramedy' anlegen
INSERT INTO category (category_id, name, last_update)
VALUES (
    (SELECT COALESCE(MAX(category_id), 0) + 1 FROM category),
    'Dramedy', 
    CURRENT_TIMESTAMP
);

-- b. Neue Kategorie allen Inhalten hinzufügen, die gleichzeitig den Kategorien "Drama" und "Comedy" zugeordnet sind
INSERT INTO content_category (content_id, category_id)
SELECT DISTINCT 
    cc1.content_id,
    (SELECT category_id FROM category WHERE name = 'Dramedy') AS category_id
FROM content_category cc1
JOIN content_category cc2 ON cc1.content_id = cc2.content_id
WHERE cc1.category_id = (SELECT category_id FROM category WHERE name = 'Drama')
  AND cc2.category_id = (SELECT category_id FROM category WHERE name = 'Comedy');
