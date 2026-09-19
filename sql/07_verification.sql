USE berealty_db;

SHOW TABLES;
SHOW CREATE TABLE Property_Transaction;
SHOW CREATE TABLE Viewing;
SHOW CREATE TABLE Listing;
SHOW TRIGGERS;

SELECT 'Agent' AS table_name, COUNT(*) AS row_count FROM Agent
UNION ALL SELECT 'Client', COUNT(*) FROM Client
UNION ALL SELECT 'Client_Role', COUNT(*) FROM Client_Role
UNION ALL SELECT 'Property_Type', COUNT(*) FROM Property_Type
UNION ALL SELECT 'Property', COUNT(*) FROM Property
UNION ALL SELECT 'Listing', COUNT(*) FROM Listing
UNION ALL SELECT 'Viewing', COUNT(*) FROM Viewing
UNION ALL SELECT 'Property_Transaction', COUNT(*) FROM Property_Transaction
UNION ALL SELECT 'Payment', COUNT(*) FROM Payment;

-- Verify viewing/listing consistency and the one-open-listing rule.
SELECT v.viewing_id, v.listing_id, l.property_id, v.client_id, v.agent_id
FROM Viewing v JOIN Listing l ON l.listing_id = v.listing_id
ORDER BY v.viewing_id;

SELECT property_id, COUNT(*) AS open_listing_count
FROM Listing
WHERE status IN ('Active','Under Offer')
GROUP BY property_id
HAVING COUNT(*) > 1;
