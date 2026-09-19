USE berealty_db;

-- Q15. Safe transactional DML demonstration.
-- A 2% temporary price adjustment is rolled back so the reusable sample data is unchanged.
START TRANSACTION;

SELECT listing_id, list_price AS price_before
FROM Listing
WHERE listing_id = 13;

UPDATE Listing
SET list_price = ROUND(list_price * 1.02, 2)
WHERE listing_id = 13
  AND status = 'Active';

SELECT listing_id, list_price AS price_after_temporary_update
FROM Listing
WHERE listing_id = 13;

ROLLBACK;

SELECT listing_id, list_price AS price_after_rollback
FROM Listing
WHERE listing_id = 13;
