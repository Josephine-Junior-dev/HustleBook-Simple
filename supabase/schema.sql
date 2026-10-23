-- HustleBook Simple tables. These names are separate from Garage Operations Pro.
-- Run this script in Supabase SQL Editor.
create table if not exists public.hbs_stock (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  qty numeric not null default 0 check (qty >= 0),
  price numeric not null default 0 check (price >= 0),
  alert numeric not null default 5 check (alert >= 0),
  created_at timestamptz not null default now()
);
create table if not exists public.hbs_sales (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  qty numeric not null check (qty > 0),
  price numeric not null check (price >= 0),
  total numeric not null check (total >= 0),
  received numeric not null default 0 check (received >= 0 and received <= total),
  pay text not null default 'M-Pesa',
  customer text,
  sale_date date not null default current_date,
  created_at timestamptz not null default now()
);
create table if not exists public.hbs_expenses (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  amount numeric not null check (amount > 0),
  category text not null default 'Other',
  pay text not null default 'M-Pesa',
  expense_date date not null default current_date,
  created_at timestamptz not null default now()
);
create table if not exists public.hbs_suppliers (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now()
);

alter table public.hbs_stock enable row level security;
alter table public.hbs_sales enable row level security;
alter table public.hbs_expenses enable row level security;
alter table public.hbs_suppliers enable row level security;

drop policy if exists "hbs_stock_owner" on public.hbs_stock;
create policy "hbs_stock_owner" on public.hbs_stock for all to authenticated using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
drop policy if exists "hbs_sales_owner" on public.hbs_sales;
create policy "hbs_sales_owner" on public.hbs_sales for all to authenticated using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
drop policy if exists "hbs_expenses_owner" on public.hbs_expenses;
create policy "hbs_expenses_owner" on public.hbs_expenses for all to authenticated using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
drop policy if exists "hbs_suppliers_owner" on public.hbs_suppliers;
create policy "hbs_suppliers_owner" on public.hbs_suppliers for all to authenticated using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));

grant usage on schema public to authenticated;
grant select, insert, update, delete on public.hbs_stock, public.hbs_sales, public.hbs_expenses, public.hbs_suppliers to authenticated;
