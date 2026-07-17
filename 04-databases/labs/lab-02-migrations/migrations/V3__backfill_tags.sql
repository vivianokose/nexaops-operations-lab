-- Backfill existing rows with a sensible default so no post has NULL tags.
UPDATE posts SET tags = ARRAY['uncategorized'] WHERE tags IS NULL;
