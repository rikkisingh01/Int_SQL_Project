SELECT ca.cohort_year
,COUNT(DISTINCT ca.customerkey) AS total_customers
,SUM(ca.total_net_revenue) AS total_revenue
,SUM(ca.total_net_revenue) / COUNT(DISTINCT ca.customerkey) AS customer_revenue

FROM cohort_analysis AS ca

WHERE 1=1
AND ca.orderdate  = ca.first_purchase_date

GROUP BY ca.cohort_year