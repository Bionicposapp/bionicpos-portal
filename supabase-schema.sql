-- BionicPOS reporting portal schema.
-- Run this once in the Supabase project's SQL Editor (Dashboard > SQL Editor > New Query).
--
-- v1 is single-location: any authenticated user can read all rows (there's only one
-- location and only the owner logs into the dashboard). When a second location is
-- added, add a `profiles(user_id, location_id)` table and change the SELECT policies
-- below to filter on it instead of `using (true)`.

create extension if not exists "pgcrypto";

create table if not exists locations (
    id uuid primary key default gen_random_uuid(),
    name text not null
);

insert into locations (id, name)
values ('00000000-0000-0000-0000-000000000001', 'Main Location')
on conflict (id) do nothing;

create table if not exists orders (
    id uuid primary key,
    location_id uuid not null references locations(id),
    order_number integer not null,
    type text not null,
    status text not null,
    table_id uuid,
    server_id text not null,
    customer_name text not null default '',
    guest_count integer not null default 1,
    opened_at timestamptz not null,
    closed_at timestamptz,
    payment_method text,
    subtotal numeric not null default 0,
    tax numeric not null default 0,
    total numeric not null default 0
);

create table if not exists order_lines (
    id uuid primary key,
    order_id uuid not null references orders(id) on delete cascade,
    item_id uuid not null,
    item_name text not null,
    price numeric not null,
    quantity integer not null,
    modifiers jsonb not null default '[]'::jsonb,
    seat_number integer,
    routing_status text not null default 'pending'
);

create table if not exists employees (
    id uuid primary key,
    location_id uuid not null references locations(id),
    display_name text not null,
    is_hidden boolean not null default false
);

alter table orders enable row level security;
alter table order_lines enable row level security;
alter table employees enable row level security;

-- The app writes with the anon key (protected only by these policies, not a login).
create policy "anon can insert orders" on orders
    for insert to anon
    with check (true);

create policy "anon can insert order_lines" on order_lines
    for insert to anon
    with check (true);

create policy "anon can upsert employees" on employees
    for insert to anon
    with check (true);

create policy "anon can update employees" on employees
    for update to anon
    using (true)
    with check (true);

-- The dashboard website reads with a logged-in Supabase Auth session.
create policy "authenticated can read orders" on orders
    for select to authenticated
    using (true);

create policy "authenticated can read order_lines" on order_lines
    for select to authenticated
    using (true);

create policy "authenticated can read employees" on employees
    for select to authenticated
    using (true);

-- Create the owner's dashboard login: Dashboard > Authentication > Users > Add User.
