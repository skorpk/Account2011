USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT	

select @idFile=id from vw_getIdFileNumber where CodeM='103001' and NumberRegister=308 AND ReportYear=2021

SELECT  ErrorNumber,COUNT(rf_idCase) AS CountCase from dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile GROUP BY ErrorNumber   ORDER BY CountCase

select * from vw_getIdFileNumber where id=@idFile

declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile

SELECT DISTINCT c.id,455,d.rf_idV020,cc.DateEnd
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				
			  INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase 
			  INNER JOIN dbo.t_DrugTherapy d on
		c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.GUID_Case='BB8F80AC-B7D0-08B5-E053-02057DC1C251'
									--AND  AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprN020 n INNER JOIN oms_nsi.dbo.sprN020Period nn ON
																	--						n.sprN020Id=nn.rf_sprN020Id
															  --WHERE ID_LEKP=d.rf_idV020 AND nn.DATEBEG<=cc.DateEnd AND nn.DATEEND>=cc.DateEnd)
/*
REGNUM должен быть уникален для ONK_USL(т.е не допускается указывать один и тот же препарат в нескольких тегах LEK_PR)
*/
;WITH cte
AS(
	SELECT c.id,d.rf_idONK_USL,d.rf_idV020
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND a.ReportMonth=@month
			AND a.ReportYear=@year
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase						
			AND c.DateEnd>='20190101'							  			  
				  INNER JOIN dbo.t_DrugTherapy0 d on
			c.id=d.rf_idCase
	where a.rf_idFiles=@idFile AND f.TypeFile='H'
	GROUP BY c.id,d.rf_idONK_USL,d.rf_idV020
	HAVING COUNT(*)>1
)
SELECT id,455 FROM cte

--SELECT * FROM t_DrugTherapy WHERE rf_idCase=115582778

--SELECT * FROM t_DrugTherapy0 WHERE rf_idCase=115582778
