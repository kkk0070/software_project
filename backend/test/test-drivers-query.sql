-- SQL Test Script: Demonstrating the "No Drivers Found" Fix
-- This script shows why INNER JOIN failed and how LEFT JOIN fixes it

-- ============================================================================
-- SCENARIO 1: Complete Driver Profile (Has entry in both tables)
-- ============================================================================

-- Sample data: Driver with complete profile
/*
users table:
id | name          | email               | role    
1  | John Doe      | john@example.com    | Driver  

drivers table:
id | user_id | vehicle_type        | vehicle_model | verification_status
1  | 1       | Electric Vehicle    | Tesla Model 3 | Pending
*/

-- OLD QUERY (INNER JOIN) - WORKS ✓
SELECT DISTINCT u.id, u.name, u.email, 
       d.vehicle_type, d.vehicle_model, d.verification_status
FROM users u
INNER JOIN drivers d ON u.id = d.user_id
WHERE u.role = 'Driver';
-- Result: Returns John Doe ✓

-- NEW QUERY (LEFT JOIN) - WORKS ✓
SELECT DISTINCT u.id, u.name, u.email, 
       d.vehicle_type, d.vehicle_model, d.verification_status
FROM users u
LEFT JOIN drivers d ON u.id = d.user_id
WHERE u.role = 'Driver';
-- Result: Returns John Doe ✓


-- ============================================================================
-- SCENARIO 2: Incomplete Driver Profile (No entry in drivers table)
-- ============================================================================

-- Sample data: Driver WITHOUT drivers table entry
/*
users table:
id | name          | email               | role    
2  | Jane Smith    | jane@example.com    | Driver  

drivers table:
(no entry for user_id = 2)
*/

-- OLD QUERY (INNER JOIN) - FAILS ✗
SELECT DISTINCT u.id, u.name, u.email, 
       d.vehicle_type, d.vehicle_model, d.verification_status
FROM users u
INNER JOIN drivers d ON u.id = d.user_id
WHERE u.role = 'Driver';
-- Result: Returns NO ROWS ✗ (Jane Smith missing!)
-- Reason: INNER JOIN requires match in BOTH tables

-- NEW QUERY (LEFT JOIN) - WORKS ✓
SELECT DISTINCT u.id, u.name, u.email, 
       d.vehicle_type, d.vehicle_model, d.verification_status
FROM users u
LEFT JOIN drivers d ON u.id = d.user_id
WHERE u.role = 'Driver';
-- Result: Returns Jane Smith with NULL values for driver fields ✓
-- id | name       | email            | vehicle_type | vehicle_model | verification_status
-- 2  | Jane Smith | jane@example.com | NULL         | NULL          | NULL


-- ============================================================================
-- COMPLETE TEST QUERY (After Fix)
-- ============================================================================

-- This is the actual query used in the application after the fix
SELECT DISTINCT u.id, u.name, u.email, u.phone, u.created_at,
       d.vehicle_type, d.vehicle_model, d.verification_status,
       COUNT(doc.id) as pending_documents
FROM users u
LEFT JOIN drivers d ON u.id = d.user_id
LEFT JOIN documents doc ON u.id = doc.user_id AND doc.status = 'Pending'
WHERE u.role = 'Driver'
GROUP BY u.id, u.name, u.email, u.phone, u.created_at, 
         d.vehicle_type, d.vehicle_model, d.verification_status
ORDER BY u.created_at DESC;

-- Expected Results:
-- - ALL users with role='Driver' are returned
-- - Drivers with complete profiles show vehicle info
-- - Drivers without drivers table entry show NULL for vehicle fields
-- - pending_documents count shows number of pending documents (0 if none)


-- ============================================================================
-- TEST DATA SETUP (For manual testing)
-- ============================================================================

-- Create test driver WITH complete profile
INSERT INTO users (name, email, password, role) 
VALUES ('Complete Driver', 'complete@test.com', '$2b$10$hashedpassword', 'Driver')
RETURNING id;
-- Assume returns id = 100

INSERT INTO drivers (user_id, vehicle_type, vehicle_model, verification_status)
VALUES (100, 'Electric Vehicle', 'Tesla Model 3', 'Pending');

-- Create test driver WITHOUT drivers table entry
INSERT INTO users (name, email, password, role) 
VALUES ('Incomplete Driver', 'incomplete@test.com', '$2b$10$hashedpassword', 'Driver')
RETURNING id;
-- Assume returns id = 101
-- (No drivers table entry created)

-- Upload test document
INSERT INTO documents (user_id, document_type, file_name, file_path, file_size, status)
VALUES (101, 'Driver License', 'license.pdf', '/uploads/license-101.pdf', 50000, 'Pending');


-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check all drivers in system
SELECT id, name, email, role FROM users WHERE role = 'Driver';
-- Expected: Shows both Complete Driver and Incomplete Driver

-- Check drivers table entries
SELECT d.*, u.name FROM drivers d 
JOIN users u ON d.user_id = u.id;
-- Expected: Shows only Complete Driver (Incomplete Driver has no entry)

-- Check what admin dashboard will see (AFTER FIX)
SELECT DISTINCT u.id, u.name, u.email, 
       d.vehicle_type, d.vehicle_model, d.verification_status,
       COUNT(doc.id) as pending_documents
FROM users u
LEFT JOIN drivers d ON u.id = d.user_id
LEFT JOIN documents doc ON u.id = doc.user_id AND doc.status = 'Pending'
WHERE u.role = 'Driver'
GROUP BY u.id, u.name, u.email, d.vehicle_type, d.vehicle_model, d.verification_status;
-- Expected: Shows BOTH drivers
-- - Complete Driver: with vehicle info and 0 pending documents
-- - Incomplete Driver: with NULL vehicle info and 1 pending document


-- ============================================================================
-- CLEANUP (Optional)
-- ============================================================================

-- Remove test data
-- DELETE FROM documents WHERE user_id IN (100, 101);
-- DELETE FROM drivers WHERE user_id = 100;
-- DELETE FROM users WHERE id IN (100, 101);
