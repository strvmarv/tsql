SELECT SUM(CAST(FILEPROPERTY(name, 'SpaceUsed') AS bigint) * 8192.) AS DatabaseSizeInBytes,
       SUM(CAST(FILEPROPERTY(name, 'SpaceUsed') AS bigint) * 8192.) / 1024 / 1024 AS DatabaseSizeInMB,
       SUM(CAST(FILEPROPERTY(name, 'SpaceUsed') AS bigint) * 8192.) / 1024 / 1024 / 1024 AS DatabaseSizeInGB
FROM sys.database_files
WHERE type_desc = 'ROWS';

SELECT (SUM(reserved_page_count) * 8192) / 1024 / 1024 AS DbSizeInMB
FROM    sys.dm_db_partition_stats

SELECT name, database_id, create_date  
FROM sys.databases ;  

-- Query to get all DB table sizes
-- https://docs.microsoft.com/en-us/azure/sql-database/sql-database-monitoring-with-dmvs
SELECT    
      obj.NAME AS "ObjectName", 
      SUM(reserved_page_count) * 8.0 / 1024 AS "Size (MB)"
FROM sys.dm_db_partition_stats DPS
	INNER JOIN sys.objects obj
		ON (DPS.object_id = obj.object_id)
GROUP BY obj.name
ORDER BY obj.name

-- Get top 5 slowest Statements
-- https://docs.microsoft.com/en-us/azure/sql-database/sql-database-monitoring-with-dmvs
SELECT TOP 5 query_stats.query_hash AS "Query Hash",
    SUM(query_stats.total_worker_time) / SUM(query_stats.execution_count) AS "Avg CPU Time",
    MIN(query_stats.statement_text) AS "Statement Text"
FROM
    (SELECT QS.*,
    SUBSTRING(ST.text, (QS.statement_start_offset/2) + 1,
    ((CASE statement_end_offset
        WHEN -1 THEN DATALENGTH(ST.text)
        ELSE QS.statement_end_offset END
            - QS.statement_start_offset)/2) + 1) AS statement_text
     FROM sys.dm_exec_query_stats AS QS
     CROSS APPLY sys.dm_exec_sql_text(QS.sql_handle) as ST) as query_stats
GROUP BY query_stats.query_hash
ORDER BY 2 DESC;

SELECT COUNT(*) FROM WebLogSummaryByUrl WITH (NOLOCK)

SELECT MIN (LogUtc) FROM WebLogSummaryByUrl WITH (NOLOCK)
SELECT MAX (LogUtc) FROM WebLogSummaryByUrl WITH (NOLOCK)

-- Get top worker queries
SELECT
    highest_cpu_queries.plan_handle,
    highest_cpu_queries.total_worker_time,
    q.dbid,
    q.objectid,
    q.number,
    q.encrypted,
    q.[text]
FROM
    (SELECT TOP 50
        qs.plan_handle,
        qs.total_worker_time
    FROM
        sys.dm_exec_query_stats qs
    ORDER BY qs.total_worker_time desc) AS highest_cpu_queries
    CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS q
ORDER BY highest_cpu_queries.total_worker_time DESC;