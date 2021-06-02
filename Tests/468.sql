USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT,
	@month TINYINT=1,
	@year SMALLINT=2019

select @idFile=id, @month=ReportMonth, @year=ReportYear from vw_getIdFileNumber where CodeM='591001' and NumberRegister=163 and ReportYear=2019

select * from vw_getIdFileNumber where id=@idFile

SELECT c.id,468,p.TypeExamination
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase
		AND c.DateEnd>='20190101'				
				INNER JOIN dbo.t_Prescriptions p ON
		c.id=p.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='F' AND p.NAZR=3 AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprV029 WHERE IDMET=ISNULL(p.TypeExamination,0)) 

SELECT * FROM oms_nsi.dbo.sprV029