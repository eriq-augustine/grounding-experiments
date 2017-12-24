SELECT
   T_000.UniqueStringID_0 AS P1,
   T_000.UniqueStringID_1 AS A,
   T_001.UniqueStringID_0 AS P2,
   T_002.UniqueStringID_0 AS P3
FROM
   BLOCK_PREDICATE T_000,
   BLOCK_PREDICATE T_001,
   BLOCK_PREDICATE T_002
WHERE
   (T_000.partition_id IN (1,2))
   AND (T_001.partition_id IN (1,2))
   AND (T_002.partition_id IN (1,2))
   AND (T_000.UniqueStringID_1 = T_001.UniqueStringID_1)
   AND (T_000.UniqueStringID_1 = T_002.UniqueStringID_1)
   AND (T_000.UniqueStringID_0 <> T_001.UniqueStringID_0)
   AND (T_001.UniqueStringID_0 <> T_002.UniqueStringID_0)
   AND (T_000.UniqueStringID_0 <> T_002.UniqueStringID_0)
;
