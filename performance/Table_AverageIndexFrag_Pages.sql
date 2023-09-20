SELECT 
	ind.OBJECT_ID AS ID
	,OBJECT_NAME(ind.OBJECT_ID) AS TableName
	,ind.name AS IndexName
	--,p.partition_number
	,indexstats.index_type_desc AS IndexType
	,indexstats.avg_fragmentation_in_percent 
	,ind.fill_factor
	,ind.is_padded
	,indexstats.page_count
	--,indexstats.forwarded_record_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats
INNER JOIN sys.indexes ind ON ind.object_id = indexstats.object_id AND ind.index_id = indexstats.index_id
--LEFT JOIN sys.partitions p ON ind.object_id = p.object_id
WHERE page_count > 1000
	--AND OBJECT_NAME(ind.OBJECT_ID) like 'Error%'
ORDER BY avg_fragmentation_in_percent desc, page_count desc