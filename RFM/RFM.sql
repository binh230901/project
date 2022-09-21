-- tính recency, frequency, monetary
WITH RFM_metrics AS (
SELECT 
	DISTINCT(CustomerID),
	timestampdiff(DAY,max(Purchase_Date),  CURDATE()) AS recency,
	COUNT(Purchase_Date) AS frequency,
	SUM(GMV) AS monetary 	
FROM Customer_Transaction ct 
GROUP BY CustomerID
HAVING CustomerID <> 0
)
-- tính percent rank của frequency và monetary
,RFM_percent AS (SELECT 
	*,
	PERCENT_RANK() over(ORDER BY frequency ASC ) AS frequency_percent_rank,
	PERCENT_RANK() over(ORDER BY monetary ASC ) AS monetary_percent_rank
FROM RFM_metrics
)
-- chia rank theo định lý pareto 80/20
, RFM_rank AS (SELECT *,
	CASE 
		WHEN recency BETWEEN 0 AND  40 THEN 3
		WHEN recency BETWEEN 40 AND 80 THEN 2
		WHEN  recency > 80 THEN 1
		ELSE 0 
	END AS recency_rank,
	CASE 
		WHEN frequency_percent_rank < 0.5 THEN 1
		WHEN frequency_percent_rank BETWEEN 0.5 AND 0.8 THEN 2
		WHEN frequency_percent_rank BETWEEN 0.8 AND 1 THEN 3
		ELSE 0 
	END AS frequency_rank,
	CASE 
		WHEN monetary_percent_rank < 0.5 THEN 1
		WHEN monetary_percent_rank BETWEEN 0.5 AND 0.8 THEN 2
		WHEN monetary_percent_rank BETWEEN 0.8 AND 1 THEN 3
		ELSE 0 
	END AS monetary_rank 	
FROM RFM_percent)
, phan_loai_RFM AS (SELECT *,
	CONCAT(recency_rank, frequency_rank, monetary_rank) AS phan_loai
FROM RFM_rank )
-- phân loại khách hàng
SELECT CustomerID ,
	phan_loai,
	CASE 
		WHEN phan_loai IN ('333') THEN 'KH Vip'
		WHEN phan_loai IN ('113', '123', '213', '223') THEN 'KH chi tieu nhieu'
		WHEN phan_loai IN ('131', '132', '231', '232') THEN 'KH thuong xuyen' 
		WHEN phan_loai IN ('311', '312', '321', '322') THEN 'KH mua gan day'
		WHEN phan_loai IN ('133') THEN 'KH vip sap mat'
		WHEN phan_loai IN ('111') THEN 'KH da mat'
		ELSE 'KH binh thuong'
	END AS nhom_khach_hang
FROM phan_loai_RFM
;

-- create view 
CREATE VIEW RFM AS (
WITH RFM_metrics AS (
SELECT 
	DISTINCT(CustomerID),
	timestampdiff(DAY,max(Purchase_Date),  CURDATE()) AS recency,
	COUNT(Purchase_Date) AS frequency,
	SUM(GMV) AS monetary 	
FROM Customer_Transaction ct 
GROUP BY CustomerID
HAVING CustomerID <> 0
)
,RFM_percent AS (SELECT 
	*,
	PERCENT_RANK() over(ORDER BY frequency ASC ) AS frequency_percent_rank,
	PERCENT_RANK() over(ORDER BY monetary ASC ) AS monetary_percent_rank
FROM RFM_metrics
)
, RFM_rank AS (SELECT *,
	CASE 
		WHEN recency BETWEEN 0 AND  40 THEN 3
		WHEN recency BETWEEN 40 AND 80 THEN 2
		WHEN  recency > 80 THEN 1
		ELSE 0 
	END AS recency_rank,
	CASE 
		WHEN frequency_percent_rank < 0.5 THEN 1
		WHEN frequency_percent_rank BETWEEN 0.5 AND 0.8 THEN 2
		WHEN frequency_percent_rank BETWEEN 0.8 AND 1 THEN 3
		ELSE 0 
	END AS frequency_rank,
	CASE 
		WHEN monetary_percent_rank < 0.5 THEN 1
		WHEN monetary_percent_rank BETWEEN 0.5 AND 0.8 THEN 2
		WHEN monetary_percent_rank BETWEEN 0.8 AND 1 THEN 3
		ELSE 0 
	END AS monetary_rank 	
FROM RFM_percent)
, phan_loai_RFM AS (SELECT *,
	CONCAT(recency_rank, frequency_rank, monetary_rank) AS phan_loai
FROM RFM_rank )
SELECT CustomerID ,
	phan_loai,
	CASE 
		WHEN phan_loai IN ('333') THEN 'KH Vip'
		WHEN phan_loai IN ('113', '123', '213', '223') THEN 'KH chi tieu nhieu'
		WHEN phan_loai IN ('131', '132', '231', '232') THEN 'KH thuong xuyen' 
		WHEN phan_loai IN ('311', '312', '321', '322') THEN 'KH mua gan day'
		WHEN phan_loai IN ('133') THEN 'KH vip sap mat'
		WHEN phan_loai IN ('111') THEN 'KH da mat'
		ELSE 'KH binh thuong'
	END AS nhom_khach_hang
FROM phan_loai_RFM
);
-- create proceduce
DROP PROCEDURE IF EXISTS RFM.RFM;

DELIMITER $$
$$
CREATE PROCEDURE RFM.RFM()
BEGIN
	WITH RFM_metrics AS (
SELECT 
	DISTINCT(CustomerID),
	timestampdiff(DAY,max(Purchase_Date),  CURDATE()) AS recency,
	COUNT(Purchase_Date) AS frequency,
	SUM(GMV) AS monetary 	
FROM Customer_Transaction ct 
GROUP BY CustomerID
HAVING CustomerID <> 0
)
-- tính percent rank của frequency và monetary
,RFM_percent AS (SELECT 
	*,
	PERCENT_RANK() over(ORDER BY frequency ASC ) AS frequency_percent_rank,
	PERCENT_RANK() over(ORDER BY monetary ASC ) AS monetary_percent_rank
FROM RFM_metrics
)
-- chia rank theo định lý pareto 80/20
, RFM_rank AS (SELECT *,
	CASE 
		WHEN recency BETWEEN 0 AND  40 THEN 3
		WHEN recency BETWEEN 40 AND 80 THEN 2
		WHEN  recency > 80 THEN 1
		ELSE 0 
	END AS recency_rank,
	CASE 
		WHEN frequency_percent_rank < 0.5 THEN 1
		WHEN frequency_percent_rank BETWEEN 0.5 AND 0.8 THEN 2
		WHEN frequency_percent_rank BETWEEN 0.8 AND 1 THEN 3
		ELSE 0 
	END AS frequency_rank,
	CASE 
		WHEN monetary_percent_rank < 0.5 THEN 1
		WHEN monetary_percent_rank BETWEEN 0.5 AND 0.8 THEN 2
		WHEN monetary_percent_rank BETWEEN 0.8 AND 1 THEN 3
		ELSE 0 
	END AS monetary_rank 	
FROM RFM_percent)
, phan_loai_RFM AS (SELECT *,
	CONCAT(recency_rank, frequency_rank, monetary_rank) AS phan_loai
FROM RFM_rank )
-- phân loại khách hàng
SELECT CustomerID ,
	phan_loai,
	CASE 
		WHEN phan_loai IN ('333') THEN 'KH Vip'
		WHEN phan_loai IN ('113', '123', '213', '223') THEN 'KH chi tieu nhieu'
		WHEN phan_loai IN ('131', '132', '231', '232') THEN 'KH thuong xuyen' 
		WHEN phan_loai IN ('311', '312', '321', '322') THEN 'KH mua gan day'
		WHEN phan_loai IN ('133') THEN 'KH vip sap mat'
		WHEN phan_loai IN ('111') THEN 'KH da mat'
		ELSE 'KH binh thuong'
	END AS nhom_khach_hang
FROM phan_loai_RFM
;
END$$
DELIMITER ;
-- call proceduce
CALL RFM()

-- create event tự động chạy mỗi tháng 1 lần
SET GLOBAL event_scheduler = On;
CREATE EVENT RFM 
ON SCHEDULE
	EVERY 1 MONTH 
	STARTs NOW()  
DO
	CALL RFM();

