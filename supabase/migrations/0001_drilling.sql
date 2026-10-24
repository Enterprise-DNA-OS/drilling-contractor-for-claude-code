-- Drilling Contractor for Claude Code: the schema.
-- What an exploration and water bore drilling contractor runs on: clients and their contracts,
-- each contract's rate schedule (metres by method and depth band, hourly items, consumables),
-- rigs, crew, holes, the daily plod (one per rig per shift) with its activities, crew hours and
-- consumables, rig prestarts, drill bits, incidents, and the progress claim.
-- Plain Postgres. Runs the same on PGlite. Money is integer cents, time is minutes, depth is metres.

create table if not exists clients (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  contact_name text,
  contact_email text,
  abn text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists contracts (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  client_id uuid not null references clients(id),
  name text not null,
  site text,
  tenement text,
  pow_ref text,                      -- programme of work approval for ground-disturbing exploration
  pow_expires_on date,
  water_licence_ref text,            -- licence to construct a well (water bore jobs)
  currency text not null default 'AUD',
  signoff_days int not null default 3,   -- days the client has to sign off a submitted plod
  terms_days int not null default 30,    -- days from claim to payment
  status text not null default 'active' check (status in ('active', 'finished', 'on-hold')),
  starts_on date,
  ends_on date,
  external_ref text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- One line of the client's schedule of rates.
--   unit 'metre' with a method and depth band: drilling charged per metre drilled in that band.
--   unit 'hour' with an activity: that activity's time is charged at this rate.
--   unit 'each' or 'metre' with no method: a consumable or item charged per unit used.
create table if not exists rate_items (
  id uuid primary key default gen_random_uuid(),
  contract_id uuid not null references contracts(id) on delete cascade,
  code text not null,
  description text not null,
  unit text not null check (unit in ('metre', 'hour', 'each', 'day')),
  method text check (method in ('RC', 'DD', 'AC', 'RAB', 'WB')),
  depth_from numeric(8,2),
  depth_to numeric(8,2),
  activity text,
  rate_cents bigint not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (contract_id, code)
);

create table if not exists rigs (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  make_model text,
  kind text not null check (kind in ('RC', 'DD', 'multi', 'AC', 'WB')),
  contract_id uuid references contracts(id),   -- where it is working now
  status text not null default 'working' check (status in ('working', 'standby', 'workshop', 'sold')),
  next_service_hours numeric(10,1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists staff (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  full_name text not null,
  role text not null check (role in ('driller', 'offsider', 'supervisor', 'mechanic')),
  licence_class text,                -- water well driller licence class (1, 2, 3)
  licence_expires_on date,
  competency text,                   -- e.g. RII30820 Certificate III in Drilling Operations
  competency_expires_on date,        -- the company's own review date for the rig types they run
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists holes (
  id uuid primary key default gen_random_uuid(),
  contract_id uuid not null references contracts(id),
  hole_id text not null,
  method text not null check (method in ('RC', 'DD', 'AC', 'RAB', 'WB')),
  planned_depth numeric(8,2),
  dip numeric(5,1),
  azimuth numeric(5,1),
  started_on date,
  completed_on date,
  abandoned boolean not null default false,
  rehab_on date,                     -- capped, plugged or rehabilitated
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (contract_id, hole_id)
);

create table if not exists claims (
  id uuid primary key default gen_random_uuid(),
  contract_id uuid not null references contracts(id),
  number text not null unique,
  period_end date not null,
  amount_cents bigint not null default 0,
  status text not null default 'draft' check (status in ('draft', 'submitted', 'paid', 'disputed')),
  submitted_on date,
  paid_on date,
  paid_cents bigint,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- The plod: one report per rig per shift.
create table if not exists plods (
  id uuid primary key default gen_random_uuid(),
  number text not null unique,
  contract_id uuid not null references contracts(id),
  rig_id uuid not null references rigs(id),
  plod_date date not null,
  shift text not null check (shift in ('day', 'night')),
  driller_id uuid references staff(id),
  engine_hours_end numeric(10,1),
  status text not null default 'draft' check (status in ('draft', 'submitted', 'approved', 'rejected')),
  submitted_on date,
  approved_on date,
  approved_by text,
  reject_reason text,
  claim_id uuid references claims(id),
  comments text,
  external_ref text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (rig_id, plod_date, shift)
);

-- Activity codes: drilling, rig-move, rig-up, standby-client, standby-contractor, breakdown,
-- survey, development, safety, meal. Only drilling carries metres.
create table if not exists plod_activities (
  id uuid primary key default gen_random_uuid(),
  plod_id uuid not null references plods(id) on delete cascade,
  line int not null,
  activity text not null,
  hole_id uuid references holes(id),
  minutes int not null default 0 check (minutes >= 0),
  from_m numeric(8,2),
  to_m numeric(8,2),
  bit_serial text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (plod_id, line),
  check (from_m is null or to_m is null or to_m >= from_m)
);

create table if not exists plod_crew (
  id uuid primary key default gen_random_uuid(),
  plod_id uuid not null references plods(id) on delete cascade,
  staff_id uuid not null references staff(id),
  minutes int not null check (minutes >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (plod_id, staff_id)
);

create table if not exists plod_consumables (
  id uuid primary key default gen_random_uuid(),
  plod_id uuid not null references plods(id) on delete cascade,
  item text not null,                -- matches a rate_items code when the client pays for it
  qty numeric(10,2) not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (plod_id, item)
);

create table if not exists bits (
  id uuid primary key default gen_random_uuid(),
  serial text not null unique,
  kind text not null,                -- 'RC hammer bit', 'HQ diamond bit', 'tricone'
  size text,
  cost_cents bigint not null default 0,
  expected_m numeric(8,1),           -- the life you expect from this kind in your ground
  rig_id uuid references rigs(id),
  fitted_on date,
  retired_on date,
  retired_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists prestarts (
  id uuid primary key default gen_random_uuid(),
  rig_id uuid not null references rigs(id),
  done_on date not null,
  shift text not null check (shift in ('day', 'night')),
  done_by uuid references staff(id),
  ok boolean not null default true,
  defects text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (rig_id, done_on, shift)
);

create table if not exists rig_services (
  id uuid primary key default gen_random_uuid(),
  rig_id uuid not null references rigs(id),
  serviced_on date not null,
  engine_hours numeric(10,1),
  kind text not null default 'service',
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (rig_id, serviced_on, kind)
);

create table if not exists incidents (
  id uuid primary key default gen_random_uuid(),
  number text not null unique,
  occurred_on date not null,
  contract_id uuid references contracts(id),
  rig_id uuid references rigs(id),
  kind text not null,                -- injury, near-miss, dangerous-incident, environmental, property
  description text not null,
  notifiable boolean not null default false,
  notified_on date,
  notified_ref text,
  closed_on date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists notes (
  id uuid primary key default gen_random_uuid(),
  contract_id uuid references contracts(id),
  rig_id uuid references rigs(id),
  body text not null,
  author text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- updated_at on every write
create or replace function touch_updated_at() returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

do $$
declare t text;
begin
  foreach t in array array['clients','contracts','rate_items','rigs','staff','holes','claims','plods','plod_activities',
    'plod_crew','plod_consumables','bits','prestarts','rig_services','incidents','notes'] loop
    execute format('drop trigger if exists trg_touch on %I', t);
    execute format('create trigger trg_touch before update on %I for each row execute function touch_updated_at()', t);
  end loop;
end $$;

create index if not exists plods_contract_date on plods (contract_id, plod_date);
create index if not exists plod_activities_hole on plod_activities (hole_id);
create index if not exists plod_crew_staff on plod_crew (staff_id);

-- Every chargeable line a plod earns, from the contract's own rate schedule.
--   Metres: each drilling run split across the depth bands it crosses.
--   Hours: activities the schedule prices by the hour (standby on the client, moves, rig up).
--   Items: consumables the schedule lists.
-- Breakdown, standby on the contractor, safety meetings and meals have no rate and earn nothing.
create or replace view v_plod_charges as
select p.id as plod_id, p.number as plod, p.contract_id, p.plod_date, p.status, p.claim_id,
       r.code as rate_code, r.description, 'metre'::text as unit,
       round(least(a.to_m, r.depth_to) - greatest(a.from_m, r.depth_from), 2) as qty,
       r.rate_cents,
       round((least(a.to_m, r.depth_to) - greatest(a.from_m, r.depth_from)) * r.rate_cents)::bigint as amount_cents
from plods p
join plod_activities a on a.plod_id = p.id and a.activity = 'drilling'
join holes h on h.id = a.hole_id
join rate_items r on r.contract_id = p.contract_id and r.unit = 'metre' and r.method = h.method
  and a.from_m < r.depth_to and a.to_m > r.depth_from
union all
select p.id, p.number, p.contract_id, p.plod_date, p.status, p.claim_id,
       r.code, r.description, 'hour',
       round(sum(a.minutes) / 60.0, 2),
       r.rate_cents,
       round(sum(a.minutes) / 60.0 * r.rate_cents)::bigint
from plods p
join plod_activities a on a.plod_id = p.id
join rate_items r on r.contract_id = p.contract_id and r.unit = 'hour' and r.activity = a.activity
group by p.id, p.number, p.contract_id, p.plod_date, p.status, p.claim_id, r.code, r.description, r.rate_cents
union all
select p.id, p.number, p.contract_id, p.plod_date, p.status, p.claim_id,
       r.code, r.description, r.unit,
       c.qty,
       r.rate_cents,
       round(c.qty * r.rate_cents)::bigint
from plods p
join plod_consumables c on c.plod_id = p.id
join rate_items r on r.contract_id = p.contract_id and r.code = c.item and r.method is null and r.activity is null;

-- One row per plod: hours by kind, metres, crew, charges.
create or replace view v_plod_summary as
select p.id, p.number, p.plod_date, p.shift, p.status, p.submitted_on, p.approved_on, p.claim_id, p.reject_reason,
       p.contract_id, k.code as contract, rg.id as rig_id, rg.code as rig, s.full_name as driller, s.code as driller_code,
       coalesce((select sum(a.minutes) from plod_activities a where a.plod_id = p.id), 0) as total_min,
       coalesce((select sum(a.minutes) from plod_activities a where a.plod_id = p.id and a.activity = 'drilling'), 0) as drilling_min,
       coalesce((select sum(a.minutes) from plod_activities a where a.plod_id = p.id and a.activity = 'standby-client'), 0) as standby_client_min,
       coalesce((select sum(a.minutes) from plod_activities a where a.plod_id = p.id and a.activity in ('breakdown', 'standby-contractor')), 0) as lost_min,
       coalesce((select sum(a.to_m - a.from_m) from plod_activities a where a.plod_id = p.id and a.activity = 'drilling'), 0) as metres,
       coalesce((select sum(c.amount_cents) from v_plod_charges c where c.plod_id = p.id), 0) as charge_cents
from plods p
join contracts k on k.id = p.contract_id
join rigs rg on rg.id = p.rig_id
left join staff s on s.id = p.driller_id;

-- Each hole: metres drilled to date and where it stands.
create or replace view v_hole_status as
select h.*, k.code as contract,
       coalesce((select max(a.to_m) from plod_activities a where a.hole_id = h.id and a.activity = 'drilling'), 0) as depth_m,
       (select max(p.plod_date) from plod_activities a join plods p on p.id = a.plod_id where a.hole_id = h.id) as last_plod_on,
       case when h.abandoned then 'abandoned'
            when h.completed_on is not null then 'complete'
            when exists (select 1 from plod_activities a where a.hole_id = h.id and a.activity = 'drilling') then 'drilling'
            else 'planned' end as stage
from holes h join contracts k on k.id = h.contract_id;

-- Each bit: metres it has drilled and what each metre cost.
create or replace view v_bit_life as
select b.*, rg.code as rig,
       coalesce((select sum(a.to_m - a.from_m) from plod_activities a where a.bit_serial = b.serial and a.activity = 'drilling'), 0) as metres
from bits b left join rigs rg on rg.id = b.rig_id;
