-- Demo data: Ironbark Drilling Pty Ltd, a fictional Kalgoorlie exploration and water bore contractor.
-- Four rigs on three live contracts and one finished one, three weeks of plods, crew, prestarts,
-- bits, incidents and claims. Dates are relative to today. Every insert skips what is already
-- there, so running it twice is harmless. Problems are planted on purpose so /attention and
-- /compliance have something to say: plods past their sign-off window, a rejected plod, a rig with
-- no plod for two days, a missed prestart, a rig past its service, a water bore drilled by a driller
-- whose licence had lapsed, an offsider whose competency review is overdue, a long shift, a
-- notifiable incident not yet notified, holes not rehabilitated, an unpaid claim and unclaimed work.

insert into clients (name, contact_name, contact_email, abn) values
  ('Red Dune Resources Ltd', 'Hannah Moss', 'hannah.moss@reddune.example', '51 600 112 334'),
  ('Kurrawang Nickel Pty Ltd', 'Owen Carter', 'owen.carter@kurrawang.example', '22 611 903 120'),
  ('Yindi Pastoral Co', 'Rosie Hart', 'rosie@yindi.example', '84 090 223 761'),
  ('Lake Lefroy Gold Ltd', 'Marcus Webb', 'marcus.webb@lefroygold.example', '67 601 554 902')
on conflict (name) do nothing;

insert into contracts (code, client_id, name, site, tenement, pow_ref, pow_expires_on, water_licence_ref, signoff_days, terms_days, status, starts_on, ends_on)
select 'C-099', id, 'Lefroy infill RC', 'Lake Lefroy', 'M15/1490', 'PoW 108812', current_date + 120, null, 3, 30, 'finished', current_date - 60, current_date - 44 from clients where name = 'Lake Lefroy Gold Ltd'
on conflict (code) do nothing;
insert into contracts (code, client_id, name, site, tenement, pow_ref, pow_expires_on, water_licence_ref, signoff_days, terms_days, status, starts_on, ends_on)
select 'C-101', id, 'Mulga Hill RC programme', 'Mulga Hill, 60 km NE of Kalgoorlie', 'E27/0631', 'PoW 113407', current_date + 18, null, 3, 30, 'active', current_date - 13, current_date + 40 from clients where name = 'Red Dune Resources Ltd'
on conflict (code) do nothing;
insert into contracts (code, client_id, name, site, tenement, pow_ref, pow_expires_on, water_licence_ref, signoff_days, terms_days, status, starts_on, ends_on)
select 'C-102', id, 'Kurrawang North diamond', 'Kurrawang North', 'M26/0410', 'PoW 112960', current_date + 210, null, 2, 30, 'active', current_date - 20, current_date + 60 from clients where name = 'Kurrawang Nickel Pty Ltd'
on conflict (code) do nothing;
insert into contracts (code, client_id, name, site, tenement, pow_ref, pow_expires_on, water_licence_ref, signoff_days, terms_days, status, starts_on, ends_on)
select 'C-103', id, 'Yindi station water bores', 'Yindi Station', null, null, null, '26D 201877', 5, 14, 'active', current_date - 9, current_date + 10 from clients where name = 'Yindi Pastoral Co'
on conflict (code) do nothing;
insert into rate_items (contract_id, code, description, unit, method, depth_from, depth_to, activity, rate_cents)
select id, 'RC-0200', 'RC drilling 0 to 200 m', 'metre', 'RC', 0, 200, null, 9000 from contracts where code = 'C-099'
on conflict (contract_id, code) do nothing;
insert into rate_items (contract_id, code, description, unit, method, depth_from, depth_to, activity, rate_cents)
select id, 'SB-CLIENT', 'Standby at client request', 'hour', null, null, null, 'standby-client', 36000 from contracts where code = 'C-099'
on conflict (contract_id, code) do nothing;
insert into rate_items (contract_id, code, description, unit, method, depth_from, depth_to, activity, rate_cents)
select id, 'RC-0100', 'RC drilling 0 to 100 m', 'metre', 'RC', 0, 100, null, 9500 from contracts where code = 'C-101'
on conflict (contract_id, code) do nothing;
insert into rate_items (contract_id, code, description, unit, method, depth_from, depth_to, activity, rate_cents)
select id, 'RC-0200', 'RC drilling 100 to 200 m', 'metre', 'RC', 100, 200, null, 11000 from contracts where code = 'C-101'
on conflict (contract_id, code) do nothing;
insert into rate_items (contract_id, code, description, unit, method, depth_from, depth_to, activity, rate_cents)
select id, 'RC-0300', 'RC drilling 200 to 300 m', 'metre', 'RC', 200, 300, null, 13000 from contracts where code = 'C-101'
on conflict (contract_id, code) do nothing;
insert into rate_items (contract_id, code, description, unit, method, depth_from, depth_to, activity, rate_cents)
select id, 'SB-CLIENT', 'Standby at client request', 'hour', null, null, null, 'standby-client', 38000 from contracts where code = 'C-101'
on conflict (contract_id, code) do nothing;
insert into rate_items (contract_id, code, description, unit, method, depth_from, depth_to, activity, rate_cents)
select id, 'MOVE', 'Rig move between holes', 'hour', null, null, null, 'rig-move', 42000 from contracts where code = 'C-101'
on conflict (contract_id, code) do nothing;
insert into rate_items (contract_id, code, description, unit, method, depth_from, depth_to, activity, rate_cents)
select id, 'RIGUP', 'Rig up and pull down', 'hour', null, null, null, 'rig-up', 38000 from contracts where code = 'C-101'
on conflict (contract_id, code) do nothing;
insert into rate_items (contract_id, code, description, unit, method, depth_from, depth_to, activity, rate_cents)
select id, 'sample-bags', 'Calico sample bags', 'each', null, null, null, null, 120 from contracts where code = 'C-101'
on conflict (contract_id, code) do nothing;
insert into rate_items (contract_id, code, description, unit, method, depth_from, depth_to, activity, rate_cents)
select id, 'DD-HQ', 'Diamond HQ 0 to 300 m', 'metre', 'DD', 0, 300, null, 18500 from contracts where code = 'C-102'
on conflict (contract_id, code) do nothing;
insert into rate_items (contract_id, code, description, unit, method, depth_from, depth_to, activity, rate_cents)
select id, 'DD-NQ', 'Diamond NQ 300 to 600 m', 'metre', 'DD', 300, 600, null, 21000 from contracts where code = 'C-102'
on conflict (contract_id, code) do nothing;
insert into rate_items (contract_id, code, description, unit, method, depth_from, depth_to, activity, rate_cents)
select id, 'SB-CLIENT', 'Standby at client request', 'hour', null, null, null, 'standby-client', 41000 from contracts where code = 'C-102'
on conflict (contract_id, code) do nothing;
insert into rate_items (contract_id, code, description, unit, method, depth_from, depth_to, activity, rate_cents)
select id, 'MOVE', 'Rig move between holes', 'hour', null, null, null, 'rig-move', 45000 from contracts where code = 'C-102'
on conflict (contract_id, code) do nothing;
insert into rate_items (contract_id, code, description, unit, method, depth_from, depth_to, activity, rate_cents)
select id, 'SURVEY', 'Downhole survey', 'hour', null, null, null, 'survey', 30000 from contracts where code = 'C-102'
on conflict (contract_id, code) do nothing;
insert into rate_items (contract_id, code, description, unit, method, depth_from, depth_to, activity, rate_cents)
select id, 'core-trays', 'Core trays', 'each', null, null, null, null, 2800 from contracts where code = 'C-102'
on conflict (contract_id, code) do nothing;
insert into rate_items (contract_id, code, description, unit, method, depth_from, depth_to, activity, rate_cents)
select id, 'WB-0150', 'Water bore drilling 0 to 150 m', 'metre', 'WB', 0, 150, null, 16000 from contracts where code = 'C-103'
on conflict (contract_id, code) do nothing;
insert into rate_items (contract_id, code, description, unit, method, depth_from, depth_to, activity, rate_cents)
select id, 'SB-CLIENT', 'Standby at client request', 'hour', null, null, null, 'standby-client', 35000 from contracts where code = 'C-103'
on conflict (contract_id, code) do nothing;
insert into rate_items (contract_id, code, description, unit, method, depth_from, depth_to, activity, rate_cents)
select id, 'DEVELOP', 'Bore development and airlift', 'hour', null, null, null, 'development', 35000 from contracts where code = 'C-103'
on conflict (contract_id, code) do nothing;
insert into rate_items (contract_id, code, description, unit, method, depth_from, depth_to, activity, rate_cents)
select id, 'pvc-casing-155', '155 mm PVC casing, per metre', 'metre', null, null, null, null, 6500 from contracts where code = 'C-103'
on conflict (contract_id, code) do nothing;
insert into rigs (code, make_model, kind, contract_id, status, next_service_hours)
select 'RC01', 'Schramm T685WS', 'RC', id, 'working', 12500 from contracts where code = 'C-101'
on conflict (code) do nothing;
insert into rigs (code, make_model, kind, contract_id, status, next_service_hours)
select 'RC02', 'Hydco 750 RC', 'RC', id, 'working', 9800 from contracts where code = 'C-101'
on conflict (code) do nothing;
insert into rigs (code, make_model, kind, contract_id, status, next_service_hours)
select 'DD01', 'Sandvik DE710', 'DD', id, 'working', 7900 from contracts where code = 'C-102'
on conflict (code) do nothing;
insert into rigs (code, make_model, kind, contract_id, status, next_service_hours)
select 'WB01', 'Hydco 1000 water well', 'WB', id, 'working', 3500 from contracts where code = 'C-103'
on conflict (code) do nothing;
insert into staff (code, full_name, role, licence_class, licence_expires_on, competency, competency_expires_on) values ('D01', 'Jack Reilly', 'driller', '3', current_date + 400, 'RII30820 Cert III Drilling Operations', current_date + 220) on conflict (code) do nothing;
insert into staff (code, full_name, role, licence_class, licence_expires_on, competency, competency_expires_on) values ('D02', 'Mia Tan', 'driller', '2', current_date - 20, 'RII30820 Cert III Drilling Operations', current_date + 150) on conflict (code) do nothing;
insert into staff (code, full_name, role, licence_class, licence_expires_on, competency, competency_expires_on) values ('D03', 'Tane Walker', 'driller', null, null, 'RII30820 Cert III Drilling Operations', current_date + 300) on conflict (code) do nothing;
insert into staff (code, full_name, role, licence_class, licence_expires_on, competency, competency_expires_on) values ('D04', 'Luke Brennan', 'driller', null, null, 'RII30820 Cert III Drilling Operations', current_date + 90) on conflict (code) do nothing;
insert into staff (code, full_name, role, licence_class, licence_expires_on, competency, competency_expires_on) values ('D05', 'Ana Silva', 'driller', null, null, 'RII30820 Cert III Drilling Operations', current_date + 180) on conflict (code) do nothing;
insert into staff (code, full_name, role, licence_class, licence_expires_on, competency, competency_expires_on) values ('D06', 'Craig Dunn', 'driller', null, null, 'RII30820 Cert III Drilling Operations', current_date + 250) on conflict (code) do nothing;
insert into staff (code, full_name, role, licence_class, licence_expires_on, competency, competency_expires_on) values ('O01', 'Ben Ross', 'offsider', null, null, 'RII20720 Cert II Surface Extraction', current_date + 200) on conflict (code) do nothing;
insert into staff (code, full_name, role, licence_class, licence_expires_on, competency, competency_expires_on) values ('O02', 'Kai Hughes', 'offsider', null, null, 'RII20720 Cert II Surface Extraction', current_date + 160) on conflict (code) do nothing;
insert into staff (code, full_name, role, licence_class, licence_expires_on, competency, competency_expires_on) values ('O03', 'Ella Ward', 'offsider', null, null, 'RII20720 Cert II Surface Extraction', current_date + 140) on conflict (code) do nothing;
insert into staff (code, full_name, role, licence_class, licence_expires_on, competency, competency_expires_on) values ('O04', 'Tom Price', 'offsider', null, null, 'RII20720 Cert II Surface Extraction', current_date - 5) on conflict (code) do nothing;
insert into staff (code, full_name, role, licence_class, licence_expires_on, competency, competency_expires_on) values ('O05', 'Josh Lee', 'offsider', null, null, 'RII20720 Cert II Surface Extraction', current_date + 210) on conflict (code) do nothing;
insert into staff (code, full_name, role, licence_class, licence_expires_on, competency, competency_expires_on) values ('O06', 'Ravi Patel', 'offsider', null, null, 'RII20720 Cert II Surface Extraction', current_date + 120) on conflict (code) do nothing;
insert into staff (code, full_name, role, licence_class, licence_expires_on, competency, competency_expires_on) values ('S01', 'Priya Nair', 'supervisor', '3', current_date + 500, 'RII30820 Cert III Drilling Operations', current_date + 330) on conflict (code) do nothing;
insert into staff (code, full_name, role, licence_class, licence_expires_on, competency, competency_expires_on) values ('M01', 'Dave Cole', 'mechanic', null, null, 'Heavy diesel trade certificate', current_date + 365) on conflict (code) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'LLRC041', 'RC', 160, -60, 90, current_date - 50, current_date - 50, current_date - 41, null from contracts where code = 'C-099'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'LLRC042', 'RC', 160, -60, 90, current_date - 50, current_date - 49, current_date - 40, null from contracts where code = 'C-099'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'LLRC043', 'RC', 160, -60, 90, current_date - 49, current_date - 49, current_date - 40, null from contracts where code = 'C-099'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'LLRC044', 'RC', 160, -60, 90, current_date - 48, current_date - 48, current_date - 39, null from contracts where code = 'C-099'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'LLRC045', 'RC', 160, -60, 90, current_date - 48, current_date - 47, null, null from contracts where code = 'C-099'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'LLRC046', 'RC', 160, -60, 90, current_date - 47, current_date - 47, null, null from contracts where code = 'C-099'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC001', 'RC', 180, -60, 270, current_date - 13, current_date - 13, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC002', 'RC', 150, -60, 270, current_date - 13, current_date - 12, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC003', 'RC', 210, -60, 270, current_date - 13, current_date - 12, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC004', 'RC', 160, -60, 270, current_date - 12, current_date - 11, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC005', 'RC', 240, -60, 270, current_date - 12, current_date - 11, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC006', 'RC', 170, -60, 270, current_date - 11, current_date - 9, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC007', 'RC', 150, -60, 270, current_date - 11, current_date - 10, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC008', 'RC', 200, -60, 270, current_date - 9, current_date - 7, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC009', 'RC', 190, -60, 270, current_date - 10, current_date - 10, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC010', 'RC', 160, -60, 270, current_date - 7, current_date - 6, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC011', 'RC', 220, -60, 270, current_date - 10, current_date - 9, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC012', 'RC', 150, -60, 270, current_date - 6, current_date - 5, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC013', 'RC', 180, -60, 270, current_date - 9, current_date - 8, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC014', 'RC', 200, -60, 270, current_date - 4, null, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC015', 'RC', 170, -60, 270, current_date - 8, current_date - 7, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC016', 'RC', 160, -60, 270, null, null, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC017', 'RC', 180, -60, 270, current_date - 7, current_date - 7, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC018', 'RC', 150, -60, 270, null, null, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC019', 'RC', 210, -60, 270, current_date - 7, current_date - 6, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC020', 'RC', 160, -60, 270, null, null, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC021', 'RC', 240, -60, 270, current_date - 6, current_date - 5, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC022', 'RC', 170, -60, 270, null, null, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC023', 'RC', 150, -60, 270, current_date - 5, current_date - 4, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC024', 'RC', 200, -60, 270, null, null, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC025', 'RC', 190, -60, 270, current_date - 4, current_date - 3, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC026', 'RC', 160, -60, 270, null, null, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC027', 'RC', 220, -60, 270, current_date - 3, current_date - 2, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC028', 'RC', 150, -60, 270, null, null, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC029', 'RC', 180, -60, 270, current_date - 2, current_date - 2, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC030', 'RC', 200, -60, 270, null, null, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC031', 'RC', 170, -60, 270, current_date - 2, current_date - 1, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC032', 'RC', 160, -60, 270, null, null, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC033', 'RC', 180, -60, 270, current_date - 1, null, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC034', 'RC', 150, -60, 270, null, null, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC035', 'RC', 210, -60, 270, null, null, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC036', 'RC', 160, -60, 270, null, null, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC037', 'RC', 240, -60, 270, null, null, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC038', 'RC', 170, -60, 270, null, null, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC039', 'RC', 150, -60, 270, null, null, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'MHRC040', 'RC', 200, -60, 270, null, null, null, null from contracts where code = 'C-101'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'KND001', 'DD', 420, -65, 225, current_date - 20, current_date - 16, null, null from contracts where code = 'C-102'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'KND002', 'DD', 520, -70, 225, current_date - 16, current_date - 10, null, null from contracts where code = 'C-102'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'KND003', 'DD', 480, -65, 225, current_date - 10, current_date - 4, null, null from contracts where code = 'C-102'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'KND004', 'DD', 600, -70, 225, current_date - 4, null, null, null from contracts where code = 'C-102'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'YWB01', 'WB', 120, -90, 0, current_date - 9, current_date - 7, null, 'Stock bore, north paddock' from contracts where code = 'C-103'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'YWB02', 'WB', 140, -90, 0, current_date - 7, current_date - 4, null, 'Stock bore, Mulga well replacement' from contracts where code = 'C-103'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'YWB03', 'WB', 110, -90, 0, current_date - 4, current_date - 2, null, 'Homestead supply' from contracts where code = 'C-103'
on conflict (contract_id, hole_id) do nothing;
insert into holes (contract_id, hole_id, method, planned_depth, dip, azimuth, started_on, completed_on, rehab_on, notes)
select id, 'YWB04', 'WB', 130, -90, 0, current_date - 2, null, null, 'South paddock trough supply' from contracts where code = 'C-103'
on conflict (contract_id, hole_id) do nothing;
insert into bits (serial, kind, size, cost_cents, expected_m, rig_id, fitted_on, retired_on, retired_reason)
select 'B-RC-4401', 'RC hammer bit', '140 mm', 165000, 1500, id, current_date - 60, current_date - 47, 'worn to gauge' from rigs where code = 'RC02'
on conflict (serial) do nothing;
insert into bits (serial, kind, size, cost_cents, expected_m, rig_id, fitted_on, retired_on, retired_reason)
select 'B-RC-4410', 'RC hammer bit', '140 mm', 165000, 1500, id, current_date - 13, current_date - 8, 'worn to gauge' from rigs where code = 'RC01'
on conflict (serial) do nothing;
insert into bits (serial, kind, size, cost_cents, expected_m, rig_id, fitted_on, retired_on, retired_reason)
select 'B-RC-4411', 'RC hammer bit', '140 mm', 165000, 1500, id, current_date - 7, null, null from rigs where code = 'RC01'
on conflict (serial) do nothing;
insert into bits (serial, kind, size, cost_cents, expected_m, rig_id, fitted_on, retired_on, retired_reason)
select 'B-RC-4412', 'RC hammer bit', '140 mm', 165000, 1500, id, current_date - 13, current_date - 9, 'two gauge buttons sheared' from rigs where code = 'RC02'
on conflict (serial) do nothing;
insert into bits (serial, kind, size, cost_cents, expected_m, rig_id, fitted_on, retired_on, retired_reason)
select 'B-RC-4413', 'RC hammer bit', '140 mm', 165000, 1500, id, current_date - 8, null, null from rigs where code = 'RC02'
on conflict (serial) do nothing;
insert into bits (serial, kind, size, cost_cents, expected_m, rig_id, fitted_on, retired_on, retired_reason)
select 'B-HQ-2201', 'HQ diamond bit', 'HQ', 98000, 900, id, current_date - 20, current_date - 12, 'crown worn' from rigs where code = 'DD01'
on conflict (serial) do nothing;
insert into bits (serial, kind, size, cost_cents, expected_m, rig_id, fitted_on, retired_on, retired_reason)
select 'B-HQ-2202', 'HQ diamond bit', 'HQ', 98000, 900, id, current_date - 11, null, null from rigs where code = 'DD01'
on conflict (serial) do nothing;
insert into bits (serial, kind, size, cost_cents, expected_m, rig_id, fitted_on, retired_on, retired_reason)
select 'B-NQ-3101', 'NQ diamond bit', 'NQ', 86000, 700, id, current_date - 6, null, null from rigs where code = 'DD01'
on conflict (serial) do nothing;
insert into bits (serial, kind, size, cost_cents, expected_m, rig_id, fitted_on, retired_on, retired_reason)
select 'B-TC-0901', 'Tricone', '200 mm', 240000, 600, id, current_date - 9, current_date - 5, 'bearing failure' from rigs where code = 'WB01'
on conflict (serial) do nothing;
insert into bits (serial, kind, size, cost_cents, expected_m, rig_id, fitted_on, retired_on, retired_reason)
select 'B-TC-0902', 'Tricone', '200 mm', 240000, 600, id, current_date - 4, null, null from rigs where code = 'WB01'
on conflict (serial) do nothing;
insert into claims (contract_id, number, period_end, status, submitted_on, paid_on)
select id, 'CL-0991', current_date - 48, 'paid', current_date - 47, current_date - 20 from contracts where code = 'C-099' on conflict (number) do nothing;
insert into claims (contract_id, number, period_end, status, submitted_on)
select id, 'CL-0992', current_date - 46, 'submitted', current_date - 40 from contracts where code = 'C-099' on conflict (number) do nothing;
insert into claims (contract_id, number, period_end, status, submitted_on)
select id, 'CL-1011', current_date - 7, 'submitted', current_date - 6 from contracts where code = 'C-101' on conflict (number) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10001', k.id, r.id, current_date - 50, 'day', s.id, 9431, 'approved', current_date - 50, current_date - 49, 'Marcus Webb (Lake Lefroy)', null, null
from contracts k, rigs r, staff s where k.code = 'C-099' and r.code = 'RC02' and s.code = 'D06'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-099' and h.hole_id = 'LLRC041'), 352, 0, 160, 'B-RC-4401', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-099' and h.hole_id = 'LLRC042'), 60, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-099' and h.hole_id = 'LLRC042'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-099' and h.hole_id = 'LLRC042'), 176, 0, 80, 'B-RC-4401', null),
    (6, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10001'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10001' and s.code = 'D06' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10001' and s.code = 'O06' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 240 from plods where number = 'P-10001' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 50, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC02' and s.code = 'D06' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10002', k.id, r.id, current_date - 49, 'day', s.id, 9442, 'approved', current_date - 49, current_date - 48, 'Marcus Webb (Lake Lefroy)', null, null
from contracts k, rigs r, staff s where k.code = 'C-099' and r.code = 'RC02' and s.code = 'D06'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-099' and h.hole_id = 'LLRC042'), 176, 80, 160, 'B-RC-4401', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-099' and h.hole_id = 'LLRC043'), 60, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-099' and h.hole_id = 'LLRC043'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-099' and h.hole_id = 'LLRC043'), 352, 0, 160, 'B-RC-4401', null),
    (6, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-099' and h.hole_id = 'LLRC044'), 60, null::numeric, null::numeric, null, null),
    (7, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-099' and h.hole_id = 'LLRC044'), 30, null::numeric, null::numeric, null, null),
    (8, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10002'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10002' and s.code = 'D06' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10002' and s.code = 'O06' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 240 from plods where number = 'P-10002' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 49, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC02' and s.code = 'D06' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10003', k.id, r.id, current_date - 48, 'day', s.id, 9453, 'approved', current_date - 48, current_date - 47, 'Marcus Webb (Lake Lefroy)', null, null
from contracts k, rigs r, staff s where k.code = 'C-099' and r.code = 'RC02' and s.code = 'D06'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-099' and h.hole_id = 'LLRC044'), 352, 0, 160, 'B-RC-4401', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-099' and h.hole_id = 'LLRC045'), 60, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-099' and h.hole_id = 'LLRC045'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-099' and h.hole_id = 'LLRC045'), 176, 0, 80, 'B-RC-4401', null),
    (6, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10003'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10003' and s.code = 'D06' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10003' and s.code = 'O06' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 240 from plods where number = 'P-10003' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 48, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC02' and s.code = 'D06' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10004', k.id, r.id, current_date - 47, 'day', s.id, 9464, 'approved', current_date - 47, current_date - 46, 'Marcus Webb (Lake Lefroy)', null, null
from contracts k, rigs r, staff s where k.code = 'C-099' and r.code = 'RC02' and s.code = 'D06'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-099' and h.hole_id = 'LLRC045'), 176, 80, 160, 'B-RC-4401', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-099' and h.hole_id = 'LLRC046'), 60, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-099' and h.hole_id = 'LLRC046'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-099' and h.hole_id = 'LLRC046'), 352, 0, 160, 'B-RC-4401', null),
    (6, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10004'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10004' and s.code = 'D06' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10004' and s.code = 'O06' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 240 from plods where number = 'P-10004' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 47, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC02' and s.code = 'D06' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10005', k.id, r.id, current_date - 13, 'day', s.id, 12241, 'approved', current_date - 13, current_date - 11, 'Hannah Moss (Red Dune)', null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC01' and s.code = 'D01'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC001'), 504, 0, 126, 'B-RC-4410', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10005'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10005' and s.code = 'D01' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10005' and s.code = 'O01' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 126 from plods where number = 'P-10005' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 13, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC01' and s.code = 'D01' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10006', k.id, r.id, current_date - 13, 'night', s.id, 12252, 'approved', current_date - 13, current_date - 11, 'Hannah Moss (Red Dune)', null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC01' and s.code = 'D03'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC001'), 216, 126, 180, 'B-RC-4410', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC003'), 60, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC003'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC003'), 224, 0, 56, 'B-RC-4410', null),
    (6, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10006'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10006' and s.code = 'D03' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10006' and s.code = 'O02' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 110 from plods where number = 'P-10006' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 13, 'night', s.id, true, null from rigs r, staff s where r.code = 'RC01' and s.code = 'D03' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10007', k.id, r.id, current_date - 12, 'day', s.id, 12263, 'approved', current_date - 12, current_date - 10, 'Hannah Moss (Red Dune)', null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC01' and s.code = 'D01'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC003'), 568, 56, 198, 'B-RC-4410', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10007'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10007' and s.code = 'D01' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10007' and s.code = 'O01' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 142 from plods where number = 'P-10007' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 12, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC01' and s.code = 'D01' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10008', k.id, r.id, current_date - 12, 'night', s.id, 12274, 'approved', current_date - 12, current_date - 10, 'Hannah Moss (Red Dune)', null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC01' and s.code = 'D03'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC003'), 48, 198, 210, 'B-RC-4410', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC005'), 60, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC005'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC005'), 456, 0, 114, 'B-RC-4410', null),
    (6, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10008'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10008' and s.code = 'D03' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10008' and s.code = 'O02' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 126 from plods where number = 'P-10008' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 12, 'night', s.id, true, null from rigs r, staff s where r.code = 'RC01' and s.code = 'D03' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10009', k.id, r.id, current_date - 11, 'day', s.id, 12285, 'approved', current_date - 11, current_date - 9, 'Hannah Moss (Red Dune)', null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC01' and s.code = 'D01'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC005'), 472, 114, 232, 'B-RC-4410', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10009'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10009' and s.code = 'D01' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10009' and s.code = 'O01' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 118 from plods where number = 'P-10009' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 11, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC01' and s.code = 'D01' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10010', k.id, r.id, current_date - 11, 'night', s.id, 12296, 'approved', current_date - 11, current_date - 9, 'Hannah Moss (Red Dune)', null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC01' and s.code = 'D03'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC005'), 32, 232, 240, 'B-RC-4410', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC007'), 60, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC007'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC007'), 536, 0, 134, 'B-RC-4410', null),
    (6, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10010'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10010' and s.code = 'D03' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10010' and s.code = 'O02' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 142 from plods where number = 'P-10010' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 11, 'night', s.id, true, null from rigs r, staff s where r.code = 'RC01' and s.code = 'D03' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10011', k.id, r.id, current_date - 10, 'day', s.id, 12307, 'approved', current_date - 10, current_date - 8, 'Hannah Moss (Red Dune)', null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC01' and s.code = 'D01'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC007'), 64, 134, 150, 'B-RC-4410', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC009'), 60, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC009'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC009'), 472, 0, 118, 'B-RC-4410', null),
    (6, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10011'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10011' and s.code = 'D01' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10011' and s.code = 'O01' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 134 from plods where number = 'P-10011' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 10, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC01' and s.code = 'D01' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10012', k.id, r.id, current_date - 10, 'night', s.id, 12318, 'approved', current_date - 10, current_date - 8, 'Hannah Moss (Red Dune)', null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC01' and s.code = 'D03'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC009'), 288, 118, 190, 'B-RC-4410', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC011'), 60, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC011'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC011'), 184, 0, 46, 'B-RC-4410', null),
    (6, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10012'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10012' and s.code = 'D03' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10012' and s.code = 'O02' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 118 from plods where number = 'P-10012' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 10, 'night', s.id, true, null from rigs r, staff s where r.code = 'RC01' and s.code = 'D03' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10013', k.id, r.id, current_date - 9, 'day', s.id, 12329, 'approved', current_date - 9, current_date - 7, 'Hannah Moss (Red Dune)', null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC01' and s.code = 'D01'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC011'), 440, 46, 156, 'B-RC-4410', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10013'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10013' and s.code = 'D01' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10013' and s.code = 'O01' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 110 from plods where number = 'P-10013' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 9, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC01' and s.code = 'D01' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10014', k.id, r.id, current_date - 9, 'night', s.id, 12340, 'approved', current_date - 9, current_date - 7, 'Hannah Moss (Red Dune)', null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC01' and s.code = 'D03'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC011'), 256, 156, 220, 'B-RC-4410', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC013'), 60, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC013'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC013'), 280, 0, 70, 'B-RC-4410', null),
    (6, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10014'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10014' and s.code = 'D03' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10014' and s.code = 'O02' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 134 from plods where number = 'P-10014' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 9, 'night', s.id, true, null from rigs r, staff s where r.code = 'RC01' and s.code = 'D03' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10015', k.id, r.id, current_date - 8, 'day', s.id, 12351, 'approved', current_date - 8, current_date - 6, 'Hannah Moss (Red Dune)', null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC01' and s.code = 'D01'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC013'), 440, 70, 180, 'B-RC-4410', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC015'), 60, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC015'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC015'), 64, 0, 16, 'B-RC-4410', null),
    (6, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10015'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10015' and s.code = 'D01' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10015' and s.code = 'O01' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 126 from plods where number = 'P-10015' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 8, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC01' and s.code = 'D01' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10016', k.id, r.id, current_date - 8, 'night', s.id, 12362, 'approved', current_date - 8, current_date - 6, 'Hannah Moss (Red Dune)', null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC01' and s.code = 'D03'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC015'), 440, 16, 126, 'B-RC-4410', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10016'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10016' and s.code = 'D03' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10016' and s.code = 'O02' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 110 from plods where number = 'P-10016' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 8, 'night', s.id, true, null from rigs r, staff s where r.code = 'RC01' and s.code = 'D03' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10017', k.id, r.id, current_date - 7, 'day', s.id, 12373, 'approved', current_date - 7, current_date - 5, 'Hannah Moss (Red Dune)', null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC01' and s.code = 'D01'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC015'), 176, 126, 170, 'B-RC-4411', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC017'), 60, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC017'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC017'), 392, 0, 98, 'B-RC-4411', null),
    (6, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10017'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10017' and s.code = 'D01' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10017' and s.code = 'O01' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 142 from plods where number = 'P-10017' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 7, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC01' and s.code = 'D01' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10018', k.id, r.id, current_date - 7, 'night', s.id, 12384, 'approved', current_date - 7, current_date - 5, 'Hannah Moss (Red Dune)', null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC01' and s.code = 'D03'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC017'), 328, 98, 180, 'B-RC-4411', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC019'), 60, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC019'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC019'), 176, 0, 44, 'B-RC-4411', null),
    (6, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10018'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10018' and s.code = 'D03' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10018' and s.code = 'O02' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 126 from plods where number = 'P-10018' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 7, 'night', s.id, true, null from rigs r, staff s where r.code = 'RC01' and s.code = 'D03' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10019', k.id, r.id, current_date - 6, 'day', s.id, 12395, 'approved', current_date - 6, current_date - 4, 'Hannah Moss (Red Dune)', null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC01' and s.code = 'D01'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC019'), 472, 44, 162, 'B-RC-4411', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10019'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10019' and s.code = 'D01' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10019' and s.code = 'O01' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 118 from plods where number = 'P-10019' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 6, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC01' and s.code = 'D01' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10020', k.id, r.id, current_date - 6, 'night', s.id, 12406, 'approved', current_date - 6, current_date - 4, 'Hannah Moss (Red Dune)', null, 'Three hours standby: client water truck late from Kalgoorlie.'
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC01' and s.code = 'D03'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'standby-client', null::uuid, 180, null::numeric, null::numeric, null, 'Waiting on client water truck'),
    (3, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC019'), 192, 162, 210, 'B-RC-4411', null),
    (4, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC021'), 60, null::numeric, null::numeric, null, null),
    (5, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC021'), 30, null::numeric, null::numeric, null, null),
    (6, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC021'), 128, 0, 32, 'B-RC-4411', null),
    (7, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10020'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10020' and s.code = 'D03' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10020' and s.code = 'O02' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 80 from plods where number = 'P-10020' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 6, 'night', s.id, true, null from rigs r, staff s where r.code = 'RC01' and s.code = 'D03' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10021', k.id, r.id, current_date - 5, 'day', s.id, 12417, 'approved', current_date - 5, current_date - 3, 'Hannah Moss (Red Dune)', null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC01' and s.code = 'D01'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC021'), 536, 32, 166, 'B-RC-4411', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10021'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10021' and s.code = 'D01' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10021' and s.code = 'O01' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 134 from plods where number = 'P-10021' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 5, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC01' and s.code = 'D01' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10022', k.id, r.id, current_date - 5, 'night', s.id, 12428, 'approved', current_date - 5, current_date - 3, 'Hannah Moss (Red Dune)', null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC01' and s.code = 'D03'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC021'), 296, 166, 240, 'B-RC-4411', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC023'), 60, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC023'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC023'), 176, 0, 44, 'B-RC-4411', null),
    (6, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10022'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10022' and s.code = 'D03' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10022' and s.code = 'O02' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 118 from plods where number = 'P-10022' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 5, 'night', s.id, true, null from rigs r, staff s where r.code = 'RC01' and s.code = 'D03' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10023', k.id, r.id, current_date - 4, 'day', s.id, 12439, 'submitted', current_date - 4, null, null, null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC01' and s.code = 'D01'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC023'), 424, 44, 150, 'B-RC-4411', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC025'), 60, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC025'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC025'), 16, 0, 4, 'B-RC-4411', null),
    (6, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10023'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10023' and s.code = 'D01' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10023' and s.code = 'O01' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 110 from plods where number = 'P-10023' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 4, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC01' and s.code = 'D01' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10024', k.id, r.id, current_date - 4, 'night', s.id, 12450, 'submitted', current_date - 4, null, null, null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC01' and s.code = 'D03'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC025'), 536, 4, 138, 'B-RC-4411', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10024'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10024' and s.code = 'D03' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10024' and s.code = 'O02' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 134 from plods where number = 'P-10024' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 4, 'night', s.id, true, null from rigs r, staff s where r.code = 'RC01' and s.code = 'D03' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10025', k.id, r.id, current_date - 3, 'day', s.id, 12461, 'submitted', current_date - 3, null, null, null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC01' and s.code = 'D01'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC025'), 208, 138, 190, 'B-RC-4411', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC027'), 60, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC027'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC027'), 296, 0, 74, 'B-RC-4411', null),
    (6, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10025'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10025' and s.code = 'D01' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10025' and s.code = 'O01' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 126 from plods where number = 'P-10025' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 3, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC01' and s.code = 'D01' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10026', k.id, r.id, current_date - 3, 'night', s.id, 12472, 'submitted', current_date - 3, null, null, null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC01' and s.code = 'D03'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC027'), 440, 74, 184, 'B-RC-4411', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10026'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10026' and s.code = 'D03' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10026' and s.code = 'O02' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 110 from plods where number = 'P-10026' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 3, 'night', s.id, true, null from rigs r, staff s where r.code = 'RC01' and s.code = 'D03' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10027', k.id, r.id, current_date - 2, 'day', s.id, 12483, 'submitted', current_date - 2, null, null, null, 'Ben stayed on 90 minutes to finish the rod change at the hole handover.'
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC01' and s.code = 'D01'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC027'), 144, 184, 220, 'B-RC-4411', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC029'), 60, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC029'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC029'), 424, 0, 106, 'B-RC-4411', null),
    (6, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10027'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10027' and s.code = 'D01' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 810 from plods p, staff s where p.number = 'P-10027' and s.code = 'O01' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 142 from plods where number = 'P-10027' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 2, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC01' and s.code = 'D01' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10028', k.id, r.id, current_date - 2, 'night', s.id, 12494, 'submitted', current_date - 2, null, null, null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC01' and s.code = 'D03'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC029'), 296, 106, 180, 'B-RC-4411', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC031'), 60, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC031'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC031'), 208, 0, 52, 'B-RC-4411', null),
    (6, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10028'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10028' and s.code = 'D03' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10028' and s.code = 'O02' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 126 from plods where number = 'P-10028' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 2, 'night', s.id, true, null from rigs r, staff s where r.code = 'RC01' and s.code = 'D03' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10029', k.id, r.id, current_date - 1, 'day', s.id, 12505, 'submitted', current_date - 1, null, null, null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC01' and s.code = 'D01'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC031'), 472, 52, 170, 'B-RC-4411', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC033'), 60, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC033'), 30, null::numeric, null::numeric, null, null),
    (5, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10029'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10029' and s.code = 'D01' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10029' and s.code = 'O01' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 118 from plods where number = 'P-10029' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 1, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC01' and s.code = 'D01' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10030', k.id, r.id, current_date - 1, 'night', s.id, 12516, 'submitted', current_date - 1, null, null, null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC01' and s.code = 'D03'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC033'), 568, 0, 142, 'B-RC-4411', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10030'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10030' and s.code = 'D03' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10030' and s.code = 'O02' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 142 from plods where number = 'P-10030' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 1, 'night', s.id, true, null from rigs r, staff s where r.code = 'RC01' and s.code = 'D03' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10031', k.id, r.id, current_date - 13, 'day', s.id, 9511, 'approved', current_date - 13, current_date - 11, 'Hannah Moss (Red Dune)', null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC02' and s.code = 'D06'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC002'), 519, 0, 118, 'B-RC-4412', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10031'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10031' and s.code = 'D06' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10031' and s.code = 'O06' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 118 from plods where number = 'P-10031' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 13, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC02' and s.code = 'D06' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10032', k.id, r.id, current_date - 12, 'day', s.id, 9522, 'approved', current_date - 12, current_date - 10, 'Hannah Moss (Red Dune)', null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC02' and s.code = 'D06'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC002'), 141, 118, 150, 'B-RC-4412', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC004'), 60, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC004'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC004'), 299, 0, 68, 'B-RC-4412', null),
    (6, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10032'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10032' and s.code = 'D06' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10032' and s.code = 'O06' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 100 from plods where number = 'P-10032' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 12, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC02' and s.code = 'D06' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10033', k.id, r.id, current_date - 11, 'day', s.id, 9533, 'approved', current_date - 11, current_date - 9, 'Hannah Moss (Red Dune)', null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC02' and s.code = 'D06'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC004'), 405, 68, 160, 'B-RC-4412', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC006'), 60, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC006'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC006'), 62, 0, 14, 'B-RC-4412', null),
    (6, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10033'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10033' and s.code = 'D06' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10033' and s.code = 'O06' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 106 from plods where number = 'P-10033' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 11, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC02' and s.code = 'D06' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10034', k.id, r.id, current_date - 10, 'day', s.id, 9544, 'approved', current_date - 10, current_date - 8, 'Hannah Moss (Red Dune)', null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC02' and s.code = 'D06'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC006'), 493, 14, 126, 'B-RC-4412', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10034'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10034' and s.code = 'D06' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10034' and s.code = 'O06' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 112 from plods where number = 'P-10034' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 10, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC02' and s.code = 'D06' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10035', k.id, r.id, current_date - 9, 'day', s.id, 9555, 'approved', current_date - 9, current_date - 7, 'Hannah Moss (Red Dune)', null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC02' and s.code = 'D06'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC006'), 194, 126, 170, 'B-RC-4412', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC008'), 60, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC008'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC008'), 326, 0, 74, 'B-RC-4412', null),
    (6, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10035'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10035' and s.code = 'D06' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10035' and s.code = 'O06' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 118 from plods where number = 'P-10035' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 9, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC02' and s.code = 'D06' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10036', k.id, r.id, current_date - 8, 'day', s.id, 9566, 'approved', current_date - 8, current_date - 6, 'Hannah Moss (Red Dune)', null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC02' and s.code = 'D06'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC008'), 440, 74, 174, 'B-RC-4413', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10036'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10036' and s.code = 'D06' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10036' and s.code = 'O06' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 100 from plods where number = 'P-10036' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 8, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC02' and s.code = 'D06' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10037', k.id, r.id, current_date - 7, 'day', s.id, 9577, 'approved', current_date - 7, current_date - 5, 'Hannah Moss (Red Dune)', null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC02' and s.code = 'D06'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC008'), 114, 174, 200, 'B-RC-4413', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC010'), 60, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC010'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC010'), 352, 0, 80, 'B-RC-4413', null),
    (6, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10037'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10037' and s.code = 'D06' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10037' and s.code = 'O06' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 106 from plods where number = 'P-10037' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 7, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC02' and s.code = 'D06' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10038', k.id, r.id, current_date - 6, 'day', s.id, 9588, 'approved', current_date - 6, current_date - 4, 'Hannah Moss (Red Dune)', null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC02' and s.code = 'D06'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC010'), 352, 80, 160, 'B-RC-4413', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC012'), 60, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC012'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC012'), 141, 0, 32, 'B-RC-4413', null),
    (6, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10038'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10038' and s.code = 'D06' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10038' and s.code = 'O06' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 112 from plods where number = 'P-10038' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 6, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC02' and s.code = 'D06' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10039', k.id, r.id, current_date - 5, 'day', s.id, 9599, 'approved', current_date - 5, current_date - 3, 'Hannah Moss (Red Dune)', null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC02' and s.code = 'D06'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC012'), 519, 32, 150, 'B-RC-4413', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC014'), 60, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC014'), 30, null::numeric, null::numeric, null, null),
    (5, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10039'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10039' and s.code = 'D06' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10039' and s.code = 'O06' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 118 from plods where number = 'P-10039' on conflict (plod_id, item) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10040', k.id, r.id, current_date - 4, 'day', s.id, 9610, 'submitted', current_date - 4, null, null, null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC02' and s.code = 'D06'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC014'), 440, 0, 100, 'B-RC-4413', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10040'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10040' and s.code = 'D06' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10040' and s.code = 'O06' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 100 from plods where number = 'P-10040' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 4, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC02' and s.code = 'D06' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10041', k.id, r.id, current_date - 3, 'day', s.id, 9613, 'submitted', current_date - 3, null, null, null, 'Booster compressor failure at 10:40. Parts ordered from Perth.'
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC02' and s.code = 'D06'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-101' and h.hole_id = 'MHRC014'), 120, 100, 130, 'B-RC-4413', null),
    (3, 'breakdown', null::uuid, 480, null::numeric, null::numeric, null, 'Compressor booster failed, rig stood down'),
    (4, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10041'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10041' and s.code = 'D06' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10041' and s.code = 'O06' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'sample-bags', 30 from plods where number = 'P-10041' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 3, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC02' and s.code = 'D06' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10042', k.id, r.id, current_date - 20, 'day', s.id, 7111, 'approved', current_date - 20, current_date - 19, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D04'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND001'), 546, 0, 42, 'B-HQ-2201', null),
    (3, 'survey', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND001'), 45, null::numeric, null::numeric, null, null),
    (4, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10042'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10042' and s.code = 'D04' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10042' and s.code = 'O03' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 9 from plods where number = 'P-10042' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 20, 'day', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D04' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10043', k.id, r.id, current_date - 20, 'night', s.id, 7122, 'approved', current_date - 20, current_date - 19, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D05'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND001'), 598, 42, 88, 'B-HQ-2201', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10043'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10043' and s.code = 'D05' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10043' and s.code = 'O04' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 10 from plods where number = 'P-10043' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 20, 'night', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D05' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10044', k.id, r.id, current_date - 19, 'day', s.id, 7133, 'approved', current_date - 19, current_date - 18, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D04'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND001'), 494, 88, 126, 'B-HQ-2201', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10044'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10044' and s.code = 'D04' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10044' and s.code = 'O03' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 8 from plods where number = 'P-10044' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 19, 'day', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D04' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10045', k.id, r.id, current_date - 19, 'night', s.id, 7144, 'approved', current_date - 19, current_date - 18, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D05'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND001'), 546, 126, 168, 'B-HQ-2201', null),
    (3, 'survey', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND001'), 45, null::numeric, null::numeric, null, null),
    (4, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10045'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10045' and s.code = 'D05' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10045' and s.code = 'O04' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 9 from plods where number = 'P-10045' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 19, 'night', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D05' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10046', k.id, r.id, current_date - 18, 'day', s.id, 7155, 'approved', current_date - 18, current_date - 17, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D04'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND001'), 650, 168, 218, 'B-HQ-2201', null),
    (3, 'survey', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND001'), 45, null::numeric, null::numeric, null, null),
    (4, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10046'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10046' and s.code = 'D04' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10046' and s.code = 'O03' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 11 from plods where number = 'P-10046' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 18, 'day', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D04' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10047', k.id, r.id, current_date - 18, 'night', s.id, 7166, 'approved', current_date - 18, current_date - 17, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D05'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND001'), 494, 218, 256, 'B-HQ-2201', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10047'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10047' and s.code = 'D05' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10047' and s.code = 'O04' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 8 from plods where number = 'P-10047' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 18, 'night', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D05' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10048', k.id, r.id, current_date - 17, 'day', s.id, 7177, 'approved', current_date - 17, current_date - 16, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D04'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND001'), 598, 256, 302, 'B-HQ-2201', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10048'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10048' and s.code = 'D04' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10048' and s.code = 'O03' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 10 from plods where number = 'P-10048' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 17, 'day', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D04' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10049', k.id, r.id, current_date - 17, 'night', s.id, 7188, 'approved', current_date - 17, current_date - 16, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D05'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND001'), 650, 302, 352, 'B-HQ-2201', null),
    (3, 'survey', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND001'), 45, null::numeric, null::numeric, null, null),
    (4, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10049'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10049' and s.code = 'D05' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10049' and s.code = 'O04' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 11 from plods where number = 'P-10049' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 17, 'night', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D05' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10050', k.id, r.id, current_date - 16, 'day', s.id, 7199, 'approved', current_date - 16, current_date - 15, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D04'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND001'), 546, 352, 394, 'B-HQ-2201', null),
    (3, 'survey', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND001'), 45, null::numeric, null::numeric, null, null),
    (4, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10050'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10050' and s.code = 'D04' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10050' and s.code = 'O03' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 9 from plods where number = 'P-10050' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 16, 'day', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D04' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10051', k.id, r.id, current_date - 16, 'night', s.id, 7210, 'approved', current_date - 16, current_date - 15, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D05'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND001'), 338, 394, 420, 'B-HQ-2201', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND002'), 120, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND002'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND002'), 260, 0, 20, 'B-HQ-2201', null),
    (6, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10051'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10051' and s.code = 'D05' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10051' and s.code = 'O04' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 10 from plods where number = 'P-10051' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 16, 'night', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D05' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10052', k.id, r.id, current_date - 15, 'day', s.id, 7221, 'approved', current_date - 15, current_date - 14, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D04'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND002'), 494, 20, 58, 'B-HQ-2201', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10052'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10052' and s.code = 'D04' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10052' and s.code = 'O03' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 8 from plods where number = 'P-10052' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 15, 'day', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D04' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10053', k.id, r.id, current_date - 15, 'night', s.id, 7232, 'approved', current_date - 15, current_date - 14, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D05'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND002'), 546, 58, 100, 'B-HQ-2201', null),
    (3, 'survey', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND002'), 45, null::numeric, null::numeric, null, null),
    (4, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10053'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10053' and s.code = 'D05' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10053' and s.code = 'O04' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 9 from plods where number = 'P-10053' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 15, 'night', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D05' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10054', k.id, r.id, current_date - 14, 'day', s.id, 7243, 'approved', current_date - 14, current_date - 13, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D04'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND002'), 650, 100, 150, 'B-HQ-2201', null),
    (3, 'survey', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND002'), 45, null::numeric, null::numeric, null, null),
    (4, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10054'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10054' and s.code = 'D04' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10054' and s.code = 'O03' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 11 from plods where number = 'P-10054' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 14, 'day', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D04' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10055', k.id, r.id, current_date - 14, 'night', s.id, 7254, 'approved', current_date - 14, current_date - 13, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D05'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND002'), 494, 150, 188, 'B-HQ-2201', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10055'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10055' and s.code = 'D05' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10055' and s.code = 'O04' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 8 from plods where number = 'P-10055' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 14, 'night', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D05' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10056', k.id, r.id, current_date - 13, 'day', s.id, 7265, 'approved', current_date - 13, current_date - 12, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D04'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND002'), 598, 188, 234, 'B-HQ-2201', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10056'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10056' and s.code = 'D04' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10056' and s.code = 'O03' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 10 from plods where number = 'P-10056' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 13, 'day', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D04' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10057', k.id, r.id, current_date - 13, 'night', s.id, 7276, 'approved', current_date - 13, current_date - 12, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D05'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND002'), 650, 234, 284, 'B-HQ-2201', null),
    (3, 'survey', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND002'), 45, null::numeric, null::numeric, null, null),
    (4, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10057'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10057' and s.code = 'D05' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10057' and s.code = 'O04' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 11 from plods where number = 'P-10057' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 13, 'night', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D05' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10058', k.id, r.id, current_date - 12, 'day', s.id, 7287, 'approved', current_date - 12, current_date - 11, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D04'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND002'), 546, 284, 326, 'B-HQ-2201', null),
    (3, 'survey', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND002'), 45, null::numeric, null::numeric, null, null),
    (4, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10058'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10058' and s.code = 'D04' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10058' and s.code = 'O03' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 9 from plods where number = 'P-10058' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 12, 'day', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D04' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10059', k.id, r.id, current_date - 12, 'night', s.id, 7298, 'approved', current_date - 12, current_date - 11, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D05'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND002'), 598, 326, 372, 'B-HQ-2201', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10059'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10059' and s.code = 'D05' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10059' and s.code = 'O04' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 10 from plods where number = 'P-10059' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 12, 'night', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D05' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10060', k.id, r.id, current_date - 11, 'day', s.id, 7309, 'approved', current_date - 11, current_date - 10, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D04'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND002'), 494, 372, 410, 'B-NQ-3101', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10060'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10060' and s.code = 'D04' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10060' and s.code = 'O03' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 8 from plods where number = 'P-10060' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 11, 'day', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D04' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10061', k.id, r.id, current_date - 11, 'night', s.id, 7320, 'approved', current_date - 11, current_date - 10, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D05'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND002'), 546, 410, 452, 'B-NQ-3101', null),
    (3, 'survey', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND002'), 45, null::numeric, null::numeric, null, null),
    (4, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10061'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10061' and s.code = 'D05' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10061' and s.code = 'O04' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 9 from plods where number = 'P-10061' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 11, 'night', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D05' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10062', k.id, r.id, current_date - 10, 'day', s.id, 7331, 'approved', current_date - 10, current_date - 9, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D04'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND002'), 650, 452, 502, 'B-NQ-3101', null),
    (3, 'survey', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND002'), 45, null::numeric, null::numeric, null, null),
    (4, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10062'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10062' and s.code = 'D04' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10062' and s.code = 'O03' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 11 from plods where number = 'P-10062' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 10, 'day', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D04' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10063', k.id, r.id, current_date - 10, 'night', s.id, 7342, 'approved', current_date - 10, current_date - 9, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D05'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND002'), 234, 502, 520, 'B-NQ-3101', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND003'), 120, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND003'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND003'), 260, 0, 20, 'B-HQ-2202', null),
    (6, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10063'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10063' and s.code = 'D05' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10063' and s.code = 'O04' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 8 from plods where number = 'P-10063' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 10, 'night', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D05' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10064', k.id, r.id, current_date - 9, 'day', s.id, 7353, 'approved', current_date - 9, current_date - 8, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D04'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'standby-client', null::uuid, 120, null::numeric, null::numeric, null, 'Waiting on geologist to call end of hole'),
    (3, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND003'), 598, 20, 66, 'B-HQ-2202', null),
    (4, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10064'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10064' and s.code = 'D04' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10064' and s.code = 'O03' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 10 from plods where number = 'P-10064' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 9, 'day', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D04' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10065', k.id, r.id, current_date - 9, 'night', s.id, 7364, 'approved', current_date - 9, current_date - 8, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D05'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND003'), 650, 66, 116, 'B-HQ-2202', null),
    (3, 'survey', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND003'), 45, null::numeric, null::numeric, null, null),
    (4, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10065'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10065' and s.code = 'D05' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10065' and s.code = 'O04' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 11 from plods where number = 'P-10065' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 9, 'night', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D05' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10066', k.id, r.id, current_date - 8, 'day', s.id, 7375, 'approved', current_date - 8, current_date - 7, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D04'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND003'), 546, 116, 158, 'B-HQ-2202', null),
    (3, 'survey', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND003'), 45, null::numeric, null::numeric, null, null),
    (4, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10066'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10066' and s.code = 'D04' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10066' and s.code = 'O03' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 9 from plods where number = 'P-10066' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 8, 'day', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D04' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10067', k.id, r.id, current_date - 8, 'night', s.id, 7386, 'approved', current_date - 8, current_date - 7, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D05'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND003'), 598, 158, 204, 'B-HQ-2202', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10067'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10067' and s.code = 'D05' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10067' and s.code = 'O04' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 10 from plods where number = 'P-10067' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 8, 'night', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D05' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10068', k.id, r.id, current_date - 7, 'day', s.id, 7397, 'approved', current_date - 7, current_date - 6, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D04'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND003'), 494, 204, 242, 'B-HQ-2202', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10068'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10068' and s.code = 'D04' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10068' and s.code = 'O03' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 8 from plods where number = 'P-10068' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 7, 'day', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D04' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10069', k.id, r.id, current_date - 7, 'night', s.id, 7408, 'approved', current_date - 7, current_date - 6, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D05'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND003'), 546, 242, 284, 'B-HQ-2202', null),
    (3, 'survey', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND003'), 45, null::numeric, null::numeric, null, null),
    (4, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10069'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10069' and s.code = 'D05' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10069' and s.code = 'O04' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 9 from plods where number = 'P-10069' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 7, 'night', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D05' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10070', k.id, r.id, current_date - 6, 'day', s.id, 7419, 'approved', current_date - 6, current_date - 5, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D04'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND003'), 650, 284, 334, 'B-HQ-2202', null),
    (3, 'survey', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND003'), 45, null::numeric, null::numeric, null, null),
    (4, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10070'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10070' and s.code = 'D04' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10070' and s.code = 'O03' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 11 from plods where number = 'P-10070' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 6, 'day', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D04' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10071', k.id, r.id, current_date - 6, 'night', s.id, 7430, 'rejected', current_date - 6, null, null, 'Core loss 212 to 218 m not explained; standby needs the geologist named.', null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D05'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'standby-client', null::uuid, 90, null::numeric, null::numeric, null, 'Waiting on geologist'),
    (3, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND003'), 494, 334, 372, 'B-NQ-3101', null),
    (4, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10071'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10071' and s.code = 'D05' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10071' and s.code = 'O04' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 8 from plods where number = 'P-10071' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 6, 'night', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D05' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10072', k.id, r.id, current_date - 5, 'day', s.id, 7441, 'approved', current_date - 5, current_date - 4, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D04'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND003'), 598, 372, 418, 'B-NQ-3101', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10072'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10072' and s.code = 'D04' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10072' and s.code = 'O03' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 10 from plods where number = 'P-10072' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 5, 'day', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D04' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10073', k.id, r.id, current_date - 5, 'night', s.id, 7452, 'approved', current_date - 5, current_date - 4, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D05'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND003'), 650, 418, 468, 'B-NQ-3101', null),
    (3, 'survey', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND003'), 45, null::numeric, null::numeric, null, null),
    (4, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10073'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10073' and s.code = 'D05' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10073' and s.code = 'O04' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 11 from plods where number = 'P-10073' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 5, 'night', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D05' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10074', k.id, r.id, current_date - 4, 'day', s.id, 7463, 'approved', current_date - 4, current_date - 3, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D04'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND003'), 156, 468, 480, 'B-NQ-3101', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND004'), 120, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND004'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND004'), 390, 0, 30, 'B-HQ-2202', null),
    (6, 'survey', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND004'), 45, null::numeric, null::numeric, null, null),
    (7, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10074'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10074' and s.code = 'D04' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10074' and s.code = 'O03' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 9 from plods where number = 'P-10074' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 4, 'day', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D04' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10075', k.id, r.id, current_date - 4, 'night', s.id, 7474, 'approved', current_date - 4, current_date - 3, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D05'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND004'), 598, 30, 76, 'B-HQ-2202', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10075'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10075' and s.code = 'D05' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10075' and s.code = 'O04' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 10 from plods where number = 'P-10075' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 4, 'night', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D05' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10076', k.id, r.id, current_date - 3, 'day', s.id, 7485, 'approved', current_date - 3, current_date - 2, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D04'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND004'), 494, 76, 114, 'B-HQ-2202', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10076'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10076' and s.code = 'D04' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10076' and s.code = 'O03' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 8 from plods where number = 'P-10076' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 3, 'day', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D04' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10077', k.id, r.id, current_date - 3, 'night', s.id, 7496, 'approved', current_date - 3, current_date - 2, 'Owen Carter (Kurrawang)', null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D05'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND004'), 546, 114, 156, 'B-HQ-2202', null),
    (3, 'survey', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND004'), 45, null::numeric, null::numeric, null, null),
    (4, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10077'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10077' and s.code = 'D05' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10077' and s.code = 'O04' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 9 from plods where number = 'P-10077' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 3, 'night', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D05' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10078', k.id, r.id, current_date - 2, 'day', s.id, 7507, 'submitted', current_date - 2, null, null, null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D04'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND004'), 650, 156, 206, 'B-HQ-2202', null),
    (3, 'survey', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND004'), 45, null::numeric, null::numeric, null, null),
    (4, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10078'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10078' and s.code = 'D04' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10078' and s.code = 'O03' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 11 from plods where number = 'P-10078' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 2, 'day', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D04' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10079', k.id, r.id, current_date - 2, 'night', s.id, 7518, 'submitted', current_date - 2, null, null, null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D05'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND004'), 494, 206, 244, 'B-HQ-2202', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10079'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10079' and s.code = 'D05' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10079' and s.code = 'O04' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 8 from plods where number = 'P-10079' on conflict (plod_id, item) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10080', k.id, r.id, current_date - 1, 'day', s.id, 7529, 'submitted', current_date - 1, null, null, null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D04'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND004'), 598, 244, 290, 'B-HQ-2202', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10080'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10080' and s.code = 'D04' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10080' and s.code = 'O03' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 10 from plods where number = 'P-10080' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 1, 'day', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D04' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10081', k.id, r.id, current_date - 1, 'night', s.id, 7540, 'submitted', current_date - 1, null, null, null, null
from contracts k, rigs r, staff s where k.code = 'C-102' and r.code = 'DD01' and s.code = 'D05'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND004'), 650, 290, 340, 'B-HQ-2202', null),
    (3, 'survey', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-102' and h.hole_id = 'KND004'), 45, null::numeric, null::numeric, null, null),
    (4, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10081'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10081' and s.code = 'D05' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 720 from plods p, staff s where p.number = 'P-10081' and s.code = 'O04' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'core-trays', 11 from plods where number = 'P-10081' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 1, 'night', s.id, true, null from rigs r, staff s where r.code = 'DD01' and s.code = 'D05' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10082', k.id, r.id, current_date - 9, 'day', s.id, 3210, 'approved', current_date - 9, current_date - 8, 'Rosie Hart (Yindi)', null, null
from contracts k, rigs r, staff s where k.code = 'C-103' and r.code = 'WB01' and s.code = 'D02'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-103' and h.hole_id = 'YWB01'), 432, 0, 48, 'B-TC-0901', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10082'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 660 from plods p, staff s where p.number = 'P-10082' and s.code = 'D02' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 660 from plods p, staff s where p.number = 'P-10082' and s.code = 'O05' on conflict (plod_id, staff_id) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 9, 'day', s.id, true, null from rigs r, staff s where r.code = 'WB01' and s.code = 'D02' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10083', k.id, r.id, current_date - 8, 'day', s.id, 3220, 'approved', current_date - 8, current_date - 7, 'Rosie Hart (Yindi)', null, null
from contracts k, rigs r, staff s where k.code = 'C-103' and r.code = 'WB01' and s.code = 'D02'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-103' and h.hole_id = 'YWB01'), 432, 48, 96, 'B-TC-0901', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10083'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 660 from plods p, staff s where p.number = 'P-10083' and s.code = 'D02' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 660 from plods p, staff s where p.number = 'P-10083' and s.code = 'O05' on conflict (plod_id, staff_id) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 8, 'day', s.id, true, null from rigs r, staff s where r.code = 'WB01' and s.code = 'D02' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10084', k.id, r.id, current_date - 7, 'day', s.id, 3230, 'approved', current_date - 7, current_date - 6, 'Rosie Hart (Yindi)', null, null
from contracts k, rigs r, staff s where k.code = 'C-103' and r.code = 'WB01' and s.code = 'D02'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-103' and h.hole_id = 'YWB01'), 216, 96, 120, 'B-TC-0901', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-103' and h.hole_id = 'YWB02'), 90, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-103' and h.hole_id = 'YWB02'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-103' and h.hole_id = 'YWB02'), 216, 0, 24, 'B-TC-0901', null),
    (6, 'development', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-103' and h.hole_id = 'YWB01'), 240, null::numeric, null::numeric, null, 'Airlift development until clear'),
    (7, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10084'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 660 from plods p, staff s where p.number = 'P-10084' and s.code = 'D02' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 660 from plods p, staff s where p.number = 'P-10084' and s.code = 'O05' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'pvc-casing-155', 120 from plods where number = 'P-10084' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 7, 'day', s.id, false, 'Hydraulic hose weeping at the mast ram. Tagged out, replaced before drilling.' from rigs r, staff s where r.code = 'WB01' and s.code = 'D02' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10085', k.id, r.id, current_date - 6, 'day', s.id, 3240, 'approved', current_date - 6, current_date - 5, 'Rosie Hart (Yindi)', null, null
from contracts k, rigs r, staff s where k.code = 'C-103' and r.code = 'WB01' and s.code = 'D02'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-103' and h.hole_id = 'YWB02'), 432, 24, 72, 'B-TC-0901', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10085'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 660 from plods p, staff s where p.number = 'P-10085' and s.code = 'D02' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 660 from plods p, staff s where p.number = 'P-10085' and s.code = 'O05' on conflict (plod_id, staff_id) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 6, 'day', s.id, true, null from rigs r, staff s where r.code = 'WB01' and s.code = 'D02' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10086', k.id, r.id, current_date - 5, 'day', s.id, 3250, 'approved', current_date - 5, current_date - 4, 'Rosie Hart (Yindi)', null, null
from contracts k, rigs r, staff s where k.code = 'C-103' and r.code = 'WB01' and s.code = 'D02'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-103' and h.hole_id = 'YWB02'), 432, 72, 120, 'B-TC-0901', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10086'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 660 from plods p, staff s where p.number = 'P-10086' and s.code = 'D02' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 660 from plods p, staff s where p.number = 'P-10086' and s.code = 'O05' on conflict (plod_id, staff_id) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 5, 'day', s.id, true, null from rigs r, staff s where r.code = 'WB01' and s.code = 'D02' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10087', k.id, r.id, current_date - 4, 'day', s.id, 3260, 'approved', current_date - 4, current_date - 3, 'Rosie Hart (Yindi)', null, null
from contracts k, rigs r, staff s where k.code = 'C-103' and r.code = 'WB01' and s.code = 'D02'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-103' and h.hole_id = 'YWB02'), 180, 120, 140, 'B-TC-0902', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-103' and h.hole_id = 'YWB03'), 90, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-103' and h.hole_id = 'YWB03'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-103' and h.hole_id = 'YWB03'), 252, 0, 28, 'B-TC-0902', null),
    (6, 'development', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-103' and h.hole_id = 'YWB02'), 240, null::numeric, null::numeric, null, 'Airlift development until clear'),
    (7, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10087'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 660 from plods p, staff s where p.number = 'P-10087' and s.code = 'D02' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 660 from plods p, staff s where p.number = 'P-10087' and s.code = 'O05' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'pvc-casing-155', 140 from plods where number = 'P-10087' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 4, 'day', s.id, true, null from rigs r, staff s where r.code = 'WB01' and s.code = 'D02' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10088', k.id, r.id, current_date - 3, 'day', s.id, 3270, 'approved', current_date - 3, current_date - 2, 'Rosie Hart (Yindi)', null, null
from contracts k, rigs r, staff s where k.code = 'C-103' and r.code = 'WB01' and s.code = 'D02'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-103' and h.hole_id = 'YWB03'), 432, 28, 76, 'B-TC-0902', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10088'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 660 from plods p, staff s where p.number = 'P-10088' and s.code = 'D02' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 660 from plods p, staff s where p.number = 'P-10088' and s.code = 'O05' on conflict (plod_id, staff_id) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 3, 'day', s.id, true, null from rigs r, staff s where r.code = 'WB01' and s.code = 'D02' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10089', k.id, r.id, current_date - 2, 'day', s.id, 3280, 'submitted', current_date - 2, null, null, null, null
from contracts k, rigs r, staff s where k.code = 'C-103' and r.code = 'WB01' and s.code = 'D02'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-103' and h.hole_id = 'YWB03'), 306, 76, 110, 'B-TC-0902', null),
    (3, 'rig-move', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-103' and h.hole_id = 'YWB04'), 90, null::numeric, null::numeric, null, null),
    (4, 'rig-up', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-103' and h.hole_id = 'YWB04'), 30, null::numeric, null::numeric, null, null),
    (5, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-103' and h.hole_id = 'YWB04'), 126, 0, 14, 'B-TC-0902', null),
    (6, 'development', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-103' and h.hole_id = 'YWB03'), 240, null::numeric, null::numeric, null, 'Airlift development until clear'),
    (7, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10089'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 660 from plods p, staff s where p.number = 'P-10089' and s.code = 'D02' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 660 from plods p, staff s where p.number = 'P-10089' and s.code = 'O05' on conflict (plod_id, staff_id) do nothing;
insert into plod_consumables (plod_id, item, qty) select id, 'pvc-casing-155', 110 from plods where number = 'P-10089' on conflict (plod_id, item) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 2, 'day', s.id, true, null from rigs r, staff s where r.code = 'WB01' and s.code = 'D02' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10090', k.id, r.id, current_date - 1, 'day', s.id, 3290, 'submitted', current_date - 1, null, null, null, null
from contracts k, rigs r, staff s where k.code = 'C-103' and r.code = 'WB01' and s.code = 'D02'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null),
    (2, 'drilling', (select h.id from holes h join contracts k on k.id = h.contract_id where k.code = 'C-103' and h.hole_id = 'YWB04'), 432, 14, 62, 'B-TC-0902', null),
    (3, 'meal', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10090'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 660 from plods p, staff s where p.number = 'P-10090' and s.code = 'D02' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 660 from plods p, staff s where p.number = 'P-10090' and s.code = 'O05' on conflict (plod_id, staff_id) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date - 1, 'day', s.id, true, null from rigs r, staff s where r.code = 'WB01' and s.code = 'D02' on conflict (rig_id, done_on, shift) do nothing;
insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, status, submitted_on, approved_on, approved_by, reject_reason, comments)
select 'P-10091', k.id, r.id, current_date, 'day', s.id, null, 'draft', null, null, null, null, null
from contracts k, rigs r, staff s where k.code = 'C-101' and r.code = 'RC01' and s.code = 'D01'
on conflict (rig_id, plod_date, shift) do nothing;
insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
select p.id, v.line, v.activity, v.hole_id, v.minutes, v.from_m, v.to_m, v.bit_serial, v.notes from plods p,
  (values (1, 'safety', null::uuid, 30, null::numeric, null::numeric, null, null)) as v(line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes)
where p.number = 'P-10091'
on conflict (plod_id, line) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 0 from plods p, staff s where p.number = 'P-10091' and s.code = 'D01' on conflict (plod_id, staff_id) do nothing;
insert into plod_crew (plod_id, staff_id, minutes) select p.id, s.id, 0 from plods p, staff s where p.number = 'P-10091' and s.code = 'O01' on conflict (plod_id, staff_id) do nothing;
insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) select r.id, current_date, 'day', s.id, true, null from rigs r, staff s where r.code = 'RC01' and s.code = 'D01' on conflict (rig_id, done_on, shift) do nothing;

-- claims take the approved plods in their period
update plods set claim_id = (select id from claims where number = 'CL-0991')
  where claim_id is null and status = 'approved' and plod_date <= current_date - 48 and contract_id = (select id from contracts where code = 'C-099');
update plods set claim_id = (select id from claims where number = 'CL-0992')
  where claim_id is null and status = 'approved' and plod_date <= current_date - 46 and contract_id = (select id from contracts where code = 'C-099');
update plods set claim_id = (select id from claims where number = 'CL-1011')
  where claim_id is null and status = 'approved' and plod_date <= current_date - 7 and contract_id = (select id from contracts where code = 'C-101');
update claims c set amount_cents = coalesce((select sum(v.amount_cents) from v_plod_charges v where v.claim_id = c.id), 0)
  where c.number in ('CL-0991', 'CL-0992', 'CL-1011');
update claims set paid_cents = amount_cents where number = 'CL-0991';

insert into rig_services (rig_id, serviced_on, engine_hours, kind, notes) select id, current_date - 22, 12250, 'service', '250 hour service' from rigs where code = 'RC01' on conflict do nothing;
insert into rig_services (rig_id, serviced_on, engine_hours, kind, notes) select id, current_date - 30, 9550, 'service', '250 hour service' from rigs where code = 'RC02' on conflict do nothing;
insert into rig_services (rig_id, serviced_on, engine_hours, kind, notes) select id, current_date - 25, 7650, 'service', '250 hour service' from rigs where code = 'DD01' on conflict do nothing;
insert into rig_services (rig_id, serviced_on, engine_hours, kind, notes) select id, current_date - 12, 3250, 'service', '250 hour service' from rigs where code = 'WB01' on conflict do nothing;

insert into incidents (number, occurred_on, contract_id, rig_id, kind, description, notifiable, notified_on, closed_on)
select 'IN-031', current_date - 8, k.id, r.id, 'near-miss', 'Offsider''s glove caught between rod and breakout clamp. No injury. Toolbox talk held on hands-free rod handling.', false, null, current_date - 6
from contracts k, rigs r where k.code = 'C-101' and r.code = 'RC01' on conflict (number) do nothing;
insert into incidents (number, occurred_on, contract_id, rig_id, kind, description, notifiable, notified_on, closed_on)
select 'IN-032', current_date - 2, k.id, r.id, 'dangerous-incident', 'High-pressure hose on the mud pump failed and released drilling fluid under pressure across the rig floor. Area cleared, no one hit.', true, null, null
from contracts k, rigs r where k.code = 'C-102' and r.code = 'DD01' on conflict (number) do nothing;

insert into notes (contract_id, rig_id, body, author)
select k.id, r.id, 'Booster parts due Thursday on the Perth freight run. Craig and Ravi on workshop duties until then.', 'Priya Nair'
from contracts k, rigs r where k.code = 'C-101' and r.code = 'RC02' and not exists (select 1 from notes);

