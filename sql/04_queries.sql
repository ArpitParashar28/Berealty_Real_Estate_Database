USE berealty_db;

-- Q1. Property catalogue with type, owner, managing agent and current listing.
SELECT p.property_id,
       CONCAT(p.address_line, ', ', p.district) AS property_address,
       pt.type_name AS property_type,
       p.status AS property_status,
       CONCAT(c.first_name, ' ', c.last_name) AS owner_name,
       CONCAT(a.first_name, ' ', a.last_name) AS managing_agent,
       l.listing_type,
       l.list_price,
       l.status AS listing_status
FROM Property p
JOIN Property_Type pt ON pt.property_type_id = p.property_type_id
JOIN Client c ON c.client_id = p.owner_client_id
JOIN Agent a ON a.agent_id = p.managing_agent_id
LEFT JOIN Listing l
       ON l.property_id = p.property_id
      AND l.status IN ('Active','Under Offer')
ORDER BY p.property_id;

-- Q2. Active/under-offer listing workload by agent and commercial type.
SELECT a.agent_id,
       CONCAT(a.first_name, ' ', a.last_name) AS agent_name,
       l.listing_type,
       COUNT(l.listing_id) AS open_listings,
       ROUND(AVG(l.list_price),2) AS average_list_price
FROM Agent a
LEFT JOIN Property p ON p.managing_agent_id = a.agent_id
LEFT JOIN Listing l ON l.property_id = p.property_id
                   AND l.status IN ('Active','Under Offer')
GROUP BY a.agent_id, a.first_name, a.last_name, l.listing_type
ORDER BY a.agent_id, l.listing_type;

-- Q3. Completed transactions handled by agents.
SELECT t.transaction_id,
       CONCAT(a.first_name, ' ', a.last_name) AS agent_name,
       l.listing_type,
       p.address_line,
       p.district,
       t.transaction_date,
       t.agreed_amount
FROM Property_Transaction t
JOIN Agent a ON a.agent_id = t.agent_id
JOIN Listing l ON l.listing_id = t.listing_id
JOIN Property p ON p.property_id = l.property_id
WHERE t.status = 'Completed'
ORDER BY t.transaction_date;

-- Q4. Client transaction history.
SELECT c.client_id,
       CONCAT(c.first_name, ' ', c.last_name) AS client_name,
       t.transaction_id,
       l.listing_type,
       p.address_line,
       t.transaction_date,
       t.agreed_amount,
       t.status
FROM Client c
JOIN Property_Transaction t ON t.client_id = c.client_id
JOIN Listing l ON l.listing_id = t.listing_id
JOIN Property p ON p.property_id = l.property_id
ORDER BY c.client_id, t.transaction_date;

-- Q5. RIGHT JOIN: retain every agent even when the agent has no transaction.
SELECT a.agent_id,
       CONCAT(a.first_name, ' ', a.last_name) AS agent_name,
       COUNT(t.transaction_id) AS all_transactions,
       SUM(t.status = 'Completed') AS completed_transactions,
       COALESCE(SUM(CASE WHEN t.status = 'Completed' THEN t.agreed_amount ELSE 0 END),0) AS completed_value
FROM Property_Transaction t
RIGHT JOIN Agent a ON a.agent_id = t.agent_id
GROUP BY a.agent_id, a.first_name, a.last_name
ORDER BY a.agent_id;

-- Q6. CROSS JOIN capacity matrix: every agent x property type combination.
SELECT a.agent_id,
       CONCAT(a.first_name, ' ', a.last_name) AS agent_name,
       pt.type_name AS property_type,
       COUNT(p.property_id) AS managed_properties
FROM Agent a
CROSS JOIN Property_Type pt
LEFT JOIN Property p
       ON p.managing_agent_id = a.agent_id
      AND p.property_type_id = pt.property_type_id
GROUP BY a.agent_id, a.first_name, a.last_name, pt.property_type_id, pt.type_name
ORDER BY a.agent_id, pt.property_type_id;

-- Q7. Correlated subquery: open listings priced above their district/type average.
SELECT l.listing_id,
       p.district,
       l.listing_type,
       l.list_price
FROM Listing l
JOIN Property p ON p.property_id = l.property_id
WHERE l.status IN ('Active','Under Offer')
  AND l.list_price > (
      SELECT AVG(l2.list_price)
      FROM Listing l2
      JOIN Property p2 ON p2.property_id = l2.property_id
      WHERE p2.district = p.district
        AND l2.listing_type = l.listing_type
        AND l2.status IN ('Active','Under Offer')
  )
ORDER BY p.district, l.listing_type, l.list_price DESC;

-- Q8. Clients with an above-average number of completed transactions.
SELECT c.client_id,
       CONCAT(c.first_name, ' ', c.last_name) AS client_name,
       COUNT(*) AS completed_transactions
FROM Client c
JOIN Property_Transaction t ON t.client_id = c.client_id
WHERE t.status = 'Completed'
GROUP BY c.client_id, c.first_name, c.last_name
HAVING COUNT(*) > (
    SELECT AVG(client_completed_count)
    FROM (
        SELECT COUNT(*) AS client_completed_count
        FROM Property_Transaction
        WHERE status = 'Completed'
        GROUP BY client_id
    ) x
)
ORDER BY completed_transactions DESC, c.client_id;

-- Q9. Monthly completed transaction report.
SELECT DATE_FORMAT(t.transaction_date, '%Y-%m') AS report_month,
       l.listing_type,
       COUNT(*) AS completed_count,
       ROUND(SUM(t.agreed_amount),2) AS total_amount,
       ROUND(AVG(t.agreed_amount),2) AS average_amount
FROM Property_Transaction t
JOIN Listing l ON l.listing_id = t.listing_id
WHERE t.status = 'Completed'
GROUP BY DATE_FORMAT(t.transaction_date, '%Y-%m'), l.listing_type
ORDER BY report_month, l.listing_type;

-- Q10. Quarterly completed transaction report.
SELECT YEAR(t.transaction_date) AS report_year,
       QUARTER(t.transaction_date) AS report_quarter,
       l.listing_type,
       COUNT(*) AS completed_count,
       ROUND(SUM(t.agreed_amount),2) AS total_amount
FROM Property_Transaction t
JOIN Listing l ON l.listing_id = t.listing_id
WHERE t.status = 'Completed'
GROUP BY YEAR(t.transaction_date), QUARTER(t.transaction_date), l.listing_type
ORDER BY report_year, report_quarter, l.listing_type;

-- Q11. Yearly report by property type and listing type.
SELECT YEAR(t.transaction_date) AS report_year,
       pt.type_name AS property_type,
       l.listing_type,
       COUNT(*) AS completed_count,
       ROUND(SUM(t.agreed_amount),2) AS total_amount
FROM Property_Transaction t
JOIN Listing l ON l.listing_id = t.listing_id
JOIN Property p ON p.property_id = l.property_id
JOIN Property_Type pt ON pt.property_type_id = p.property_type_id
WHERE t.status = 'Completed'
GROUP BY YEAR(t.transaction_date), pt.type_name, l.listing_type
ORDER BY report_year, pt.type_name, l.listing_type;

-- Q12. CTE + DENSE_RANK: 2026 completed sale performance by agent.
WITH agent_sales AS (
    SELECT a.agent_id,
           CONCAT(a.first_name, ' ', a.last_name) AS agent_name,
           COUNT(*) AS completed_sales,
           SUM(t.agreed_amount) AS total_sale_value
    FROM Agent a
    JOIN Property_Transaction t ON t.agent_id = a.agent_id
    JOIN Listing l ON l.listing_id = t.listing_id
    WHERE t.status = 'Completed'
      AND l.listing_type = 'Sale'
      AND YEAR(t.transaction_date) = 2026
    GROUP BY a.agent_id, a.first_name, a.last_name
)
SELECT agent_id,
       agent_name,
       completed_sales,
       total_sale_value,
       DENSE_RANK() OVER (ORDER BY total_sale_value DESC) AS sales_rank
FROM agent_sales
ORDER BY sales_rank, agent_id;

-- Q13. Window function: running total of completed 2026 sales.
SELECT t.transaction_date,
       t.transaction_id,
       CONCAT(a.first_name, ' ', a.last_name) AS agent_name,
       t.agreed_amount,
       SUM(t.agreed_amount) OVER (
           ORDER BY t.transaction_date, t.transaction_id
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_sale_total
FROM Property_Transaction t
JOIN Listing l ON l.listing_id = t.listing_id
JOIN Agent a ON a.agent_id = t.agent_id
WHERE t.status = 'Completed'
  AND l.listing_type = 'Sale'
  AND YEAR(t.transaction_date) = 2026
ORDER BY t.transaction_date, t.transaction_id;

-- Q14. Property-management dashboard for open listings.
SELECT l.listing_id,
       p.property_id,
       p.address_line,
       p.district,
       l.listing_type,
       l.status,
       DATEDIFF(CURDATE(), l.start_date) AS days_on_market,
       COUNT(v.viewing_id) AS viewing_count
FROM Listing l
JOIN Property p ON p.property_id = l.property_id
LEFT JOIN Viewing v ON v.listing_id = l.listing_id
WHERE l.status IN ('Active','Under Offer')
GROUP BY l.listing_id, p.property_id, p.address_line, p.district,
         l.listing_type, l.status, l.start_date
ORDER BY days_on_market DESC, l.listing_id;
