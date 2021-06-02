USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT=143080

select @idFile=id from vw_getIdFileNumber where CodeM='101801' and NumberRegister=11618 and ReportYear=2019

select * from vw_getIdFileNumber where id=@idFile

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

SELECT DISTINCT c.id,430
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
			INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase
		 	  INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
			  INNER JOIN dbo.vw_sprMKB10 m ON
		d.DS1=m.DiagnosisCode					
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase  		
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprN005 WHERE (DS_M=m.DiagnosisCode OR DS_M=m.MainDS OR ISNULL(DS_M,m.MainDS)=m.MainDS ) AND ID_M=sl.rf_idN005
		AND cc.DateBegin BETWEEN DATEBEG AND DATEEND)

SELECT DISTINCT c.id,430
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
AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprN005 WHERE (DS_M=m.DiagnosisCode OR DS_M=m.MainDS OR ISNULL(DS_M,m.MainDS)=m.MainDS ) AND ID_M=sl.rf_idN005 AND DATEBEG<=cc.DateEnd AND cc.DateEnd<=DATEEND) 
