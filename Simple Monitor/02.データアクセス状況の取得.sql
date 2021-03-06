﻿SET NOCOUNT ON

-- データアクセス状況の取得
-- DROP TABLE IF EXISTS #T1
-- DROP TABLE IF EXISTS #T2

IF (OBJECT_ID('tempdb..#T1') IS NOT NULL)
	DROP TABLE #T1
IF (OBJECT_ID('tempdb..#T2') IS NOT NULL)
	DROP TABLE #T2


SELECT
	GETDATE() counter_date,
	*
INTO #T1
FROM 
	sys.dm_os_performance_counters
WHERE
	object_name LIKE '%Buffer Manager%'
	AND
	counter_name IN('Page lookups/sec', 'Readahead pages/sec', 'Readahead time/sec', 'Page reads/sec', 'Page writes/sec', 'Checkpoint pages/sec', 'Background writer pages/sec')

WAITFOR DELAY '00:00:01'


SELECT
	GETDATE() counter_date,
	*
INTO #T2
FROM 
	sys.dm_os_performance_counters
WHERE
	object_name LIKE '%Buffer Manager%'
	AND
	counter_name IN('Page lookups/sec', 'Readahead pages/sec', 'Readahead time/sec', 'Page reads/sec', 'Page writes/sec', 'Checkpoint pages/sec', 'Background writer pages/sec')


SELECT 
    #T2.counter_date,
	RTRIM(#T1.object_name) object_name,
	RTRIM(#T1.counter_name) counter_name,
	RTRIM(#T1.instance_name) instance_name,
	CAST((#T2.cntr_value - #T1.cntr_value) / (DATEDIFF (ms, #T1.counter_date,#T2.counter_date) / 1000.0) AS bigint) AS cntr_value,
	CAST((#T2.cntr_value - #T1.cntr_value) / (DATEDIFF (ms, #T1.counter_date,#T2.counter_date) / 1000.0) AS bigint) * 8 / 1024.0 AS cntr_value_MB
FROM #T1
	LEFT JOIN
	#T2
	ON
	#T1.object_name = #T2.object_name
	AND
	#T1.counter_name = #T2.counter_name
