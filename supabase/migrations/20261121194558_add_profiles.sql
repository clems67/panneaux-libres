CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'pending'
        CHECK (role IN ('admin', 'animator', 'basic', 'pending')),
    city_id smallint REFERENCES public.cities(city_id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);