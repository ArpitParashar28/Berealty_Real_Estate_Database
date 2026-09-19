-- Berealty Real Estate Property Management Database
-- MySQL 8.4 compatible schema
-- Integrity revision: Property_Transaction does NOT duplicate property_id.
-- The property is derived from Listing.property_id, preventing listing/property mismatches.

DROP DATABASE IF EXISTS berealty_db;
CREATE DATABASE berealty_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
USE berealty_db;

CREATE TABLE Client (
    client_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    phone VARCHAR(30),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE Client_Role (
    client_id INT NOT NULL,
    role_name ENUM('Buyer','Seller','Landlord','Tenant') NOT NULL,
    PRIMARY KEY (client_id, role_name),
    CONSTRAINT fk_client_role_client
        FOREIGN KEY (client_id) REFERENCES Client(client_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Agent (
    agent_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    phone VARCHAR(30),
    hire_date DATE NOT NULL,
    commission_rate DECIMAL(5,2) NOT NULL DEFAULT 2.50,
    CONSTRAINT chk_agent_commission
        CHECK (commission_rate >= 0 AND commission_rate <= 100)
) ENGINE=InnoDB;

CREATE TABLE Property_Type (
    property_type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    category ENUM('Residential','Commercial') NOT NULL
) ENGINE=InnoDB;

CREATE TABLE Property (
    property_id INT AUTO_INCREMENT PRIMARY KEY,
    property_type_id INT NOT NULL,
    owner_client_id INT NOT NULL,
    managing_agent_id INT NOT NULL,
    address_line VARCHAR(160) NOT NULL,
    district VARCHAR(80) NOT NULL,
    postal_code VARCHAR(10) NOT NULL,
    city VARCHAR(80) NOT NULL DEFAULT 'Berlin',
    bedrooms INT NOT NULL DEFAULT 0,
    bathrooms INT NOT NULL DEFAULT 0,
    floor_area_sqm DECIMAL(8,2) NOT NULL,
    status ENUM('Available','Reserved','Sold','Rented','Inactive') NOT NULL DEFAULT 'Available',
    CONSTRAINT chk_property_bedrooms CHECK (bedrooms >= 0),
    CONSTRAINT chk_property_bathrooms CHECK (bathrooms >= 0),
    CONSTRAINT chk_property_area CHECK (floor_area_sqm > 0),
    CONSTRAINT fk_property_type
        FOREIGN KEY (property_type_id) REFERENCES Property_Type(property_type_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_property_owner
        FOREIGN KEY (owner_client_id) REFERENCES Client(client_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_property_agent
        FOREIGN KEY (managing_agent_id) REFERENCES Agent(agent_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE Listing (
    listing_id INT AUTO_INCREMENT PRIMARY KEY,
    property_id INT NOT NULL,
    listing_type ENUM('Sale','Rent') NOT NULL,
    list_price DECIMAL(12,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NULL,
    status ENUM('Active','Under Offer','Closed','Withdrawn') NOT NULL DEFAULT 'Active',
    open_property_id INT GENERATED ALWAYS AS (
        CASE WHEN status IN ('Active','Under Offer') THEN property_id ELSE NULL END
    ) STORED,
    CONSTRAINT chk_listing_price CHECK (list_price > 0),
    CONSTRAINT uq_listing_one_open_per_property UNIQUE (open_property_id),
    CONSTRAINT chk_listing_dates CHECK (end_date IS NULL OR end_date >= start_date),
    CONSTRAINT fk_listing_property
        FOREIGN KEY (property_id) REFERENCES Property(property_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE Viewing (
    viewing_id INT AUTO_INCREMENT PRIMARY KEY,
    listing_id INT NOT NULL,
    client_id INT NOT NULL,
    agent_id INT NOT NULL,
    viewing_datetime DATETIME NOT NULL,
    outcome ENUM('Scheduled','Attended','Interested','Not Interested','Cancelled') NOT NULL DEFAULT 'Scheduled',
    notes VARCHAR(255),
    CONSTRAINT fk_viewing_listing
        FOREIGN KEY (listing_id) REFERENCES Listing(listing_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_viewing_client
        FOREIGN KEY (client_id) REFERENCES Client(client_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_viewing_agent
        FOREIGN KEY (agent_id) REFERENCES Agent(agent_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE Property_Transaction (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    listing_id INT NOT NULL,
    client_id INT NOT NULL,
    agent_id INT NOT NULL,
    transaction_date DATE NOT NULL,
    agreed_amount DECIMAL(12,2) NOT NULL,
    status ENUM('Pending','Completed','Cancelled') NOT NULL DEFAULT 'Pending',
    CONSTRAINT uq_transaction_listing UNIQUE (listing_id),
    CONSTRAINT chk_transaction_amount CHECK (agreed_amount > 0),
    CONSTRAINT fk_transaction_listing
        FOREIGN KEY (listing_id) REFERENCES Listing(listing_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_transaction_client
        FOREIGN KEY (client_id) REFERENCES Client(client_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_transaction_agent
        FOREIGN KEY (agent_id) REFERENCES Agent(agent_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE Payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    payment_method ENUM('Bank Transfer','Card','Direct Debit','Cash') NOT NULL,
    status ENUM('Pending','Paid','Refunded') NOT NULL DEFAULT 'Paid',
    CONSTRAINT chk_payment_amount CHECK (amount > 0),
    CONSTRAINT fk_payment_transaction
        FOREIGN KEY (transaction_id) REFERENCES Property_Transaction(transaction_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Indexes chosen for common filtering, joining and time-based reports.
CREATE INDEX idx_property_district_status
    ON Property(district, status);
CREATE INDEX idx_property_agent
    ON Property(managing_agent_id);
CREATE INDEX idx_listing_status_date
    ON Listing(status, start_date);
CREATE INDEX idx_listing_property_type
    ON Listing(property_id, listing_type);
CREATE INDEX idx_transaction_status_date
    ON Property_Transaction(status, transaction_date);
CREATE INDEX idx_transaction_agent_status
    ON Property_Transaction(agent_id, status);
CREATE INDEX idx_transaction_client
    ON Property_Transaction(client_id);
CREATE INDEX idx_viewing_listing_date
    ON Viewing(listing_id, viewing_datetime);
CREATE INDEX idx_payment_transaction
    ON Payment(transaction_id);
