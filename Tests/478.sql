USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT,
	@month TINYINT=1,
	@year SMALLINT=2019

select @idFile=id, @month=ReportMonth, @year=ReportYear from vw_getIdFileNumber where CodeM='185905' and NumberRegister=77 and ReportYear=2019

select * from vw_getIdFileNumber where id=@idFile

SELECT DISTINCT ErrorNumber FROM dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile

SELECT DISTINCT c.id,478,m.DirectionMo
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190501'	
				INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase						 
				INNER JOIN dbo.t_DirectionMU m ON
		c.id=m.rf_idCase              
where a.rf_idFiles=@idFile AND m.DirectionMO IS NOT NULL AND NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprMO WHERE MCOD=m.DirectionMO)

SELECT * FROM vw_sprT001 WHERE CodeM='103001'