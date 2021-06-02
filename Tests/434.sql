USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT	

select @idFile=id from vw_getIdFileNumber where CodeM='805965' and NumberRegister=125 and ReportYear=2020

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
--устанавливаем дату начала и дату окончания отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	

SELECT DISTINCT c.id,434
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'		 	  
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase      
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
			  INNER JOIN dbo.vw_sprMKB10 m ON
		d.DS1=m.DiagnosisCode        
				INNER JOIN dbo.t_DiagnosticBlock dd ON
		sl.id=dd.rf_idONK_SL              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND dd.TypeDiagnostic=2 AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprN012 WHERE DS_Igh=m.MainDS AND ID_Igh=dd.CodeDiagnostic) 
	AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi mm WHERE mm.MUCode LIKE '60.9%' AND mm.rf_idCase=c.id)

SELECT DISTINCT c.id,434,n9.ID_Igh,c.idRecordCase,d.DS1,dd.CodeDiagnostic,TypeDiagnostic
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'		 	  
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase      
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
			  INNER JOIN dbo.vw_sprMKB10 m ON
		d.DS1=m.DiagnosisCode        
			 INNER JOIN oms_nsi.dbo.sprN012 n9 ON
		DS_Igh=m.MainDS
			 INNER JOIN dbo.t_DiagnosticBlock dd ON
		sl.id=dd.rf_idONK_SL
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND dd.TypeDiagnostic=2 AND c.DateEnd BETWEEN n9.DATEBEG AND n9.DATEEND
		AND NOT EXISTS(SELECT * FROM dbo.t_DiagnosticBlock dd1 WHERE dd1.rf_idONK_SL=sl.id AND dd1.TypeDiagnostic=2 AND dd1.CodeDiagnostic=n9.ID_Igh) 
		AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi mm WHERE mm.MUCode LIKE '60.9%' AND mm.rf_idCase=c.id)
ORDER BY id

