WITH sales_per_order AS (
	SELECT
		Order_ID,
		State,
		SUM(Sales) AS total_sale_order
	FROM
		Orders
	GROUP BY
		Order_ID,
		state
),
-- tính trung bình sale và STd của mỗi bang
avg_std_sales AS (
	SELECT
		state,
		AVG(total_sale_order) AS avg_sales,
		STD(total_sale_order) AS std_sales
	FROM
		sales_per_order
	GROUP BY
		state
)
-- tính upper whisker and lower whisker
,
upper_lower_whisker AS (
	SELECT
		*,
		(avg_sales + 3 * std_sales) AS upper_whisker,
		CASE WHEN avg_sales - 3 * std_sales > 0 THEN
			avg_sales - 3 * std_sales
		ELSE
			0
		END AS lower_whisker
	FROM
		avg_std_sales),
	spo_table AS (
		SELECT
			Order_ID,
			sales_per_order.state,
			total_sale_order,
			avg_sales,
			std_sales,
			upper_whisker,
			lower_whisker,
			CASE WHEN total_sale_order < lower_whisker
				OR total_sale_order > upper_whisker THEN
				'outlier'
			ELSE
				'expected sales'
			END AS spo
		FROM
			sales_per_order
		RIGHT JOIN upper_lower_whisker ON upper_lower_whisker.state = sales_per_order.state),
	tsono AS (
		SELECT
			state,
			SUM(total_sale_order) AS total_sale_order_state_no_outlier
		FROM
			spo_table
		WHERE
			spo = 'expected sales'
		GROUP BY
			state),
		tsos AS (
			SELECT
				state,
				SUM(sales) AS total_sale_order_state
			FROM
				Orders
			GROUP BY
				state
)
		SELECT
			tsos.state,
			total_sale_order_state,
			total_sale_order_state_no_outlier
		FROM
			tsos
		LEFT JOIN tsono ON tsos.state = tsono.state
		ORDER BY state