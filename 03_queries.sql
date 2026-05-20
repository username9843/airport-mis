-- ============================================================
-- ERCAN AIRPORT MANAGEMENT INFORMATION SYSTEM
-- 15 Management Queries
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- Q1: Fleet status summary — how many planes per status
-- ────────────────────────────────────────────────────────────
SELECT
    status,
    COUNT(*)                                  AS total_planes,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct_of_fleet
FROM airplanes
GROUP BY status
ORDER BY total_planes DESC;

-- ────────────────────────────────────────────────────────────
-- Q2: Technicians and the number of plane models they are
--     certified on, ordered by expertise breadth
-- ────────────────────────────────────────────────────────────
SELECT
    e.ssn,
    e.first_name || ' ' || e.last_name        AS technician,
    t.specialization,
    COUNT(te.model_no)                         AS models_certified,
    STRING_AGG(te.model_no, ', ' ORDER BY te.model_no) AS models
FROM technicians t
JOIN employees e USING (ssn)
LEFT JOIN technician_expertise te USING (ssn)
GROUP BY e.ssn, e.first_name, e.last_name, t.specialization
ORDER BY models_certified DESC;

-- ────────────────────────────────────────────────────────────
-- Q3: Airplanes currently parked in hangars (active assignments)
-- ────────────────────────────────────────────────────────────
SELECT
    a.plane_no,
    pm.model_name,
    a.airline,
    h.hangar_no,
    h.location,
    h.hangar_type,
    ha.time_in,
    EXTRACT(DAY FROM NOW() - ha.time_in)       AS days_parked,
    ha.reason
FROM hangar_assignments ha
JOIN airplanes a   ON ha.plane_no  = a.plane_no
JOIN plane_models pm ON a.model_no = pm.model_no
JOIN hangars h     ON ha.hangar_no = h.hangar_no
WHERE ha.time_out IS NULL
ORDER BY days_parked DESC;

-- ────────────────────────────────────────────────────────────
-- Q4: Test pass/fail rates per test — identify problem tests
-- ────────────────────────────────────────────────────────────
SELECT
    t.test_name,
    COUNT(*)                                   AS times_conducted,
    SUM(CASE WHEN te.result = 'pass'        THEN 1 ELSE 0 END) AS passes,
    SUM(CASE WHEN te.result = 'conditional' THEN 1 ELSE 0 END) AS conditionals,
    SUM(CASE WHEN te.result = 'fail'        THEN 1 ELSE 0 END) AS failures,
    ROUND(AVG(te.score), 2)                    AS avg_score,
    ROUND(MIN(te.score), 2)                    AS min_score,
    ROUND(MAX(te.score), 2)                    AS max_score
FROM test_events te
JOIN tests t USING (test_id)
GROUP BY t.test_id, t.test_name
ORDER BY failures DESC, avg_score;

-- ────────────────────────────────────────────────────────────
-- Q5: Top performing technicians by average test score
--     and total hours worked on testing
-- ────────────────────────────────────────────────────────────
SELECT
    e.first_name || ' ' || e.last_name         AS technician,
    t.specialization,
    COUNT(te.event_id)                          AS tests_performed,
    ROUND(SUM(te.hours_spent), 1)              AS total_hours,
    ROUND(AVG(te.score), 2)                    AS avg_score_given,
    SUM(CASE WHEN te.result = 'fail' THEN 1 ELSE 0 END) AS fails_found
FROM test_events te
JOIN technicians t  ON te.technician_ssn = t.ssn
JOIN employees e    ON t.ssn = e.ssn
GROUP BY e.first_name, e.last_name, t.specialization
ORDER BY avg_score_given DESC;

-- ────────────────────────────────────────────────────────────
-- Q6: Aircraft test history with most recent result per plane
-- ────────────────────────────────────────────────────────────
SELECT
    a.plane_no,
    pm.model_name,
    a.airline,
    a.status,
    COUNT(te.event_id)                          AS total_tests,
    ROUND(AVG(te.score), 2)                    AS avg_score,
    MAX(te.test_date)                           AS last_test_date,
    (NOW()::DATE - MAX(te.test_date))           AS days_since_last_test
FROM airplanes a
JOIN plane_models pm ON a.model_no = pm.model_no
LEFT JOIN test_events te ON a.plane_no = te.plane_no
GROUP BY a.plane_no, pm.model_name, a.airline, a.status
ORDER BY days_since_last_test DESC NULLS FIRST;

-- ────────────────────────────────────────────────────────────
-- Q7: Traffic controllers whose annual medical exam is overdue
--     (older than 12 months)
-- ────────────────────────────────────────────────────────────
SELECT
    e.first_name || ' ' || e.last_name         AS controller,
    tc.certification_no,
    tc.last_medical_exam,
    NOW()::DATE - tc.last_medical_exam         AS days_since_exam,
    tc.clearance_level,
    CASE
        WHEN NOW()::DATE - tc.last_medical_exam > 365 THEN 'OVERDUE'
        WHEN NOW()::DATE - tc.last_medical_exam > 300 THEN 'DUE SOON'
        ELSE 'OK'
    END AS medical_status
FROM traffic_controllers tc
JOIN employees e USING (ssn)
ORDER BY days_since_exam DESC;

-- ────────────────────────────────────────────────────────────
-- Q8: Flight punctuality report — avg delay per airline
-- ────────────────────────────────────────────────────────────
SELECT
    a.airline,
    COUNT(f.flight_id)                          AS total_flights,
    COUNT(f.actual_depart)                      AS flights_departed,
    ROUND(AVG(
        EXTRACT(EPOCH FROM (f.actual_depart - f.scheduled_depart)) / 60
    ), 1)                                       AS avg_departure_delay_min,
    SUM(CASE WHEN f.status = 'cancelled' THEN 1 ELSE 0 END) AS cancellations,
    SUM(CASE WHEN f.actual_depart <= f.scheduled_depart THEN 1 ELSE 0 END) AS on_time
FROM flights f
JOIN airplanes a ON f.plane_no = a.plane_no
WHERE f.status NOT IN ('scheduled','boarding')
GROUP BY a.airline
ORDER BY avg_departure_delay_min DESC NULLS LAST;

-- ────────────────────────────────────────────────────────────
-- Q9: Maintenance cost analysis per airplane
-- ────────────────────────────────────────────────────────────
SELECT
    a.plane_no,
    pm.model_name,
    a.airline,
    a.total_flight_hours,
    COUNT(r.repair_id)                          AS total_repairs,
    COALESCE(SUM(r.cost), 0)                   AS total_repair_cost,
    COALESCE(
        ROUND(SUM(r.cost) / NULLIF(a.total_flight_hours, 0), 2), 0
    )                                           AS cost_per_flight_hour,
    COUNT(CASE WHEN r.status != 'completed' THEN 1 END) AS open_repairs
FROM airplanes a
JOIN plane_models pm ON a.model_no = pm.model_no
LEFT JOIN repair_orders r ON a.plane_no = r.plane_no
GROUP BY a.plane_no, pm.model_name, a.airline, a.total_flight_hours
ORDER BY total_repair_cost DESC;

-- ────────────────────────────────────────────────────────────
-- Q10: Hangar utilization — current occupancy vs capacity
-- ────────────────────────────────────────────────────────────
SELECT
    h.hangar_no,
    h.location,
    h.hangar_type,
    h.capacity                                  AS max_capacity,
    COUNT(ha.assignment_id)                     AS current_occupancy,
    ROUND(COUNT(ha.assignment_id) * 100.0 / h.capacity, 1) AS utilization_pct,
    h.capacity - COUNT(ha.assignment_id)        AS available_slots
FROM hangars h
LEFT JOIN hangar_assignments ha
    ON h.hangar_no = ha.hangar_no AND ha.time_out IS NULL
GROUP BY h.hangar_no, h.location, h.hangar_type, h.capacity
ORDER BY utilization_pct DESC;

-- ────────────────────────────────────────────────────────────
-- Q11: Planes that failed any test in the last 6 months —
--      safety watchlist
-- ────────────────────────────────────────────────────────────
SELECT DISTINCT
    a.plane_no,
    pm.model_name,
    a.airline,
    a.status,
    t.test_name,
    te.score,
    te.test_date,
    e.first_name || ' ' || e.last_name          AS tested_by,
    te.remarks
FROM test_events te
JOIN tests t          USING (test_id)
JOIN airplanes a      ON te.plane_no = a.plane_no
JOIN plane_models pm  ON a.model_no = pm.model_no
JOIN technicians tech ON te.technician_ssn = tech.ssn
JOIN employees e      ON tech.ssn = e.ssn
WHERE te.result = 'fail'
  AND te.test_date >= CURRENT_DATE - INTERVAL '6 months'
ORDER BY te.test_date DESC;

-- ────────────────────────────────────────────────────────────
-- Q12: Workload distribution — tests + repairs per technician
--      this year
-- ────────────────────────────────────────────────────────────
SELECT
    e.first_name || ' ' || e.last_name          AS technician,
    t.specialization,
    COUNT(DISTINCT te.event_id)                 AS tests_this_year,
    ROUND(SUM(te.hours_spent), 1)              AS test_hours,
    COUNT(DISTINCT r.repair_id)                 AS repairs_assigned,
    ROUND(SUM(te.hours_spent) + 
          COALESCE(
              (SELECT SUM(EXTRACT(EPOCH FROM (COALESCE(r2.closed_at,NOW()) - r2.opened_at))/3600)
               FROM repair_orders r2 WHERE r2.assigned_tech = t.ssn
               AND EXTRACT(YEAR FROM r2.opened_at) = EXTRACT(YEAR FROM NOW())), 0
          ), 1)                                  AS total_est_hours
FROM technicians t
JOIN employees e    ON t.ssn = e.ssn
LEFT JOIN test_events te
    ON te.technician_ssn = t.ssn
    AND EXTRACT(YEAR FROM te.test_date) = EXTRACT(YEAR FROM NOW())
LEFT JOIN repair_orders r
    ON r.assigned_tech = t.ssn
    AND EXTRACT(YEAR FROM r.opened_at) = EXTRACT(YEAR FROM NOW())
GROUP BY e.first_name, e.last_name, t.specialization, t.ssn
ORDER BY test_hours DESC;

-- ────────────────────────────────────────────────────────────
-- Q13: Monthly flight volume by destination (last 12 months)
-- ────────────────────────────────────────────────────────────
SELECT
    TO_CHAR(f.scheduled_depart, 'YYYY-MM')       AS month,
    f.destination,
    COUNT(*)                                      AS flights,
    SUM(f.passenger_count)                        AS total_passengers,
    SUM(CASE WHEN f.status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled
FROM flights f
WHERE f.scheduled_depart >= NOW() - INTERVAL '12 months'
GROUP BY TO_CHAR(f.scheduled_depart, 'YYYY-MM'), f.destination
ORDER BY month DESC, flights DESC;

-- ────────────────────────────────────────────────────────────
-- Q14: Aircraft aging report — planes over 15 years old
--      with their last test and repair history
-- ────────────────────────────────────────────────────────────
SELECT
    a.plane_no,
    a.registration_no,
    pm.manufacturer || ' ' || pm.model_name     AS model,
    a.airline,
    a.manufacture_date,
    DATE_PART('year', AGE(a.manufacture_date))  AS age_years,
    a.total_flight_hours,
    a.status,
    MAX(te.test_date)                            AS last_test_date,
    ROUND(AVG(te.score),2)                       AS avg_test_score,
    COUNT(DISTINCT r.repair_id)                  AS lifetime_repairs,
    COALESCE(SUM(r.cost),0)                      AS lifetime_repair_cost
FROM airplanes a
JOIN plane_models pm ON a.model_no = pm.model_no
LEFT JOIN test_events te ON a.plane_no = te.plane_no
LEFT JOIN repair_orders r ON a.plane_no = r.plane_no
WHERE a.manufacture_date < NOW() - INTERVAL '15 years'
GROUP BY a.plane_no, a.registration_no, pm.manufacturer, pm.model_name,
         a.airline, a.manufacture_date, a.total_flight_hours, a.status
ORDER BY age_years DESC;

-- ────────────────────────────────────────────────────────────
-- Q15: Employee union membership overview with salary bands
--      per union and employee type
-- ────────────────────────────────────────────────────────────
SELECT
    u.union_name,
    e.emp_type,
    COUNT(e.ssn)                                 AS member_count,
    TO_CHAR(MIN(e.salary), 'FM$999,999')         AS min_salary,
    TO_CHAR(ROUND(AVG(e.salary),2), 'FM$999,999') AS avg_salary,
    TO_CHAR(MAX(e.salary), 'FM$999,999')         AS max_salary,
    TO_CHAR(SUM(e.salary), 'FM$9,999,999')       AS total_payroll,
    u.contract_end,
    CASE
        WHEN u.contract_end < NOW()::DATE THEN 'EXPIRED'
        WHEN u.contract_end < NOW()::DATE + 90 THEN 'EXPIRING SOON'
        ELSE 'ACTIVE'
    END AS contract_status
FROM employees e
JOIN unions u USING (union_id)
WHERE e.is_active = TRUE
GROUP BY u.union_name, e.emp_type, u.contract_end
ORDER BY u.union_name, member_count DESC;
