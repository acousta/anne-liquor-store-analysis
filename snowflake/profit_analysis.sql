create or replace view ANNE_LIQUOR_STORE.PUBLIC.PROFIT_ANALYSIS(
	BRAND,
	PRODUCT,
	SIZE,
	TOTAL_QUANTITY_SOLD,
	TOTAL_SALES_REVENUE,
	COST_PER_UNIT,
	AVG_SELLING_PRICE,
	TOTAL_PROFIT,
	PROFIT_MARGIN_PERCENTAGE
) as
with product_costs as (
    select 
        coalesce(p.brand, pp.brand) as brand,
        coalesce(p.description, pp.description) as description,
        coalesce(p.size, pp.size) as size,
        avg(p.purchaseprice) as avg_purchase_price,
        avg(pp.purchaseprice) as avg_price_from_prices
    from purchases p
    full outer join purchase_prices pp 
        on p.brand = pp.brand 
        and p.description = pp.description 
        and p.size = pp.size
    group by 
        coalesce(p.brand, pp.brand),
        coalesce(p.description, pp.description),
        coalesce(p.size, pp.size)
),
sales_data as (
    select 
        brand,
        description,
        size,
        sum(salesquantity) as total_quantity_sold,
        sum(salesdollars) as total_sales_revenue,
        avg(salesprice) as avg_selling_price
    from sales
    group by brand, description, size
)
select 
    s.brand,
    s.description as product,
    s.size,
    s.total_quantity_sold,
    s.total_sales_revenue,
    case
        when pc.avg_purchase_price is not null then pc.avg_purchase_price
        else pc.avg_price_from_prices
    end as cost_per_unit,
    s.avg_selling_price,
    (s.total_sales_revenue - (s.total_quantity_sold * cost_per_unit)) as total_profit,
    ((s.avg_selling_price - cost_per_unit) / s.avg_selling_price) * 100 as profit_margin_percentage
from sales_data s
left join product_costs pc on s.brand = pc.brand and s.description = pc.description and s.size = pc.size;
