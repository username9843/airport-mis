-- ============================================================
-- ERCAN AIRPORT MANAGEMENT INFORMATION SYSTEM
-- DML - Sample Data
-- ============================================================

-- ── UNIONS ──────────────────────────────────────────────────
INSERT INTO unions (union_name, contract_end, contact_info) VALUES
  ('Aviation Workers Union',       '2026-12-31', 'awu@ercan.aero'),
  ('Air Traffic Controllers Guild', '2025-06-30', 'atcg@ercan.aero'),
  ('Technical Staff Association',   '2027-03-31', 'tsa@ercan.aero'),
  ('Security Personnel Union',      '2026-09-30', 'spu@ercan.aero'),
  ('Airport Admin Union',           '2026-12-31', 'aau@ercan.aero');

-- ── PLANE MODELS ────────────────────────────────────────────
INSERT INTO plane_models VALUES
  ('B737-800',  'Boeing',   '737-800',         189, 5765, 2, 79016.0, 41000, 1998),
  ('B737-MAX8', 'Boeing',   '737 MAX 8',        189, 6570, 2, 82191.5, 41000, 2017),
  ('A320-200',  'Airbus',   'A320-200',         180, 6150, 2, 77000.0, 39800, 1988),
  ('A320NEO',   'Airbus',   'A320neo',          194, 6300, 2, 79000.0, 39800, 2014),
  ('B777-300',  'Boeing',   '777-300',          396, 11121,2, 299370.0,43100, 1997),
  ('ATR72-600', 'ATR',      'ATR 72-600',        70, 1528, 2, 23000.0, 25000, 2009),
  ('B757-200',  'Boeing',   '757-200',          200, 7250, 2, 115680.0,42000, 1982),
  ('E190-E2',   'Embraer',  'E190-E2',          114, 5278, 2, 56400.0, 41000, 2018);

-- ── EMPLOYEES ───────────────────────────────────────────────
INSERT INTO employees (ssn, first_name, last_name, birth_date, hire_date, email, phone, salary, emp_type, union_id, union_member_no) VALUES
-- Technicians
  ('111-22-3333','Ali',      'Yilmaz',  '1978-04-12','2005-06-01','ali.yilmaz@ercan.aero',   '+90-533-111-0001', 65000, 'technician',          3,'TSA-0001'),
  ('222-33-4444','Mehmet',   'Kaya',    '1982-09-23','2010-03-15','mehmet.kaya@ercan.aero',  '+90-533-111-0002', 60000, 'technician',          3,'TSA-0002'),
  ('333-44-5555','Fatma',    'Demir',   '1990-01-07','2015-07-20','fatma.demir@ercan.aero',  '+90-533-111-0003', 58000, 'technician',          3,'TSA-0003'),
  ('444-55-6666','Hasan',    'Çelik',   '1975-11-30','2001-01-10','hasan.celik@ercan.aero',  '+90-533-111-0004', 72000, 'technician',          3,'TSA-0004'),
  ('555-66-7777','Ayse',     'Ozturk',  '1988-06-14','2013-09-01','ayse.ozturk@ercan.aero',  '+90-533-111-0005', 61000, 'technician',          3,'TSA-0005'),
-- Traffic Controllers
  ('666-77-8888','Ibrahim',  'Sahin',   '1980-02-28','2007-04-15','ibrahim.sahin@ercan.aero', '+90-533-111-0006', 75000, 'traffic_controller',  2,'ATCG-0001'),
  ('777-88-9999','Zeynep',   'Arslan',  '1985-08-03','2011-06-01','zeynep.arslan@ercan.aero', '+90-533-111-0007', 73000, 'traffic_controller',  2,'ATCG-0002'),
  ('888-99-0000','Mustafa',  'Korkmaz', '1977-12-19','2003-10-20','mustafa.korkmaz@ercan.aero','+90-533-111-0008',78000, 'traffic_controller',  2,'ATCG-0003'),
-- Ground / Admin / Security
  ('999-00-1111','Elif',     'Kurt',    '1992-03-25','2018-01-15','elif.kurt@ercan.aero',     '+90-533-111-0009', 45000, 'ground_crew',         1,'AWU-0001'),
  ('101-11-2222','Burak',    'Polat',   '1983-07-09','2009-11-01','burak.polat@ercan.aero',   '+90-533-111-0010', 55000, 'admin',               5,'AAU-0001'),
  ('121-31-4141','Serkan',   'Aksoy',   '1986-05-17','2012-08-20','serkan.aksoy@ercan.aero',  '+90-533-111-0011', 50000, 'security',            4,'SPU-0001'),
  ('131-41-5151','Derya',    'Yildiz',  '1991-11-02','2017-03-10','derya.yildiz@ercan.aero',  '+90-533-111-0012', 48000, 'ground_crew',         1,'AWU-0002'),
  ('141-51-6161','Emre',     'Aydın',   '1979-08-21','2006-05-01','emre.aydin@ercan.aero',    '+90-533-111-0013', 80000, 'manager',             5,'AAU-0002');

-- ── TECHNICIANS (subtype) ────────────────────────────────────
INSERT INTO technicians VALUES
  ('111-22-3333','LIC-ERN-001','Airframe & Powerplant', 19),
  ('222-33-4444','LIC-ERN-002','Avionics',              14),
  ('333-44-5555','LIC-ERN-003','Hydraulics',             9),
  ('444-55-6666','LIC-ERN-004','Engines',               23),
  ('555-66-7777','LIC-ERN-005','Electrical Systems',    11);

-- ── TECHNICIAN EXPERTISE ────────────────────────────────────
INSERT INTO technician_expertise VALUES
  ('111-22-3333','B737-800'),('111-22-3333','B737-MAX8'),('111-22-3333','A320-200'),
  ('222-33-4444','A320-200'),('222-33-4444','A320NEO'),  ('222-33-4444','E190-E2'),
  ('333-44-5555','ATR72-600'),('333-44-5555','B737-800'),
  ('444-55-6666','B777-300'), ('444-55-6666','B757-200'),('444-55-6666','B737-MAX8'),
  ('555-66-7777','A320NEO'),  ('555-66-7777','E190-E2'), ('555-66-7777','ATR72-600');

-- ── TRAFFIC CONTROLLERS (subtype) ───────────────────────────
INSERT INTO traffic_controllers VALUES
  ('666-77-8888','ATC-CY-0001','2024-11-15',4),
  ('777-88-9999','ATC-CY-0002','2025-01-20',3),
  ('888-99-0000','ATC-CY-0003','2024-09-05',5);

-- ── HANGARS ─────────────────────────────────────────────────
INSERT INTO hangars VALUES
  ('H-01','North Apron - Bay 1',  'storage',     8, 4500.00,'141-51-6161'),
  ('H-02','North Apron - Bay 2',  'storage',     6, 3800.00,'141-51-6161'),
  ('H-03','South Maintenance Hub','maintenance',  4, 6200.00,'141-51-6161'),
  ('H-04','Overhaul Facility',    'overhaul',     2,12000.00,'141-51-6161'),
  ('H-05','West Cargo Hangar',    'storage',     10, 8000.00,'141-51-6161');

-- ── AIRPLANES ────────────────────────────────────────────────
INSERT INTO airplanes VALUES
  ('TC-ERN01','B737-800', 'TC-ERN01','2008-03-12','2025-01-10',28450.50,'active',  'Cyprus Airways',   NULL),
  ('TC-ERN02','A320-200', 'TC-ERN02','2011-07-22','2024-12-05',19320.00,'active',  'Cyprus Airways',   NULL),
  ('TC-ERN03','ATR72-600','TC-ERN03','2017-05-18','2025-02-14', 8200.75,'active',  'Kıbrıs Hava',      NULL),
  ('TC-ERN04','B737-MAX8','TC-ERN04','2020-01-30','2025-03-01', 5100.20,'active',  'Pegasus Airlines', NULL),
  ('TC-ERN05','A320NEO',  'TC-ERN05','2019-11-09','2025-01-22', 7800.00,'active',  'SunExpress',       NULL),
  ('TC-ERN06','B777-300', 'TC-ERN06','2005-08-14','2024-11-30',52300.00,'maintenance','Turkish Airlines',NULL),
  ('TC-ERN07','E190-E2',  'TC-ERN07','2021-06-07','2025-04-10', 3450.00,'active',  'Kıbrıs Hava',      NULL),
  ('TC-ERN08','B757-200', 'TC-ERN08','2003-02-19','2023-08-01',68900.00,'grounded','Charter Co.',       'Pending retirement review'),
  ('TC-ERN09','A320-200', 'TC-ERN09','2013-09-25','2024-10-15',21500.00,'active',  'Cyprus Airways',   NULL),
  ('TC-ERN10','B737-800', 'TC-ERN10','2015-04-11','2025-02-28',15600.00,'active',  'Pegasus Airlines', NULL);

-- ── HANGAR ASSIGNMENTS ───────────────────────────────────────
INSERT INTO hangar_assignments (plane_no, hangar_no, time_in, time_out, reason) VALUES
  -- historical (completed)
  ('TC-ERN01','H-01','2024-11-01 08:00','2024-11-05 16:00','Routine overnight storage'),
  ('TC-ERN02','H-02','2024-12-10 09:00','2024-12-11 07:00','Weather hold'),
  ('TC-ERN06','H-03','2024-11-20 10:00','2024-12-01 17:00','Engine inspection'),
  ('TC-ERN08','H-04','2023-08-02 08:00','2023-08-30 17:00','Major overhaul'),
  ('TC-ERN03','H-01','2025-01-15 06:00','2025-01-16 06:00','Overnight storage'),
  -- currently parked (no time_out)
  ('TC-ERN06','H-03','2025-04-01 09:00', NULL, 'Major maintenance - gear'),
  ('TC-ERN08','H-04','2025-03-10 08:00', NULL, 'Awaiting decommission decision'),
  ('TC-ERN04','H-02','2025-05-18 22:00', NULL, 'Overnight storage');

-- ── TESTS (catalog) ─────────────────────────────────────────
INSERT INTO tests (test_name, description, max_score, pass_score, applicable_to) VALUES
  ('Engine Performance Test',    'Full engine run-up and performance metrics',           100, 75, NULL),
  ('Hydraulic System Check',     'Pressure tests on all hydraulic circuits',             100, 80, NULL),
  ('Avionics Calibration',       'Navigation and comm system calibration',               100, 85, NULL),
  ('Landing Gear Inspection',    'Visual and functional landing gear check',             100, 90, NULL),
  ('Pressurization Test',        'Cabin pressurization leak test',                       100, 85, NULL),
  ('Fuel System Integrity',      'Fuel tanks, lines and valve inspection',               100, 80, NULL),
  ('Flight Control Surfaces',    'Ailerons, elevators, rudder travel checks',            100, 90, NULL),
  ('Electrical Systems Audit',   'Complete electrical wiring and component audit',       100, 75, NULL),
  ('Turboprop Power Check',      'Power output and propeller efficiency',                100, 80, 'ATR72-600'),
  ('ETOPS Compliance Review',    'Extended-range twin-engine ops requirements',          100, 95, 'B777-300');

-- ── TEST EVENTS ──────────────────────────────────────────────
INSERT INTO test_events (plane_no, test_id, technician_ssn, test_date, hours_spent, score, remarks) VALUES
  ('TC-ERN01','1','111-22-3333','2025-01-10', 3.5, 88.0, 'Engine 1 slightly below peak - monitored'),
  ('TC-ERN01','4','111-22-3333','2025-01-10', 1.5, 96.0, NULL),
  ('TC-ERN02','3','222-33-4444','2024-12-05', 2.0, 92.0, NULL),
  ('TC-ERN02','7','222-33-4444','2024-12-05', 2.5, 87.0, NULL),
  ('TC-ERN03','9','333-44-5555','2025-02-14', 4.0, 78.0, 'Propeller pitch slightly off, adjusted'),
  ('TC-ERN03','6','333-44-5555','2025-02-14', 1.0, 95.0, NULL),
  ('TC-ERN04','1','444-55-6666','2025-03-01', 3.0, 99.0, 'Excellent - new aircraft'),
  ('TC-ERN04','5','444-55-6666','2025-03-01', 2.0, 98.0, NULL),
  ('TC-ERN05','3','555-66-7777','2025-01-22', 2.5, 89.0, NULL),
  ('TC-ERN06','10','444-55-6666','2024-11-30', 6.0, 72.0, 'ETOPS non-compliant - grounded for maintenance'),
  ('TC-ERN06','2','333-44-5555','2025-04-02', 3.0, 85.0, 'Post-repair hydraulics recheck'),
  ('TC-ERN07','8','555-66-7777','2025-04-10', 2.0, 91.0, NULL),
  ('TC-ERN08','4','111-22-3333','2023-08-15', 2.5, 62.0, 'Gear cracks found - major repair required'),
  ('TC-ERN09','2','333-44-5555','2024-10-15', 2.0, 93.0, NULL),
  ('TC-ERN10','1','111-22-3333','2025-02-28', 3.5, 82.0, NULL),
  ('TC-ERN10','7','222-33-4444','2025-02-28', 2.0, 90.0, NULL),
  ('TC-ERN01','2','333-44-5555','2025-03-20', 2.5, 79.0, NULL),
  ('TC-ERN05','1','444-55-6666','2025-02-10', 4.0, 94.0, NULL);

-- ── REPAIR ORDERS ────────────────────────────────────────────
INSERT INTO repair_orders (plane_no, reported_by, assigned_tech, opened_at, closed_at, description, priority, status, cost) VALUES
  ('TC-ERN06','444-55-6666','444-55-6666','2024-11-30 14:00',NULL,
   'ETOPS failure - nose gear actuator cracked. Full replacement required.',1,'in_progress',NULL),
  ('TC-ERN08','111-22-3333','111-22-3333','2023-08-15 10:00','2023-08-29 15:00',
   'Main landing gear structural cracks - replaced.',1,'completed',85000.00),
  ('TC-ERN01','111-22-3333','444-55-6666','2025-01-10 12:00','2025-01-15 09:00',
   'Engine 1 fuel injector cleaning and calibration.',3,'completed',4200.00),
  ('TC-ERN03','333-44-5555','333-44-5555','2025-02-14 16:00','2025-02-17 11:00',
   'Propeller pitch mechanism lubrication and adjustment.',2,'completed',1800.00),
  ('TC-ERN05','555-66-7777',NULL,'2025-05-10 09:00',NULL,
   'Minor avionics firmware update pending.',4,'open',NULL);

-- ── RUNWAYS ──────────────────────────────────────────────────
INSERT INTO runways VALUES
  (DEFAULT,'11/29', 2870, 45, 'asphalt', TRUE),
  (DEFAULT,'05/23', 1800, 30, 'asphalt', FALSE); -- under maintenance

-- ── FLIGHTS ──────────────────────────────────────────────────
INSERT INTO flights (flight_no,plane_no,runway_id,origin,destination,scheduled_depart,scheduled_arrive,actual_depart,actual_arrive,status,passenger_count) VALUES
  ('CY101','TC-ERN01',1,'LCEN','LGAV','2025-05-01 07:00','2025-05-01 08:30','2025-05-01 07:05','2025-05-01 08:35','arrived',  165),
  ('CY102','TC-ERN02',1,'LGAV','LCEN','2025-05-01 10:00','2025-05-01 11:30','2025-05-01 10:10','2025-05-01 11:40','arrived',  158),
  ('PC301','TC-ERN04',1,'LCEN','LTFM','2025-05-02 06:00','2025-05-02 07:20','2025-05-02 06:00','2025-05-02 07:18','arrived',  180),
  ('XQ401','TC-ERN05',1,'LCEN','EDDF','2025-05-03 14:00','2025-05-03 17:10','2025-05-03 14:05','2025-05-03 17:15','arrived',  175),
  ('CY103','TC-ERN09',1,'LCEN','LGAV','2025-05-05 08:00','2025-05-05 09:30', NULL,              NULL,              'cancelled',0),
  ('K4501','TC-ERN03',1,'LCEN','LTAC','2025-05-06 09:00','2025-05-06 10:10','2025-05-06 09:15','2025-05-06 10:25','arrived',   66),
  ('CY201','TC-ERN10',1,'LCEN','LCLK','2025-05-10 11:00','2025-05-10 11:30','2025-05-10 11:00','2025-05-10 11:32','arrived',  145),
  ('PC302','TC-ERN04',1,'LTFM','LCEN','2025-05-12 16:00','2025-05-12 17:20',NULL,              NULL,              'scheduled',NULL),
  ('CY104','TC-ERN01',1,'LCEN','LTFM','2025-05-15 07:30','2025-05-15 08:50','2025-05-15 07:35','2025-05-15 08:52','arrived',  171),
  ('XQ402','TC-ERN07',1,'LCEN','EGLL','2025-05-20 13:00','2025-05-20 16:00', NULL,              NULL,              'boarding', NULL);

-- ── CONTROLLER ASSIGNMENTS ───────────────────────────────────
INSERT INTO flight_controller_assignments VALUES
  (1,'666-77-8888','tower'),  (1,'777-88-9999','ground'),
  (2,'777-88-9999','tower'),  (2,'888-99-0000','ground'),
  (3,'888-99-0000','tower'),  (3,'666-77-8888','ground'),
  (4,'666-77-8888','tower'),  (4,'777-88-9999','approach'),
  (5,'777-88-9999','tower'),
  (6,'888-99-0000','tower'),  (6,'666-77-8888','ground'),
  (7,'666-77-8888','tower'),  (7,'888-99-0000','ground'),
  (8,'777-88-9999','tower'),
  (9,'888-99-0000','tower'),  (9,'666-77-8888','ground'),
  (10,'666-77-8888','tower'), (10,'777-88-9999','approach');
