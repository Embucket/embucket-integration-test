-- SQLBench-H query 20 derived from TPC-H query 20 under the terms of the TPC Fair Use Policy.
-- TPC-H queries are Copyright 1993-2022 Transaction Processing Performance Council.
select
	s_name,
	s_address
from
	tpch.supplier,
	tpch.nation
where
	s_suppkey in (
		select
			ps_suppkey
		from
			tpch.partsupp
		where
			ps_partkey in (
				select
					p_partkey
				from
					tpch.part
				where
					p_name like 'blanched%'
			)
			and ps_availqty > (
				select
					0.5 * sum(l_quantity)
				from
					tpch.lineitem
				where
					l_partkey = ps_partkey
					and l_suppkey = ps_suppkey
					and l_shipdate >= date '1993-01-01'
					and l_shipdate < date '1993-01-01' + interval '1' year
			)
	)
	and s_nationkey = n_nationkey
	and n_name = 'KENYA'
order by
	s_name;
