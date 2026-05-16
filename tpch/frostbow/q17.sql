-- SQLBench-H query 17 derived from TPC-H query 17 under the terms of the TPC Fair Use Policy.
-- TPC-H queries are Copyright 1993-2022 Transaction Processing Performance Council.
select
	sum(l_extendedprice) / 7.0 as avg_yearly
from
	warehouse.tpch.lineitem,
	warehouse.tpch.part
where
	p_partkey = l_partkey
	and p_brand = 'Brand#42'
	and p_container = 'LG BAG'
	and l_quantity < (
		select
			0.2 * avg(l_quantity)
		from
			warehouse.tpch.lineitem
		where
			l_partkey = p_partkey
	);
