-- IRlist 1.0 schema
-- Run in Supabase Dashboard > SQL Editor.
-- Safe to re-run: existing tables are extended rather than dropped.

create table if not exists public.tasks (
  id uuid primary key, user_id uuid not null references auth.users(id) on delete cascade,
  title text not null, due date, priority text, done boolean default false,
  created_at timestamptz, category text, project text, project_id uuid,
  assignee text, description text, completed_at timestamptz
);
alter table public.tasks add column if not exists category text;
alter table public.tasks add column if not exists project text;
alter table public.tasks add column if not exists project_id uuid;
alter table public.tasks add column if not exists assignee text;
alter table public.tasks add column if not exists description text;
alter table public.tasks add column if not exists completed_at timestamptz;
alter table public.tasks add column if not exists space text not null default 'work';

create table if not exists public.projects (
  id uuid primary key, user_id uuid not null references auth.users(id) on delete cascade,
  name text not null, description text, progress integer default 0, status text,
  client_id uuid, client text, contract_amount numeric default 0, cost numeric default 0,
  start_date date, due_date date
);
alter table public.projects add column if not exists client_id uuid;
alter table public.projects add column if not exists client text;
alter table public.projects add column if not exists contract_amount numeric default 0;
alter table public.projects add column if not exists cost numeric default 0;
alter table public.projects add column if not exists start_date date;
alter table public.projects add column if not exists due_date date;

create table if not exists public.transactions (
  id uuid primary key, user_id uuid not null references auth.users(id) on delete cascade,
  title text not null, amount numeric not null, date date not null, kind text not null, notes text
);
alter table public.transactions add column if not exists notes text;

create table if not exists public.habits (
  id uuid primary key, user_id uuid not null references auth.users(id) on delete cascade,
  name text not null, frequency text
);
alter table public.habits add column if not exists frequency text;

create table if not exists public.payroll (
  id uuid primary key, user_id uuid not null references auth.users(id) on delete cascade,
  person text not null, amount numeric not null, period text,
  status text not null default 'pending', created_at timestamptz, date date
);
alter table public.payroll add column if not exists date date;

create table if not exists public.project_payments (
  id uuid primary key, user_id uuid not null references auth.users(id) on delete cascade,
  project text not null, client text, amount numeric not null, date date,
  status text not null default 'pending', period text, payment_type text
);
alter table public.project_payments add column if not exists period text;
alter table public.project_payments add column if not exists payment_type text;

create table if not exists public.team_members (
  id uuid primary key, user_id uuid not null references auth.users(id) on delete cascade,
  name text not null, role text, phone text, salary numeric default 0, created_at timestamptz
);

create table if not exists public.clients (
  id uuid primary key, user_id uuid not null references auth.users(id) on delete cascade,
  name text not null, company text, phone text, email text, notes text, created_at timestamptz
);

create table if not exists public.goals (
  id uuid primary key, user_id uuid not null references auth.users(id) on delete cascade,
  title text not null, period text, progress integer default 0, description text, created_at timestamptz
);

create table if not exists public.gratitude (
  id uuid primary key, user_id uuid not null references auth.users(id) on delete cascade,
  text text not null, created_at timestamptz
);

-- Enable Row Level Security and recreate owner-only policies idempotently.
do $$
declare t text;
begin
  foreach t in array array['tasks','projects','transactions','habits','payroll','project_payments','team_members','clients','goals','gratitude'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists "irlist owner access" on public.%I', t);
    execute format('create policy "irlist owner access" on public.%I for all using (auth.uid() = user_id) with check (auth.uid() = user_id)', t);
  end loop;
end $$;
