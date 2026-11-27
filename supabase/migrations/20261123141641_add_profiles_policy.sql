grant select on table public.profiles to authenticated;

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

create policy "Users can view profiles"
on public.profiles
  for select
  to authenticated
  USING (
    id = (SELECT auth.uid())
);