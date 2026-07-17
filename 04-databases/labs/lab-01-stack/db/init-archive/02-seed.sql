INSERT INTO authors (name, email) VALUES
  ('Vivian',  'vivian@lumberyard.dev'),
  ('Alice',   'alice@lumberyard.dev'),
  ('Bob',     'bob@lumberyard.dev')
ON CONFLICT (email) DO NOTHING;

INSERT INTO posts (author_id, title, body, published) VALUES
  (1, 'Day 1', 'Started the journey', TRUE),
  (1, 'Day 2', 'Linux is calm',       TRUE),
  (2, 'Hello', 'First post',          FALSE);
