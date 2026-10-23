-- HustleBook Paint Shop + Marketplace schema
-- Run once in Supabase SQL Editor for project ptluwoeogfkqavhspdjj.
-- Separate hps_ tables keep these records apart from Garage Operations Pro and hbs_ data.
-- Do not put a service_role key in the website.

create extension if not exists pgcrypto;

create table if not exists public.hps_shops (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  shop_name text not null,
  phone text,
  whatsapp text,
  email text,
  location_text text,
  description text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.hps_suppliers (
  id uuid primary key default gen_random_uuid(),
  shop_id uuid not null references public.hps_shops(id) on delete cascade,
  name text not null,
  phone text,
  email text,
  location_text text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.hps_products (
  id uuid primary key default gen_random_uuid(),
  shop_id uuid not null references public.hps_shops(id) on delete cascade,
  supplier_id uuid references public.hps_suppliers(id) on delete set null,
  product_name text not null,
  brand text,
  category text not null default 'Paint',
  product_code text,
  colour_name text,
  colour_code text,
  size_value numeric(12,3),
  size_unit text not null default 'piece'
    check (size_unit in ('litre','ml','kg','g','tin','roll','sheet','piece','set','pack','other')),
  stock_qty numeric(14,3) not null default 0 check (stock_qty >= 0),
  low_stock_level numeric(14,3) not null default 0 check (low_stock_level >= 0),
  buying_price numeric(14,2) not null default 0 check (buying_price >= 0),
  selling_price numeric(14,2) not null default 0 check (selling_price >= 0),
  image_url text,
  description text,
  is_published boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (shop_id, product_code)
);

create table if not exists public.hps_customers (
  id uuid primary key default gen_random_uuid(),
  shop_id uuid not null references public.hps_shops(id) on delete cascade,
  customer_name text not null,
  phone text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.hps_sales (
  id uuid primary key default gen_random_uuid(),
  shop_id uuid not null references public.hps_shops(id) on delete cascade,
  customer_id uuid references public.hps_customers(id) on delete set null,
  receipt_number text,
  sale_date timestamptz not null default now(),
  subtotal numeric(14,2) not null default 0 check (subtotal >= 0),
  discount numeric(14,2) not null default 0 check (discount >= 0),
  total numeric(14,2) not null default 0 check (total >= 0),
  amount_received numeric(14,2) not null default 0 check (amount_received >= 0),
  payment_method text not null default 'M-Pesa'
    check (payment_method in ('M-Pesa','Cash','Bank','Credit','Other')),
  status text not null default 'completed'
    check (status in ('completed','cancelled','refunded')),
  notes text,
  created_at timestamptz not null default now(),
  check (amount_received <= total)
);

create table if not exists public.hps_sale_items (
  id uuid primary key default gen_random_uuid(),
  sale_id uuid not null references public.hps_sales(id) on delete cascade,
  shop_id uuid not null references public.hps_shops(id) on delete cascade,
  product_id uuid references public.hps_products(id) on delete set null,
  product_name text not null,
  brand text,
  colour_name text,
  size_value numeric(12,3),
  size_unit text,
  quantity numeric(14,3) not null check (quantity > 0),
  unit_price numeric(14,2) not null check (unit_price >= 0),
  unit_cost numeric(14,2) not null default 0 check (unit_cost >= 0),
  line_total numeric(14,2) not null check (line_total >= 0),
  created_at timestamptz not null default now()
);

create table if not exists public.hps_expenses (
  id uuid primary key default gen_random_uuid(),
  shop_id uuid not null references public.hps_shops(id) on delete cascade,
  description text not null,
  category text not null default 'Other',
  amount numeric(14,2) not null check (amount > 0),
  payment_method text not null default 'M-Pesa'
    check (payment_method in ('M-Pesa','Cash','Bank','Other')),
  expense_date date not null default current_date,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.hps_purchases (
  id uuid primary key default gen_random_uuid(),
  shop_id uuid not null references public.hps_shops(id) on delete cascade,
  supplier_id uuid references public.hps_suppliers(id) on delete set null,
  supplier_invoice text,
  purchase_date date not null default current_date,
  subtotal numeric(14,2) not null default 0 check (subtotal >= 0),
  total numeric(14,2) not null default 0 check (total >= 0),
  amount_paid numeric(14,2) not null default 0 check (amount_paid >= 0),
  payment_method text not null default 'M-Pesa'
    check (payment_method in ('M-Pesa','Cash','Bank','Credit','Other')),
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.hps_purchase_items (
  id uuid primary key default gen_random_uuid(),
  purchase_id uuid not null references public.hps_purchases(id) on delete cascade,
  shop_id uuid not null references public.hps_shops(id) on delete cascade,
  product_id uuid references public.hps_products(id) on delete set null,
  product_name text not null,
  quantity numeric(14,3) not null check (quantity > 0),
  unit_cost numeric(14,2) not null check (unit_cost >= 0),
  line_total numeric(14,2) not null check (line_total >= 0),
  created_at timestamptz not null default now()
);

create table if not exists public.hps_stock_movements (
  id uuid primary key default gen_random_uuid(),
  shop_id uuid not null references public.hps_shops(id) on delete cascade,
  product_id uuid references public.hps_products(id) on delete set null,
  movement_type text not null
    check (movement_type in ('opening','purchase','sale','adjustment','return','damage','correction')),
  quantity_change numeric(14,3) not null,
  reference_id uuid,
  note text,
  created_at timestamptz not null default now()
);

create table if not exists public.hps_marketplace_enquiries (
  id uuid primary key default gen_random_uuid(),
  shop_id uuid not null references public.hps_shops(id) on delete cascade,
  product_id uuid references public.hps_products(id) on delete set null,
  customer_name text not null,
  customer_phone text,
  message text,
  quantity_requested numeric(14,3),
  status text not null default 'new'
    check (status in ('new','contacted','quoted','closed')),
  created_at timestamptz not null default now()
);

create index if not exists hps_products_shop_idx on public.hps_products(shop_id);
create index if not exists hps_products_public_idx on public.hps_products(is_published, is_active);
create index if not exists hps_sales_shop_date_idx on public.hps_sales(shop_id, sale_date desc);
create index if not exists hps_expenses_shop_date_idx on public.hps_expenses(shop_id, expense_date desc);
create index if not exists hps_movements_product_idx on public.hps_stock_movements(shop_id, product_id, created_at desc);
create index if not exists hps_enquiries_shop_idx on public.hps_marketplace_enquiries(shop_id, created_at desc);

alter table public.hps_shops enable row level security;
alter table public.hps_suppliers enable row level security;
alter table public.hps_products enable row level security;
alter table public.hps_customers enable row level security;
alter table public.hps_sales enable row level security;
alter table public.hps_sale_items enable row level security;
alter table public.hps_expenses enable row level security;
alter table public.hps_purchases enable row level security;
alter table public.hps_purchase_items enable row level security;
alter table public.hps_stock_movements enable row level security;
alter table public.hps_marketplace_enquiries enable row level security;

-- Shop owners can access only records belonging to their own shop(s).
drop policy if exists hps_shops_owner_all on public.hps_shops;
create policy hps_shops_owner_all on public.hps_shops
  for all to authenticated using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

drop policy if exists hps_suppliers_owner_all on public.hps_suppliers;
create policy hps_suppliers_owner_all on public.hps_suppliers for all to authenticated
  using (exists (select 1 from public.hps_shops s where s.id = shop_id and s.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.hps_shops s where s.id = shop_id and s.owner_id = (select auth.uid())));

-- Published products in active shops can be browsed without exposing private business records.
drop policy if exists hps_products_public_read on public.hps_products;
create policy hps_products_public_read on public.hps_products for select to anon, authenticated
  using (is_published = true and is_active = true and exists (
    select 1 from public.hps_shops s where s.id = shop_id and s.is_active = true
  ));
drop policy if exists hps_products_owner_all on public.hps_products;
create policy hps_products_owner_all on public.hps_products for all to authenticated
  using (exists (select 1 from public.hps_shops s where s.id = shop_id and s.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.hps_shops s where s.id = shop_id and s.owner_id = (select auth.uid())));

drop policy if exists hps_customers_owner_all on public.hps_customers;
create policy hps_customers_owner_all on public.hps_customers for all to authenticated
  using (exists (select 1 from public.hps_shops s where s.id = shop_id and s.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.hps_shops s where s.id = shop_id and s.owner_id = (select auth.uid())));

drop policy if exists hps_sales_owner_all on public.hps_sales;
create policy hps_sales_owner_all on public.hps_sales for all to authenticated
  using (exists (select 1 from public.hps_shops s where s.id = shop_id and s.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.hps_shops s where s.id = shop_id and s.owner_id = (select auth.uid())));

drop policy if exists hps_sale_items_owner_all on public.hps_sale_items;
create policy hps_sale_items_owner_all on public.hps_sale_items for all to authenticated
  using (exists (select 1 from public.hps_shops s where s.id = shop_id and s.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.hps_shops s where s.id = shop_id and s.owner_id = (select auth.uid())));

drop policy if exists hps_expenses_owner_all on public.hps_expenses;
create policy hps_expenses_owner_all on public.hps_expenses for all to authenticated
  using (exists (select 1 from public.hps_shops s where s.id = shop_id and s.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.hps_shops s where s.id = shop_id and s.owner_id = (select auth.uid())));

drop policy if exists hps_purchases_owner_all on public.hps_purchases;
create policy hps_purchases_owner_all on public.hps_purchases for all to authenticated
  using (exists (select 1 from public.hps_shops s where s.id = shop_id and s.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.hps_shops s where s.id = shop_id and s.owner_id = (select auth.uid())));

drop policy if exists hps_purchase_items_owner_all on public.hps_purchase_items;
create policy hps_purchase_items_owner_all on public.hps_purchase_items for all to authenticated
  using (exists (select 1 from public.hps_shops s where s.id = shop_id and s.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.hps_shops s where s.id = shop_id and s.owner_id = (select auth.uid())));

drop policy if exists hps_stock_movements_owner_all on public.hps_stock_movements;
create policy hps_stock_movements_owner_all on public.hps_stock_movements for all to authenticated
  using (exists (select 1 from public.hps_shops s where s.id = shop_id and s.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.hps_shops s where s.id = shop_id and s.owner_id = (select auth.uid())));

drop policy if exists hps_enquiries_owner_all on public.hps_marketplace_enquiries;
create policy hps_enquiries_owner_all on public.hps_marketplace_enquiries for all to authenticated
  using (exists (select 1 from public.hps_shops s where s.id = shop_id and s.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.hps_shops s where s.id = shop_id and s.owner_id = (select auth.uid())));

grant usage on schema public to anon, authenticated;
grant select on public.hps_products to anon;
grant select, insert, update, delete on public.hps_shops, public.hps_suppliers, public.hps_products,
  public.hps_customers, public.hps_sales, public.hps_sale_items, public.hps_expenses,
  public.hps_purchases, public.hps_purchase_items, public.hps_stock_movements,
  public.hps_marketplace_enquiries to authenticated;

-- Note: the application must create a shop row first, use its id for shop_id,
-- and adjust stock in a transaction when purchases/sales are saved.
-- Marketplace access to published products does NOT expose costs, sales, or customer records.
