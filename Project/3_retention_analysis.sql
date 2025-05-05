WITH customer_last_purchase AS (

SELECT ca.customerkey
,ca.cleaned_name
,ca.orderdate
,ROW_NUMBER() OVER (PARTITION BY ca.customerkey ORDER BY ca.orderdate DESC) AS rn
,ca.first_purchase_date
,ca.cohort_year

FROM cohort_analysis AS ca  
),

churned_customers AS (

SELECT clp.customerkey
,clp.cleaned_name
,clp.orderdate AS last_purchase_date
,CASE
	WHEN clp.orderdate  < (SELECT MAX(s.orderdate) FROM sales AS s) - INTERVAL '6 months' THEN 'Churned'
	ELSE 'Active'
END AS customer_status
,clp.cohort_year


FROM customer_last_purchase AS clp

WHERE 1=1
AND clp.rn = 1
AND clp.first_purchase_date < (SELECT MAX(s.orderdate) FROM sales AS s) - INTERVAL '6 months'
)

SELECT cc.cohort_year 
,cc.customer_status
,COUNT(cc.customerkey) AS num_customers
,SUM(COUNT(cc.customerkey)) OVER(PARTITION BY cc.cohort_year) AS total_customers
,ROUND(COUNT(cc.customerkey) / SUM(COUNT(cc.customerkey)) OVER(PARTITION BY cc.cohort_year), 2) AS status_percentage

FROM churned_customers AS cc

WHERE 1=1

GROUP BY cc.cohort_year, cc.customer_status