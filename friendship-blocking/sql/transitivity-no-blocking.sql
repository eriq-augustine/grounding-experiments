SELECT
   T_000.UniqueStringID_0 AS P1,
   T_000.UniqueStringID_1 AS P2,
   T_001.UniqueStringID_1 AS P3
FROM
   FRIENDS_PREDICATE T_000,
   FRIENDS_PREDICATE T_001
WHERE
   (T_000.partition_id IN (1,2))
   AND (T_001.partition_id IN (1,2))
   AND (T_001.UniqueStringID_0 = T_000.UniqueStringID_1)
   AND (T_000.UniqueStringID_0 <> T_000.UniqueStringID_1)
   AND (T_000.UniqueStringID_1 <> T_001.UniqueStringID_1)
   AND (T_000.UniqueStringID_0 <> T_001.UniqueStringID_1)
;
