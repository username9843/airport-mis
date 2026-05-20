-- ============================================================
-- ERCAN AIRPORT MANAGEMENT INFORMATION SYSTEM
-- DDL - PostgreSQL
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- ENUMS
-- ────────────────────────────────────────────────────────────
CREATE TYPE employee_type     AS ENUM ('technician', 'traffic_controller', 'ground_crew', 'admin', 'security', 'manager');
CREATE TYPE airplane_status   AS ENUM ('active', 'maintenance', 'grounded', 'retired');
CREATE TYPE flight_status     AS ENUM ('scheduled', 'boarding', 'departed', 'arrived', 'cancelled', 'delayed');
CREATE TYPE test_result       AS ENUM ('pass', 'fail', 'conditional');
CREATE TYPE repair_status     AS ENUM ('open', 'in_progress', 'completed', 'deferred');
CREATE TYPE hangar_type       AS ENUM ('storage', 'maintenance', 'overhaul');

-- ────────────────────────────────────────────────────────────
-- UNIONS
-- ────────────────────────────────────────────────────────────
CREATE TABLE unions (
    union_id     SERIAL        PRIMARY KEY,
    union_name   VARCHAR(100)  NOT NULL UNIQUE,
    contract_end DATE,
    contact_info TEXT
);

-- ────────────────────────────────────────────────────────────
-- EMPLOYEES (supertype)
-- ────────────────────────────────────────────────────────────
CREATE TABLE employees (
    ssn              CHAR(11)        PRIMARY KEY,          -- ###-##-####
    first_name       VARCHAR(50)     NOT NULL,
    last_name        VARCHAR(50)     NOT NULL,
    birth_date       DATE            NOT NULL,
    hire_date        DATE            NOT NULL DEFAULT CURRENT_DATE,
    email            VARCHAR(100)    NOT NULL UNIQUE,
    phone            VARCHAR(20),
    salary           NUMERIC(10,2)   NOT NULL CHECK (salary > 0),
    emp_type         employee_type   NOT NULL,
    union_id         INT             NOT NULL REFERENCES unions(union_id),
    union_member_no  VARCHAR(30)     NOT NULL UNIQUE,
    is_active        BOOLEAN         NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_hire_after_birth CHECK (hire_date > birth_date)
);

-- ────────────────────────────────────────────────────────────
-- TRAFFIC CONTROLLERS (subtype)
-- ────────────────────────────────────────────────────────────
CREATE TABLE traffic_controllers (
    ssn              CHAR(11)   PRIMARY KEY REFERENCES employees(ssn) ON DELETE CASCADE,
    certification_no VARCHAR(30) NOT NULL UNIQUE,
    last_medical_exam DATE       NOT NULL,
    clearance_level  SMALLINT   NOT NULL DEFAULT 1 CHECK (clearance_level BETWEEN 1 AND 5),
    CONSTRAINT chk_medical_not_future CHECK (last_medical_exam <= CURRENT_DATE)
);

-- ────────────────────────────────────────────────────────────
-- PLANE MODELS
-- ────────────────────────────────────────────────────────────
CREATE TABLE plane_models (
    model_no         VARCHAR(20)  PRIMARY KEY,
    manufacturer     VARCHAR(80)  NOT NULL,
    model_name       VARCHAR(80)  NOT NULL,
    capacity         SMALLINT     NOT NULL CHECK (capacity > 0),
    max_range_km     INT          CHECK (max_range_km > 0),
    engine_count     SMALLINT     NOT NULL CHECK (engine_count > 0),
    max_takeoff_weight_kg NUMERIC(12,2),
    service_ceiling_ft    INT,
    introduced_year  SMALLINT
);

-- ────────────────────────────────────────────────────────────
-- TECHNICIANS (subtype) + expertise
-- ────────────────────────────────────────────────────────────
CREATE TABLE technicians (
    ssn              CHAR(11)    PRIMARY KEY REFERENCES employees(ssn) ON DELETE CASCADE,
    license_no       VARCHAR(30) NOT NULL UNIQUE,
    specialization   VARCHAR(80),
    years_experience SMALLINT    CHECK (years_experience >= 0)
);

CREATE TABLE technician_expertise (
    ssn      CHAR(11)    NOT NULL REFERENCES technicians(ssn) ON DELETE CASCADE,
    model_no VARCHAR(20) NOT NULL REFERENCES plane_models(model_no) ON DELETE CASCADE,
    PRIMARY KEY (ssn, model_no)
);

-- ────────────────────────────────────────────────────────────
-- AIRPLANES
-- ────────────────────────────────────────────────────────────
CREATE TABLE airplanes (
    plane_no          VARCHAR(20)     PRIMARY KEY,
    model_no          VARCHAR(20)     NOT NULL REFERENCES plane_models(model_no),
    registration_no   VARCHAR(20)     NOT NULL UNIQUE,
    manufacture_date  DATE            NOT NULL,
    last_service_date DATE,
    total_flight_hours NUMERIC(10,2)  NOT NULL DEFAULT 0 CHECK (total_flight_hours >= 0),
    status            airplane_status NOT NULL DEFAULT 'active',
    airline           VARCHAR(80),
    notes             TEXT
);

-- ────────────────────────────────────────────────────────────
-- HANGARS
-- ────────────────────────────────────────────────────────────
CREATE TABLE hangars (
    hangar_no    VARCHAR(10)   PRIMARY KEY,
    location     VARCHAR(100)  NOT NULL,
    hangar_type  hangar_type   NOT NULL DEFAULT 'storage',
    capacity     SMALLINT      NOT NULL CHECK (capacity > 0),
    area_sqm     NUMERIC(10,2),
    manager_ssn  CHAR(11)      REFERENCES employees(ssn) ON DELETE SET NULL
);

-- ────────────────────────────────────────────────────────────
-- HANGAR ASSIGNMENTS (airplane ↔ hangar with IN/OUT times)
-- ────────────────────────────────────────────────────────────
CREATE TABLE hangar_assignments (
    assignment_id  SERIAL       PRIMARY KEY,
    plane_no       VARCHAR(20)  NOT NULL REFERENCES airplanes(plane_no) ON DELETE CASCADE,
    hangar_no      VARCHAR(10)  NOT NULL REFERENCES hangars(hangar_no)  ON DELETE CASCADE,
    time_in        TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    time_out       TIMESTAMPTZ,
    reason         VARCHAR(200),
    CONSTRAINT chk_timeout_after_in CHECK (time_out IS NULL OR time_out > time_in)
);

-- Prevent double-booking: a plane can only be in one hangar at a time
CREATE UNIQUE INDEX ux_plane_active_assignment
    ON hangar_assignments (plane_no)
    WHERE time_out IS NULL;

-- ────────────────────────────────────────────────────────────
-- TESTS (catalog of available tests)
-- ────────────────────────────────────────────────────────────
CREATE TABLE tests (
    test_id       SERIAL        PRIMARY KEY,
    test_name     VARCHAR(100)  NOT NULL UNIQUE,
    description   TEXT,
    max_score     NUMERIC(6,2)  NOT NULL DEFAULT 100 CHECK (max_score > 0),
    pass_score    NUMERIC(6,2)  NOT NULL CHECK (pass_score > 0),
    applicable_to VARCHAR(20)   REFERENCES plane_models(model_no) ON DELETE SET NULL, -- NULL = all models
    CONSTRAINT chk_pass_lte_max CHECK (pass_score <= max_score)
);

-- ────────────────────────────────────────────────────────────
-- TESTING EVENTS
-- ────────────────────────────────────────────────────────────
CREATE TABLE test_events (
    event_id       SERIAL        PRIMARY KEY,
    plane_no       VARCHAR(20)   NOT NULL REFERENCES airplanes(plane_no) ON DELETE CASCADE,
    test_id        INT           NOT NULL REFERENCES tests(test_id),
    technician_ssn CHAR(11)      NOT NULL REFERENCES technicians(ssn),
    test_date      DATE          NOT NULL DEFAULT CURRENT_DATE,
    hours_spent    NUMERIC(5,2)  NOT NULL CHECK (hours_spent > 0),
    score          NUMERIC(6,2)  NOT NULL CHECK (score >= 0),
    result         test_result   NOT NULL,
    remarks        TEXT,
    CONSTRAINT chk_score_lte_max CHECK (score <= 999.99) -- validated at app layer vs test max
);

-- Auto-derive result based on score vs pass threshold (trigger)
CREATE OR REPLACE FUNCTION trg_derive_test_result()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE v_pass NUMERIC;
BEGIN
    SELECT pass_score INTO v_pass FROM tests WHERE test_id = NEW.test_id;
    NEW.result := CASE WHEN NEW.score >= v_pass THEN 'pass'::test_result
                       WHEN NEW.score >= v_pass * 0.85 THEN 'conditional'::test_result
                       ELSE 'fail'::test_result END;
    RETURN NEW;
END;
$$;

CREATE TRIGGER set_test_result
    BEFORE INSERT OR UPDATE OF score ON test_events
    FOR EACH ROW EXECUTE FUNCTION trg_derive_test_result();

-- ────────────────────────────────────────────────────────────
-- REPAIR ORDERS (extended requirement)
-- ────────────────────────────────────────────────────────────
CREATE TABLE repair_orders (
    repair_id      SERIAL        PRIMARY KEY,
    plane_no       VARCHAR(20)   NOT NULL REFERENCES airplanes(plane_no),
    reported_by    CHAR(11)      REFERENCES employees(ssn) ON DELETE SET NULL,
    assigned_tech  CHAR(11)      REFERENCES technicians(ssn) ON DELETE SET NULL,
    opened_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    closed_at      TIMESTAMPTZ,
    description    TEXT          NOT NULL,
    priority       SMALLINT      NOT NULL DEFAULT 3 CHECK (priority BETWEEN 1 AND 5),
    status         repair_status NOT NULL DEFAULT 'open',
    cost           NUMERIC(12,2) CHECK (cost >= 0),
    CONSTRAINT chk_close_after_open CHECK (closed_at IS NULL OR closed_at > opened_at)
);

-- ────────────────────────────────────────────────────────────
-- RUNWAYS
-- ────────────────────────────────────────────────────────────
CREATE TABLE runways (
    runway_id       SERIAL        PRIMARY KEY,
    runway_code     VARCHAR(10)   NOT NULL UNIQUE,  -- e.g. '06/24'
    length_m        INT           NOT NULL CHECK (length_m > 0),
    width_m         INT           NOT NULL CHECK (width_m > 0),
    surface_type    VARCHAR(30)   NOT NULL DEFAULT 'asphalt',
    is_operational  BOOLEAN       NOT NULL DEFAULT TRUE
);

-- ────────────────────────────────────────────────────────────
-- FLIGHTS
-- ────────────────────────────────────────────────────────────
CREATE TABLE flights (
    flight_id         SERIAL        PRIMARY KEY,
    flight_no         VARCHAR(12)   NOT NULL,
    plane_no          VARCHAR(20)   NOT NULL REFERENCES airplanes(plane_no),
    runway_id         INT           REFERENCES runways(runway_id) ON DELETE SET NULL,
    origin            VARCHAR(5)    NOT NULL,  -- ICAO code
    destination       VARCHAR(5)    NOT NULL,
    scheduled_depart  TIMESTAMPTZ   NOT NULL,
    scheduled_arrive  TIMESTAMPTZ   NOT NULL,
    actual_depart     TIMESTAMPTZ,
    actual_arrive     TIMESTAMPTZ,
    status            flight_status NOT NULL DEFAULT 'scheduled',
    passenger_count   SMALLINT      CHECK (passenger_count >= 0),
    CONSTRAINT chk_arrive_after_depart CHECK (scheduled_arrive > scheduled_depart)
);

-- Controller ↔ Flight assignment (many-to-many)
CREATE TABLE flight_controller_assignments (
    flight_id  INT      NOT NULL REFERENCES flights(flight_id) ON DELETE CASCADE,
    ssn        CHAR(11) NOT NULL REFERENCES traffic_controllers(ssn) ON DELETE CASCADE,
    role       VARCHAR(50) NOT NULL DEFAULT 'ground',
    PRIMARY KEY (flight_id, ssn)
);

-- ────────────────────────────────────────────────────────────
-- INDEXES FOR PERFORMANCE
-- ────────────────────────────────────────────────────────────
CREATE INDEX idx_airplanes_model       ON airplanes(model_no);
CREATE INDEX idx_airplanes_status      ON airplanes(status);
CREATE INDEX idx_test_events_plane     ON test_events(plane_no);
CREATE INDEX idx_test_events_tech      ON test_events(technician_ssn);
CREATE INDEX idx_test_events_date      ON test_events(test_date);
CREATE INDEX idx_hangar_assign_plane   ON hangar_assignments(plane_no);
CREATE INDEX idx_flights_plane         ON flights(plane_no);
CREATE INDEX idx_flights_scheduled     ON flights(scheduled_depart);
CREATE INDEX idx_repair_status         ON repair_orders(status);
CREATE INDEX idx_employees_type        ON employees(emp_type);
