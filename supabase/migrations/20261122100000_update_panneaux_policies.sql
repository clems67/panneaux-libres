drop policy if exists "Enable read access for authenticated users" on public.panneaux;
drop policy if exists "Enable update access for all users" on public.panneaux;

create policy "Users can view panneaux in their city"
  on public.panneaux
  for select
  to authenticated
  using (
    exists (
      select 1
      from public.profiles p
      where p.id = (select auth.uid())
        and p.city_id = panneaux.city_id
    )
  );

  create policy "Users can edit panneaux in their city"
  on public.panneaux
  for update
  to authenticated
  using (
    exists (
      select 1
      from public.profiles p
      where p.id = (select auth.uid())
        and p.city_id = panneaux.city_id
    )
  );

