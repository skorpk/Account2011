USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test66]    Script Date: 10.01.2019 16:41:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test66]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	
/* Объединяю периоды  т.к. в справочнике они не объеденены*/
DECLARE @tmpMSLocation AS TABLE (CodeM CHAR(6), DateBegin DATE, DateEnd DATE,rf_idV006 TINYINT,rf_idV008 SMALLINT, rf_idV002 SMALLINT)

IF EXISTS(SELECT CodeM,rf_idV002,rf_idV006,rf_idV008 
	FROM vw_MSLocation WHERE CodeM=@codeLPU GROUP BY CodeM,rf_idV002,rf_idV006,rf_idV008 HAVING COUNT(*)>1)
BEGIN
	;WITH sprPeriod1 AS
	(
		SELECT ROW_NUMBER() OVER(ORDER BY CodeM,DateBegin,rf_idV006,rf_idV008,rf_idV002) AS ROWID,CodeM,DateBegin,(DateEnd-1)  AS DateEnd,
				rf_idV006,rf_idV008,rf_idV002
		FROM vw_MSLocation 
		WHERE CodeM=@codeLPU
	)
	INSERT @tmpMSLocation
	SELECT a.CodeM, a.DateBegin,a1.DateEnd,a.rf_idV006,a.rf_idV008,a.rf_idV002
	FROM sprPeriod1 a INNER JOIN sprPeriod1 a1 ON
				a.CodeM=a1.CodeM
				AND a.rf_idV006=a1.rf_idV006
				AND a.rf_idV008=a1.rf_idV008
				AND a.rf_idV002=a1.rf_idV002
				AND a.RowId<>a1.ROWID
				AND a.DateBegin<=a1.DateEnd
END
--------------------------------------------------------------------------------
--кладем уникальные записи в таблицу по лицензиям
 INSERT @tmpMSLocation( CodeM,rf_idV002,rf_idV006,rf_idV008 ,DateBegin ,DateEnd)
 SELECT v.CodeM,v.rf_idV002,v.rf_idV006,v.rf_idV008 ,v.DateBegin,v.DateEnd
 FROM vw_MSLocation v INNER JOIN (SELECT CodeM,rf_idV002,rf_idV006,rf_idV008 
								  FROM vw_MSLocation 
								  WHERE CodeM=@codeLPU 
								  GROUP BY CodeM,rf_idV002,rf_idV006,rf_idV008 
								  HAVING COUNT(*)=1) t ON
			v.CodeM=t.CodeM
			AND v.rf_idV002=t.rf_idV002
			AND v.rf_idV006=t.rf_idV006
			AND v.rf_idV008=t.rf_idV008
 WHERE v.CodeM=@codeLPU 
/*--------------------------------------*/
insert #tError
select c.id,66
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			--AND c.IsCompletedCase=0
			AND c.DateEnd>=@dateStart
			AND c.DateEnd<@dateEnd
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
			AND m.MUCode NOT LIKE '2.82.%'			
WHERE NOT EXISTS(SELECT * FROM @tmpMSLocation
				 WHERE CodeM=@CodeLPU AND rf_idV006=c.rf_idV006 AND rf_idV008=c.rf_idV008 AND rf_idV002=c.rf_idV002 
						AND DateBegin<=c.DateBegin AND DateEnd>=c.DateEnd)

/*--------------------------------------*/
insert #tError
select c.id,66
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013
						inner join t_Case c on
			r.id=c.rf_idRecordCase			
			AND c.IsCompletedCase=1				
			AND c.DateEnd>=@dateStart
			AND c.DateEnd<@dateEnd
WHERE NOT EXISTS(SELECT * FROM @tmpMSLocation
				 WHERE CodeM=@CodeLPU AND rf_idV006=c.rf_idV006 AND rf_idV008=c.rf_idV008 AND rf_idV002=c.rf_idV002 
						AND DateBegin<=c.DateBegin AND DateEnd>=c.DateEnd)
/*--------------------------------------*/						
-- алгоритм для случаев оказания амбулаторно-поликлинической помощи в приемном отделение стационара						
insert #tError
select c.id,66
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			AND c.rf_idV006=3	
			AND c.DateEnd>=@dateStart
			AND c.DateEnd<@dateEnd
			AND c.DateEnd<'20190101'
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
			AND m.MUCode LIKE '2.82.%'			
WHERE NOT EXISTS(SELECT * FROM vw_MSLocation 
				 WHERE CodeM=@CodeLPU AND rf_idV006=1 AND rf_idV008=31 AND rf_idV002=c.rf_idV002 
						AND DateBegin<=c.DateBegin AND DateEnd>=c.DateEnd)				
