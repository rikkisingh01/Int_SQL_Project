WITH customer_ltv AS (

SELECT ca.customerkey
,ca.cleaned_name
,SUM(ca.total_net_revenue) AS total_ltv

FROM cohort_analysis AS ca 

WHERE 1=1

GROUP BY ca.customerkey, ca.cleaned_name
),

customer_segments AS (

SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY cl.total_ltv) AS ltv_25th_percentile
,PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY cl.total_ltv) AS ltv_75th_percentile

FROM customer_ltv AS cl
),

segment_values AS (

SELECT cl.*
,CASE
	WHEN cl.total_ltv < cs.ltv_25th_percentile  THEN '1 - Low-Value'
	WHEN cl.total_ltv <= cs.ltv_75th_percentile  THEN '2 - Mid-Value'
	ELSE '3 - High-Value'
END AS customer_segment

FROM customer_ltv AS cl

CROSS JOIN customer_segments AS cs

)

SELECT sv.customer_segment 
,SUM(sv.total_ltv) AS total_ltv
,COUNT(sv.customerkey) AS customer_count
,SUM(sv.total_ltv) / COUNT(sv.customerkey) AS avg_ltv

FROM segment_values AS sv

WHERE 1=1

GROUP BY sv.customer_segment

ORDER BY sv.customer_segment DESC