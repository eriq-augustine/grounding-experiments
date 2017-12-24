SELECT
   T_000.UniqueStringID_0 AS P1,
   T_000.UniqueStringID_1 AS P2,
   T_001.UniqueStringID_1 AS A,
   T_002.UniqueStringID_1 AS P3
FROM
   FRIENDS_PREDICATE T_000,
   BLOCK_PREDICATE T_001,
   FRIENDS_PREDICATE T_002,
   BLOCK_PREDICATE T_003,
   BLOCK_PREDICATE T_004
WHERE
   (T_000.partition_id IN (1,2))
   AND (T_001.partition_id IN (1,2))
   AND (T_002.partition_id IN (1,2))
   AND (T_003.partition_id IN (1,2))
   AND (T_004.partition_id IN (1,2))
   AND (T_001.UniqueStringID_0 = T_000.UniqueStringID_1)
   AND (T_002.UniqueStringID_0 = T_000.UniqueStringID_1)
   AND (T_003.UniqueStringID_0 = T_000.UniqueStringID_0)
   AND (T_003.UniqueStringID_1 = T_001.UniqueStringID_1)
   AND (T_004.UniqueStringID_0 = T_002.UniqueStringID_1)
   AND (T_004.UniqueStringID_1 = T_001.UniqueStringID_1)
   AND (T_000.UniqueStringID_0 <> T_000.UniqueStringID_1)
   AND (T_000.UniqueStringID_1 <> T_002.UniqueStringID_1)
   AND (T_000.UniqueStringID_0 <> T_002.UniqueStringID_1)
;
