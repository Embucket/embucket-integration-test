-- SQLBench-H query 8 derived from TPC-H query 8 under the terms of the TPC Fair Use Policy.
-- TPC-H queries are Copyright 1993-2022 Transaction Processing Performance Council.
select
	o_year,
	sum(case
		when nation = 'IRAQ' then volume
		else 0
	end) / sum(volume) as mkt_share
from
	(
		select
			extract(year from o_orderdate) as o_year,
			l_extendedprice * (1 - l_discount) as volume,
			n2.n_name as nation
		from
			embucket.tpch.part,
			embucket.tpch.supplier,
			embucket.tpch.lineitem,
			embucket.tpch.orders,
			embucket.tpch.customer,
			embucket.tpch.nation n1,
			embucket.tpch.nation n2,
			embucket.tpch.region
		where
			p_partkey = l_partkey
			and s_suppkey = l_suppkey
			and l_orderkey = o_orderkey
			and o_custkey = c_custkey
			and c_nationkey = n1.n_nationkey
			and n1.n_regionkey = r_regionkey
			and r_name = 'MIDDLE EAST'
			and s_nationkey = n2.n_nationkey
			and o_orderdate between date '1995-01-01' and date '1996-12-31'
			and p_type = 'LARGE PLATED STEEL'
	) as all_nations
group by
	o_year
order by
	o_year;
