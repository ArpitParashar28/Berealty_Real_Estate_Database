USE berealty_db;

-- Agents (5)
INSERT INTO Agent (agent_id, first_name, last_name, email, phone, hire_date, commission_rate) VALUES
(1,'Anna','Mueller','anna.mueller@berealty.example','+49 30 5550 1001','2022-03-01',2.50),
(2,'Lukas','Schmidt','lukas.schmidt@berealty.example','+49 30 5550 1002','2023-01-15',2.25),
(3,'David','Klein','david.klein@berealty.example','+49 30 5550 1003','2021-09-10',2.75),
(4,'Sofia','Becker','sofia.becker@berealty.example','+49 30 5550 1004','2024-02-12',2.50),
(5,'Mia','Wagner','mia.wagner@berealty.example','+49 30 5550 1005','2023-08-21',2.25);

-- Clients (10)
INSERT INTO Client (client_id, first_name, last_name, email, phone) VALUES
(1,'Jonas','Fischer','jonas.fischer@example.com','+49 151 5000 0001'),
(2,'Emma','Weber','emma.weber@example.com','+49 151 5000 0002'),
(3,'Noah','Hoffmann','noah.hoffmann@example.com','+49 151 5000 0003'),
(4,'Lea','Koch','lea.koch@example.com','+49 151 5000 0004'),
(5,'Paul','Richter','paul.richter@example.com','+49 151 5000 0005'),
(6,'Mila','Wolf','mila.wolf@example.com','+49 151 5000 0006'),
(7,'Leon','Braun','leon.braun@example.com','+49 151 5000 0007'),
(8,'Hannah','Krueger','hannah.krueger@example.com','+49 151 5000 0008'),
(9,'Elias','Neumann','elias.neumann@example.com','+49 151 5000 0009'),
(10,'Clara','Zimmermann','clara.zimmermann@example.com','+49 151 5000 0010');

-- Client roles (15)
INSERT INTO Client_Role (client_id, role_name) VALUES
(1,'Seller'),(1,'Landlord'),
(2,'Seller'),(2,'Landlord'),
(3,'Seller'),
(4,'Landlord'),
(5,'Seller'),
(6,'Landlord'),
(7,'Buyer'),(7,'Tenant'),
(8,'Buyer'),(8,'Tenant'),
(9,'Buyer'),(9,'Tenant'),
(10,'Buyer');

-- Property types (5)
INSERT INTO Property_Type (property_type_id, type_name, category) VALUES
(1,'Apartment','Residential'),
(2,'House','Residential'),
(3,'Office','Commercial'),
(4,'Retail','Commercial'),
(5,'Studio','Residential');

-- Properties (15) - initial owners are sellers/landlords.
INSERT INTO Property
(property_id, property_type_id, owner_client_id, managing_agent_id, address_line, district, postal_code, city, bedrooms, bathrooms, floor_area_sqm, status) VALUES
(1,1,1,1,'12 Prenzlauer Allee','Prenzlauer Berg','10405','Berlin',2,1,72.00,'Available'),
(2,1,2,2,'88 Sonnenallee','Neukoelln','12045','Berlin',1,1,48.00,'Available'),
(3,2,3,4,'24 Koenigsallee','Grunewald','14193','Berlin',4,3,210.00,'Available'),
(4,3,4,3,'16 Friedrichstrasse','Mitte','10117','Berlin',0,2,155.00,'Available'),
(5,1,5,1,'41 Boxhagener Strasse','Friedrichshain','10245','Berlin',3,2,98.00,'Available'),
(6,2,1,3,'7 Dahlemer Weg','Zehlendorf','14167','Berlin',4,2,180.00,'Available'),
(7,1,6,5,'9 Kantstrasse','Charlottenburg','10623','Berlin',2,1,68.00,'Available'),
(8,2,2,2,'33 Pankower Allee','Pankow','13187','Berlin',4,2,165.00,'Reserved'),
(9,1,3,4,'55 Karl-Marx-Allee','Friedrichshain','10243','Berlin',2,1,75.00,'Available'),
(10,5,4,5,'18 Weserstrasse','Neukoelln','12047','Berlin',1,1,39.00,'Reserved'),
(11,5,6,2,'22 Stargarder Strasse','Prenzlauer Berg','10437','Berlin',1,1,35.00,'Available'),
(12,4,4,3,'5 Tauentzienstrasse','Charlottenburg','10789','Berlin',0,1,90.00,'Available'),
(13,1,1,1,'62 Warschauer Strasse','Friedrichshain','10243','Berlin',2,1,70.00,'Available'),
(14,3,5,4,'3 Alexanderplatz','Mitte','10178','Berlin',0,2,130.00,'Available'),
(15,2,3,5,'11 Alt-Tegel','Tegel','13507','Berlin',3,2,140.00,'Available');

-- Listings (15). Completed transactions inserted later will close matching listings through triggers.
INSERT INTO Listing (listing_id, property_id, listing_type, list_price, start_date, end_date, status) VALUES
(1,1,'Sale',525000.00,'2025-11-20',NULL,'Active'),
(2,2,'Rent',2150.00,'2026-01-10',NULL,'Active'),
(3,3,'Sale',625000.00,'2026-01-18',NULL,'Active'),
(4,4,'Rent',6800.00,'2026-02-01',NULL,'Active'),
(5,5,'Sale',485000.00,'2026-03-15',NULL,'Active'),
(6,6,'Sale',560000.00,'2026-04-20',NULL,'Active'),
(7,7,'Rent',2950.00,'2026-05-01',NULL,'Active'),
(8,8,'Sale',735000.00,'2026-06-10',NULL,'Under Offer'),
(9,9,'Sale',405000.00,'2026-05-15',NULL,'Active'),
(10,10,'Rent',2250.00,'2026-07-01',NULL,'Under Offer'),
(11,11,'Rent',1800.00,'2025-10-15',NULL,'Active'),
(12,12,'Rent',4500.00,'2025-11-01',NULL,'Active'),
(13,13,'Sale',415000.00,'2026-07-20',NULL,'Active'),
(14,14,'Rent',5900.00,'2026-08-01',NULL,'Active'),
(15,15,'Sale',690000.00,'2026-08-15',NULL,'Active');

-- Viewings (13)
INSERT INTO Viewing (viewing_id, listing_id, client_id, agent_id, viewing_datetime, outcome, notes) VALUES
(1,1,7,1,'2026-01-05 10:00:00','Interested','Requested financing details'),
(2,2,8,2,'2026-01-28 17:30:00','Interested','Preferred immediate move-in'),
(3,3,8,4,'2026-02-18 14:00:00','Attended','Family viewing'),
(4,4,9,3,'2026-03-11 11:00:00','Interested','Commercial lease discussion'),
(5,5,10,1,'2026-05-08 16:00:00','Interested','Second viewing requested'),
(6,6,9,3,'2026-07-29 15:00:00','Interested','Offer prepared'),
(7,7,7,5,'2026-07-15 18:00:00','Interested','Rental application submitted'),
(8,8,7,2,'2026-08-24 12:00:00','Interested','Purchase offer under review'),
(9,9,10,4,'2026-06-18 16:30:00','Not Interested','Budget changed'),
(10,10,9,5,'2026-08-30 17:00:00','Interested','Pending references'),
(11,13,8,1,'2026-08-10 10:30:00','Attended','No offer yet'),
(12,14,7,4,'2026-08-22 13:00:00','Scheduled','Office team viewing'),
(13,15,10,5,'2026-09-02 12:30:00','Cancelled','Client rescheduled');

-- Transactions (12)
-- Completed sales in 2026 total EUR 2,125,000:
-- Anna Mueller: 510,000 + 470,000 = 980,000
-- Sofia Becker: 600,000
-- David Klein: 545,000
INSERT INTO Property_Transaction
(transaction_id, listing_id, client_id, agent_id, transaction_date, agreed_amount, status) VALUES
(1,1,7,1,'2026-01-15',510000.00,'Completed'),
(2,2,8,2,'2026-02-05',2050.00,'Completed'),
(3,3,8,4,'2026-03-20',600000.00,'Completed'),
(4,4,9,3,'2026-04-08',6500.00,'Completed'),
(5,5,10,1,'2026-06-12',470000.00,'Completed'),
(6,8,7,2,'2026-09-01',720000.00,'Pending'),
(7,7,7,5,'2026-07-28',2850.00,'Completed'),
(8,6,9,3,'2026-08-22',545000.00,'Completed'),
(9,9,10,4,'2026-07-01',390000.00,'Cancelled'),
(10,10,9,5,'2026-09-05',2200.00,'Pending'),
(11,11,8,2,'2025-11-10',1750.00,'Completed'),
(12,12,9,3,'2025-12-15',4300.00,'Completed');

-- Payments (9) - one for each completed transaction.
INSERT INTO Payment (payment_id, transaction_id, payment_date, amount, payment_method, status) VALUES
(1,1,'2026-01-15',510000.00,'Bank Transfer','Paid'),
(2,2,'2026-02-05',2050.00,'Bank Transfer','Paid'),
(3,3,'2026-03-20',600000.00,'Bank Transfer','Paid'),
(4,4,'2026-04-08',6500.00,'Bank Transfer','Paid'),
(5,5,'2026-06-12',470000.00,'Bank Transfer','Paid'),
(6,7,'2026-07-28',2850.00,'Direct Debit','Paid'),
(7,8,'2026-08-22',545000.00,'Bank Transfer','Paid'),
(8,11,'2025-11-10',1750.00,'Direct Debit','Paid'),
(9,12,'2025-12-15',4300.00,'Bank Transfer','Paid');
