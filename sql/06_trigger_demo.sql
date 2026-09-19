USE berealty_db;

-- Demonstrates the AFTER UPDATE trigger using Transaction 6 / Listing 8 / Property 8.
-- The rollback proves that the test does not permanently alter the assessment dataset.
START TRANSACTION;

SELECT t.transaction_id,
       t.status AS transaction_status,
       p.property_id,
       p.owner_client_id,
       p.status AS property_status,
       l.listing_id,
       l.status AS listing_status,
       l.end_date
FROM Property_Transaction t
JOIN Listing l ON l.listing_id = t.listing_id
JOIN Property p ON p.property_id = l.property_id
WHERE t.transaction_id = 6;

UPDATE Property_Transaction
SET status = 'Completed'
WHERE transaction_id = 6;

SELECT t.transaction_id,
       t.status AS transaction_status,
       p.property_id,
       p.owner_client_id,
       p.status AS property_status,
       l.listing_id,
       l.status AS listing_status,
       l.end_date
FROM Property_Transaction t
JOIN Listing l ON l.listing_id = t.listing_id
JOIN Property p ON p.property_id = l.property_id
WHERE t.transaction_id = 6;

ROLLBACK;

SELECT t.transaction_id,
       t.status AS transaction_status,
       p.property_id,
       p.owner_client_id,
       p.status AS property_status,
       l.listing_id,
       l.status AS listing_status,
       l.end_date
FROM Property_Transaction t
JOIN Listing l ON l.listing_id = t.listing_id
JOIN Property p ON p.property_id = l.property_id
WHERE t.transaction_id = 6;
