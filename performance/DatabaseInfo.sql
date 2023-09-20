SELECT @@SERVERNAME as [server], DB_NAME() as [database], slo.elastic_pool_name, slo.service_objective, fil.gb
FROM sys.database_service_objectives slo 
JOIN 
(
	SELECT DB_ID() as database_id, SUM(CAST(FILEPROPERTY(name, 'SpaceUsed') AS bigint) * 8192.) / 1024 / 1024 / 1024 AS gb
	FROM sys.database_files
	WHERE type_desc = 'ROWS'
) fil
ON slo.database_id = fil.database_id