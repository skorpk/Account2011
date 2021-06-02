USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT

select @idFile=id from vw_getIdFileNumber where CodeM='103001' and NumberRegister=1 and ReportYear=2019

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


SELECT DISTINCT c.id,427
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
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprN002 WHERE (DS_St=m.DiagnosisCode OR DS_St=m.MainDS OR ISNULL(DS_St,m.MainDS)=m.MainDS ) AND ID_St=sl.rf_idN002)

---2 test
SELECT DISTINCT c.id,427
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
				INNER JOIN oms_nsi.dbo.sprN006 n6 ON
		m.MainDS=n6.DS_gr          
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprN006 WHERE DS_gr=m.MainDS AND ID_St=sl.rf_idN002 AND ID_T=sl.rf_idN003 AND ID_N=sl.rf_idN004 AND ID_M=sl.rf_idN005)

/*
Если DS1_T in (0,1,2,3,4), то STAD должно быть заполнено обязательно значением из N002(из N002 выбираются только действующие на DATE_Z_2 записи). Для установления факта соответствия N002 необходимо:
1.	сначала отобрать записи в N002 по условию DS_St= DS1. Значение тега STAD должно соответствовать  значению поля ID_St  одной из отобранных записей. Если таких записей нет, то
2.	отбор записей проводится по условию DS_St=LEFT(DS1;3). Значение тега STAD должно соответствовать  значению поля ID_St  одной из отобранных записей. Если таких записей нет, то
3.	соответствие проверяется на множестве записей, для которых DS_ST is null.

*/
SELECT DISTINCT c.id,427,c.GUID_Case,sl.rf_idN002, sl.DS1_T
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
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.DS1_T>0 AND sl.DS1_T<5
	AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprN002 WHERE (DS_St=m.DiagnosisCode OR DS_St=m.MainDS OR ISNULL(DS_St,m.MainDS)=m.MainDS ) 
					AND ID_St=sl.rf_idN002 AND DATEBEG<=cc.DateEnd AND cc.DateEnd<=DATEEND)
SELECT * FROM oms_nsi.dbo.sprN002 WHERE ID_ST=23