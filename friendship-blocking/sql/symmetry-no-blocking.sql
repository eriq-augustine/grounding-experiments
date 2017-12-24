SELECT
   T_000.UniqueStringID_0 AS P1,
   T_000.UniqueStringID_1 AS P2
FROM
   FRIENDS_PREDICATE T_000
WHERE
   (T_000.partition_id IN (1,2))
;
