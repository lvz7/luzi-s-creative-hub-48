-- Reviews for purchased designs (publicly readable only after approval)
CREATE TABLE IF NOT EXISTS public.reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  rating INTEGER NOT NULL,
  body TEXT NOT NULL,
  design TEXT,
  approved BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Basic validation
ALTER TABLE public.reviews
  ADD CONSTRAINT reviews_rating_range CHECK (rating BETWEEN 1 AND 5);

ALTER TABLE public.reviews
  ADD CONSTRAINT reviews_name_len CHECK (char_length(name) BETWEEN 1 AND 60);

ALTER TABLE public.reviews
  ADD CONSTRAINT reviews_body_len CHECK (char_length(body) BETWEEN 1 AND 800);

ALTER TABLE public.reviews
  ADD CONSTRAINT reviews_design_len CHECK (design IS NULL OR char_length(design) <= 80);

CREATE INDEX IF NOT EXISTS idx_reviews_approved_created_at ON public.reviews (approved, created_at DESC);

ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- Anyone can submit a review (unapproved by default)
DROP POLICY IF EXISTS "Anyone can submit a review" ON public.reviews;
CREATE POLICY "Anyone can submit a review"
ON public.reviews
FOR INSERT
TO public
WITH CHECK (true);

-- Only approved reviews are visible publicly
DROP POLICY IF EXISTS "Approved reviews are viewable by everyone" ON public.reviews;
CREATE POLICY "Approved reviews are viewable by everyone"
ON public.reviews
FOR SELECT
TO public
USING (approved = true);

-- No direct updates/deletes from clients
DROP POLICY IF EXISTS "No updates" ON public.reviews;
CREATE POLICY "No updates"
ON public.reviews
FOR UPDATE
TO public
USING (false);

DROP POLICY IF EXISTS "No deletes" ON public.reviews;
CREATE POLICY "No deletes"
ON public.reviews
FOR DELETE
TO public
USING (false);
