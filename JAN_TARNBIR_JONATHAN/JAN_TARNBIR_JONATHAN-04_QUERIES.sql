-- Create new Category: Dramedy
INSERT INTO category (category_id, name, last_update)
VALUES (
  (SELECT COALESCE(MAX(category_id), 0) + 1 FROM category),
  'Dramedy',
  now()
);
