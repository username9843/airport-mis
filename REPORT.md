# Ercan Airport Management Information System
## Project Report

---

## 1. Introduction

### Overview
This database system manages all operational data for **Ercan Airport (LCEN)**, North Cyprus. It covers fleet management, personnel (technicians, traffic controllers, all staff), airworthiness testing, hangar logistics, flight operations, and maintenance.

### Assumptions
| # | Assumption |
|---|---|
| 1 | Each employee has a unique SSN (primary identifier) and belongs to exactly one union |
| 2 | A plane has exactly one model, but a model can be flown by many planes |
| 3 | A plane can be in at most one hangar at a time (enforced via partial unique index) |
| 4 | Hangar assignment history is preserved — `time_out IS NULL` means currently parked |
| 5 | A technician can be expert in multiple plane models; expertise overlaps are allowed |
| 6 | Test results (`pass/fail/conditional`) are auto-derived by trigger from score vs. pass threshold |
| 7 | Traffic controllers require one annual medical exam; only the most recent date is stored |
| 8 | Flights reference ICAO airport codes (5 chars max) for origin/destination |
| 9 | Repair orders track cost only when completed; open repairs have NULL cost |
| 10 | All timestamps are stored with timezone (`TIMESTAMPTZ`) |

---

## 2. ER Diagram

See `ERD.svg` (rendered separately) or the schema below.

### Entities & Relationships Summary

```
UNIONS ──< EMPLOYEES >── (subtype) TECHNICIANS ──< TECHNICIAN_EXPERTISE >── PLANE_MODELS
                    │                     │                                        │
                    └── TRAFFIC_CONTROLLERS                                   AIRPLANES
                                                                                  │
                         TESTS ──< TEST_EVENTS >── TECHNICIANS           HANGARS ─< HANGAR_ASSIGNMENTS
                                                                                  │
                                                                              FLIGHTS >── FLIGHT_CONTROLLER_ASSIGNMENTS
                                                                                  │
                                                                          RUNWAYS    REPAIR_ORDERS
```

---

## 3. Relational Data Model

### Tables (12 total)

| Table | PK | Description |
|---|---|---|
| `unions` | union_id | Trade unions all employees belong to |
| `employees` | ssn | All airport staff (supertype) |
| `technicians` | ssn (FK) | Technician subtype; license & specialization |
| `technician_expertise` | (ssn, model_no) | M:N — technician certified on model |
| `traffic_controllers` | ssn (FK) | Controller subtype; certification & medical |
| `plane_models` | model_no | Aircraft model catalog (Boeing, Airbus, etc.) |
| `airplanes` | plane_no | Individual aircraft stationed at airport |
| `hangars` | hangar_no | Physical hangars with type & capacity |
| `hangar_assignments` | assignment_id | Plane ↔ hangar with IN/OUT timestamps |
| `tests` | test_id | Catalog of airworthiness tests |
| `test_events` | event_id | Each testing instance (plane, tech, test, score) |
| `repair_orders` | repair_id | Maintenance work orders |
| `runways` | runway_id | Airport runways |
| `flights` | flight_id | Flight records with actual vs scheduled times |
| `flight_controller_assignments` | (flight_id, ssn) | M:N — controller assigned to flight |

### Key Relationships
- `employees` → `unions` : Many-to-one
- `technicians` → `employees` : One-to-one (ISA / subtype)
- `traffic_controllers` → `employees` : One-to-one (ISA / subtype)
- `technician_expertise` → `technicians`, `plane_models` : Many-to-many
- `airplanes` → `plane_models` : Many-to-one
- `hangar_assignments` → `airplanes`, `hangars` : Many-to-many with time dimension
- `test_events` → `airplanes`, `tests`, `technicians` : Ternary relationship
- `repair_orders` → `airplanes`, `employees`, `technicians` : Many-to-one each
- `flights` → `airplanes`, `runways` : Many-to-one each
- `flight_controller_assignments` → `flights`, `traffic_controllers` : Many-to-many

---

## 4. DDL Summary

### Custom Types
- `employee_type` ENUM: technician, traffic_controller, ground_crew, admin, security, manager
- `airplane_status` ENUM: active, maintenance, grounded, retired
- `flight_status` ENUM: scheduled, boarding, departed, arrived, cancelled, delayed
- `test_result` ENUM: pass, fail, conditional
- `repair_status` ENUM: open, in_progress, completed, deferred
- `hangar_type` ENUM: storage, maintenance, overhaul

### Constraints Highlights
| Constraint | Table | Rule |
|---|---|---|
| `chk_hire_after_birth` | employees | hire_date > birth_date |
| `chk_timeout_after_in` | hangar_assignments | time_out > time_in |
| `chk_pass_lte_max` | tests | pass_score ≤ max_score |
| `chk_medical_not_future` | traffic_controllers | last_medical_exam ≤ today |
| `ux_plane_active_assignment` | hangar_assignments | Partial unique: one open assignment per plane |
| `chk_arrive_after_depart` | flights | scheduled_arrive > scheduled_depart |

### Trigger
`set_test_result` — BEFORE INSERT/UPDATE on `test_events`: auto-derives `result` (pass/conditional/fail) based on score vs. test's `pass_score`.

### Indexes
Performance indexes on: `airplanes(model_no, status)`, `test_events(plane_no, technician_ssn, test_date)`, `flights(plane_no, scheduled_depart)`, `repair_orders(status)`, `hangar_assignments(plane_no)`, `employees(emp_type)`.

---

## 5. DML Summary

Seed data includes:
- 5 unions, 13 employees (5 technicians, 3 traffic controllers, 5 other)
- 8 plane models, 10 airplanes
- 5 hangars, 8 hangar assignment records
- 10 test types, 18 test events
- 5 repair orders
- 2 runways, 10 flights, 18 controller-flight assignments

---

## 6. Management Queries (15)

| # | Query | Technique |
|---|---|---|
| Q1 | Fleet status breakdown | GROUP BY, window function (SUM OVER) |
| Q2 | Technician expertise breadth | JOIN, GROUP BY, STRING_AGG |
| Q3 | Currently parked aircraft | JOIN, WHERE time_out IS NULL, EXTRACT |
| Q4 | Test pass/fail rates | CASE WHEN aggregation, GROUP BY |
| Q5 | Top technicians by avg score | JOIN, GROUP BY, ORDER BY |
| Q6 | Aircraft test history + days since | LEFT JOIN, GROUP BY, date arithmetic |
| Q7 | Medical exam compliance | JOIN, date subtraction, CASE WHEN |
| Q8 | Flight punctuality by airline | EXTRACT(EPOCH), AVG, GROUP BY |
| Q9 | Maintenance cost per aircraft | LEFT JOIN, COALESCE, NULLIF |
| Q10 | Hangar utilization % | LEFT JOIN, GROUP BY, ROUND |
| Q11 | Safety watchlist (recent failures) | Multi-JOIN, WHERE result='fail' |
| Q12 | Technician workload this year | Correlated subquery, EXTRACT(YEAR) |
| Q13 | Monthly flight volume | TO_CHAR, GROUP BY month+destination |
| Q14 | Aging aircraft report (>15 yrs) | AGE(), DATE_PART, LEFT JOIN aggregate |
| Q15 | Union payroll & contract status | JOIN, TO_CHAR, salary bands, CASE WHEN |

---

## 7. Extensions Beyond Minimum Requirements

1. **Repair Orders** — full work order system with priority, cost tracking, open/closed lifecycle
2. **Flights & Runways** — operational flight records with actual vs scheduled time (punctuality analysis)
3. **Controller ↔ Flight M:N** — role-based assignment (tower, ground, approach)
4. **Auto-derive test results** — database trigger enforces business logic consistently
5. **Partial unique index** — prevents double hangar assignment at database level
6. **ENUMs** — type safety for status fields throughout schema
7. **employee_type discriminator** — single-table inheritance for future extensibility
8. **Hangar manager FK** — hangars track their responsible manager

---

*Database: PostgreSQL 15+ | Ercan Airport LCEN, North Cyprus*
