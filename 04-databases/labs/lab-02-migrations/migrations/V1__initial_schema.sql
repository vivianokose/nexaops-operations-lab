CREATE TABLE authors (
  id        SERIAL PRIMARY KEY,
  name      TEXT NOT NULL,
  email     TEXT UNIQUE NOT NULL,
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE posts (
  id         SERIAL PRIMARY KEY,
  author_id  INT NOT NULL REFERENCES authors(id) ON DELETE CASCADE,
  title      TEXT NOT NULL,
  body       TEXT,
  published  BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_posts_author ON posts(author_id);
CREATE INDEX idx_posts_published ON posts(published) WHERE published = TRUE;

INSERT INTO authors (name, email) VALUES
  ('Vivian', 'vivian@lumberyard.dev'),
  ('Alice',  'alice@lumberyard.dev'),
  ('Bob',    'bob@lumberyard.dev');

INSERT INTO posts (author_id, title, body, published) VALUES
  (1, 'Day 1', 'Started the journey', TRUE),
  (1, 'Day 2', 'Linux is calm',       TRUE),
  (2, 'Hello', 'First post',          FALSE);
