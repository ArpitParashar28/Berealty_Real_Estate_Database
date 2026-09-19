USE berealty_db;

DELIMITER $$

DROP TRIGGER IF EXISTS trg_transaction_after_insert_completed$$
CREATE TRIGGER trg_transaction_after_insert_completed
AFTER INSERT ON Property_Transaction
FOR EACH ROW
BEGIN
    IF NEW.status = 'Completed' THEN
        UPDATE Property p
        JOIN Listing l ON l.property_id = p.property_id
        SET p.status = CASE
                           WHEN l.listing_type = 'Sale' THEN 'Sold'
                           ELSE 'Rented'
                       END,
            p.owner_client_id = CASE
                                    WHEN l.listing_type = 'Sale' THEN NEW.client_id
                                    ELSE p.owner_client_id
                                END
        WHERE l.listing_id = NEW.listing_id;

        UPDATE Listing
        SET status = 'Closed',
            end_date = COALESCE(end_date, NEW.transaction_date)
        WHERE listing_id = NEW.listing_id;
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_transaction_after_update_completed$$
CREATE TRIGGER trg_transaction_after_update_completed
AFTER UPDATE ON Property_Transaction
FOR EACH ROW
BEGIN
    IF NEW.status = 'Completed' AND OLD.status <> 'Completed' THEN
        UPDATE Property p
        JOIN Listing l ON l.property_id = p.property_id
        SET p.status = CASE
                           WHEN l.listing_type = 'Sale' THEN 'Sold'
                           ELSE 'Rented'
                       END,
            p.owner_client_id = CASE
                                    WHEN l.listing_type = 'Sale' THEN NEW.client_id
                                    ELSE p.owner_client_id
                                END
        WHERE l.listing_id = NEW.listing_id;

        UPDATE Listing
        SET status = 'Closed',
            end_date = COALESCE(end_date, NEW.transaction_date)
        WHERE listing_id = NEW.listing_id;
    END IF;
END$$

DELIMITER ;
