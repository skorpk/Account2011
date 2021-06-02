USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT

select @idFile=id from vw_getIdFileNumber where CodeM='103001' and NumberRegister=833 and ReportYear=2020

select * from vw_getIdFileNumber where id=@idFile

SELECT ErrorNumber,COUNT(rf_idCase) AS CountCase FROM dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile GROUP BY ErrorNumber ORDER BY countCase desc
declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6),
		@typeFile char(1)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod =rc.rf_idMO, @typeFile=UPPER(f.TypeFile)
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile

SELECT DISTINCT c.id,428
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'
		AND c.DateEnd<'20190101'
		 	  INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
			  INNER JOIN dbo.vw_sprMKB10 m ON
		d.DS1=m.DiagnosisCode					
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase        	     
where a.rf_idFiles=@idFile AND f.TypeFile='H' 
AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprN003 WHERE (DS_T=m.DiagnosisCode OR DS_T=m.MainDS OR ISNULL(DS_t,m.MainDS)=m.MainDS) AND ID_T=sl.rf_idN003)

/*
≈сли DS1_T=0 and Age >17, то значение должно присутствовать об€зательно и соответствовать справочнику N003(выбираютс€ только действующие на DATE_Z_2 записи). 
ƒл€ установлени€ факта соответстви€ необходимо сначала отфильтровать записи в N003 по условию DS_T=DS1, и если выборка не пуста, значение тега ONK_T должно соответствовать
значению пол€ ID_T  одной из отфильтрованных записей. ≈сли выборка пуста, то отбор проводитс€ по условию: DS_T=LEFT(DS1;3), значение тега ONK_T должно соответствовать  
значению пол€ ID_T  одной из отфильтрованных записей. ≈сли выборка пуста, то соответствие провер€етс€ на множестве записей, дл€ которых DS_T is null.
*/
SELECT DISTINCT c.id,428,d.DS1
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
		 	  INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
			  INNER JOIN dbo.vw_sprMKB10 m ON
		d.DS1=m.DiagnosisCode					
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase        	     
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.DS1_T=0 AND c.Age>17
AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprN003 WHERE (DS_T=m.DiagnosisCode OR DS_T=m.MainDS OR ISNULL(DS_t,m.MainDS)=m.MainDS) AND ID_T=sl.rf_idN003 AND DATEBEG<=cc.DateEnd AND cc.DateEnd<=DATEEND) 

SELECT * FROM oms_nsi.dbo.sprN003 WHERE DS_T='C69'
SELECT * FROM dbo.vw_sprMKB10 WHERE DiagnosisCode='C69.6'

SELECT * FROM oms_nsi.dbo.sprN018 
