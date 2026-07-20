-- Additive change: add the new column, nullable, with no default backfill.
-- Safe to run while the app is live because nothing existing breaks.
ALTER TABLE posts ADD COLUMN tags TEXT[];

CREATE INDEX idx_posts_tags ON posts USING GIN(tags);
