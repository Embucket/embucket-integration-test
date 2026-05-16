-- SQLBench-H query 18 derived from TPC-H query 18 under the terms of the TPC Fair Use Policy.
-- TPC-H queries are Copyright 1993-2022 Transaction Processing Performance Council.
WITH t AS (SELECT l_orderkey, SUM(l_quantity) AS sum_qty
 FROM iceberg.tpch.lineitem
 GROUP BY l_orderkey
 HAVING SUM(l_quantity) > 300)
SELECT
 c_name,
 c_custkey,
 o_orderkey,
 o_orderdate,
 o_totalprice,
 t.sum_qty
FROM iceberg.tpch.customer
JOIN iceberg.tpch.orders   ON c_custkey = o_custkey
JOIN t        ON o_orderkey = t.l_orderkey
ORDER BY o_totalprice DESC, o_orderdate LIMIT 100
