CREATE TABLE IF NOT EXISTS authors (
  id        SERIAL PRIMARY KEY,
  name      TEXT NOT NULL,
  email     TEXT UNIQUE,
  joined_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS posts (
  id         SERIAL PRIMARY KEY,
  author_id  INT REFERENCES authors(id) ON DELETE CASCADE,
  title      TEXT NOT NULL,
  body       TEXT,
  published  BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_posts_author ON posts(author_id);
CREATE INDEX idx_posts_published ON posts(published) WHERE published = TRUE;
