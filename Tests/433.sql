USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT


select @idFile=id from vw_getIdFileNumber where CodeM='101801' and NumberRegister=12335 and ReportYear=2020

select * from vw_getIdFileNumber where id=@idFile

--declare @month tinyint,
--		@year smallint,
--		@codeLPU char(6),
--		@dateReg DATE,
--		@mcod CHAR(6),
--		@typeFile char(1)
		
--select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod =rc.rf_idMO, @typeFile=UPPER(f.TypeFile)
--from t_File f inner join t_RegistersCase rc on
--			f.id=rc.rf_idFiles
--					inner join oms_nsi.dbo.vw_sprT001 v on
--			f.CodeM=v.CodeM		
--where f.id=@idFile

SELECT DISTINCT c.id,433
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		--AND a.ReportMonth=@month
		--AND a.ReportYear=@year
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
				INNER JOIN oms_nsi.dbo.sprN009 n9 ON
		DS_Mrf=m.MainDS             
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND dd.TypeDiagnostic=1 AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprN009 WHERE DS_Mrf=m.MainDS AND ID_Mrf=dd.CodeDiagnostic) 

--SELECT * FROM oms_nsi.dbo.sprN009 WHERE DS_Mrf='C44'

--SELECT o.id,d.*,dd.DS1,m.MainDS
--FROM dbo.t_Case o INNER JOIN dbo.t_ONK_SL s ON
--		o.id=s.rf_idCase
--				INNER JOIN dbo.t_DiagnosticBlock d ON
--        s.id=d.rf_idONK_SL
--				INNER JOIN dbo.vw_Diagnosis dd ON
--		o.id=dd.rf_idCase
--			  INNER JOIN dbo.vw_sprMKB10 m ON
--		dd.DS1=m.DiagnosisCode 
--WHERE GUID_Case='9F9E07B1-1027-3484-E053-02057DC19ECF'

SELECT DISTINCT c.id,433,d.DS1,rf_idONK_SL,dd.*
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		--AND a.ReportMonth=@month
		--AND a.ReportYear=@year
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
			 INNER JOIN oms_nsi.dbo.sprN009 n9 ON
		DS_Mrf=m.MainDS
			 INNER JOIN dbo.t_DiagnosticBlock dd ON
		sl.id=dd.rf_idONK_SL
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND dd.TypeDiagnostic=1 
		AND NOT EXISTS(SELECT * FROM dbo.t_DiagnosticBlock dd1 WHERE dd1.rf_idONK_SL=sl.id AND dd1.TypeDiagnostic=1 AND dd1.CodeDiagnostic=n9.ID_Mrf) 

SELECT * FROM oms_nsi.dbo.sprN009 WHERE DS_Mrf='C44'

SELECT * from t_DiagnosticBlock WHERE rf_idONK_SL=454988

SELECT * FROM oms_nsi.dbo.sprN008