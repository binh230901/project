WITH t1 AS (
	SELECT
		Customer_ID,
		Customer_Name,
		Order_Date
	FROM
		Superstore
	WHERE
		YEAR(Order_Date) = 2017
),
t2_first_month AS (
	SELECT
		Customer_ID,
		MONTH(min(Order_Date)) AS first_month
	FROM
		t1
	GROUP BY
		1
),
t3_new_customers AS (
	SELECT
		COUNT(Customer_ID) AS new_customers,
		first_month
	FROM
		t2_first_month
	GROUP BY
		first_month
),
t4_retention_month AS (
	SELECT
		Customer_ID,
		MONTH(Order_Date) AS retention_month
	FROM
		t1
	GROUP BY
		1,
		2
),
t5_retained_customers AS (
	SELECT
		first_month,
		retention_month,
		count(t4_retention_month.Customer_ID) AS retained_customers
	FROM
		t4_retention_month
	LEFT JOIN t2_first_month ON t4_retention_month.Customer_ID = t2_first_month.Customer_ID
GROUP BY
	1,
	2
ORDER BY
	1,
	2
)
, t6_retention_rate as (SELECT
	t5_retained_customers.first_month,
	retention_month,
	concat('M', retention_month - t5_retained_customers.first_month) as retention_month_no,
	new_customers,
	retained_customers,
	ROUND((retained_customers / new_customers) * 100, 2) AS retention_rate
FROM
	t5_retained_customers
	LEFT JOIN t3_new_customers ON t5_retained_customers.first_month = t3_new_customers.first_month
)
-- pivot table 
-- cohort table
SELECT
	first_month,
	new_customers,
	sum(CASE WHEN retention_month_no = 'M0' then retention_rate else 0 end) as M0,
	sum(CASE WHEN retention_month_no = 'M1' then retention_rate else 0 end) as M1,
	sum(CASE WHEN retention_month_no = 'M2' then retention_rate else 0 end) as M2,
	sum(CASE WHEN retention_month_no = 'M3' then retention_rate else 0 end) as M3,
	sum(CASE WHEN retention_month_no = 'M4' then retention_rate else 0 end) as M4,
	sum(CASE WHEN retention_month_no = 'M5' then retention_rate else 0 end) as M5,
	sum(CASE WHEN retention_month_no = 'M6' then retention_rate else 0 end) as M6,
	sum(CASE WHEN retention_month_no = 'M7' then retention_rate else 0 end) as M7,
	sum(CASE WHEN retention_month_no = 'M8' then retention_rate else 0 end) as M8,
	sum(CASE WHEN retention_month_no = 'M9' then retention_rate else 0 end) as M9,
	sum(CASE WHEN retention_month_no = 'M10' then retention_rate else 0 end) as M10,
	sum(CASE WHEN retention_month_no = 'M11' then retention_rate else 0 end) as M11	
from t6_retention_rate	
GROUP BY 1,2