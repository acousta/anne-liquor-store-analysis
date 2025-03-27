create or replace view ANNE_LIQUOR_STORE.PUBLIC.BRAND_PROFIT_ANALYSIS(
	BRAND,
	BRAND_TOTAL_REVENUE,
	BRAND_TOTAL_COST,
	BRAND_TOTAL_PROFIT,
	BRAND_PROFIT_MARGIN
) as
select 
    brand,
    sum(total_sales_revenue) as brand_total_revenue,
    sum(total_quantity_sold * cost_per_unit) as brand_total_cost,
    sum(total_profit) as brand_total_profit,
    (sum(total_sales_revenue) - sum(total_quantity_sold * cost_per_unit)) / sum(total_sales_revenue) * 100 as brand_profit_margin
from anne_liquor_store.public.profit_analysis
group by brand;
