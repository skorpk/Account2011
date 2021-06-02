USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT


select @idFile=id from vw_getIdFileNumber where CodeM='101001' and NumberRegister=42 and ReportYear=2020

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


CREATE TABLE #sprDiag(DS1  VARCHAR(8))

INSERT #sprDiag(DS1) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'
INSERT #sprDiag(DS1) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0[0-9]'
/*
1.	���� � ������� ������ ������������ ������ �� ������ 60.8.* � ZL_LIST\ZAP\Z_SL\SL\DS1=Z03.1, �� �� ���� ����� USL ZL_LIST\ZAP\Z_SL\SL\USL\DS ( NOT like ��%� and NOT like �D0[0-9]%�)
*/
SELECT DISTINCT c.id,306
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20200101'		
			INNER JOIN dbo.t_Meduslugi m ON
        m.rf_idCase = c.id
			INNER JOIN vw_sprMU mm ON
        mm.MU=m.MUCode				
			INNER JOIN dbo.vw_Diagnosis d ON
        c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND mm.MUGroupCode=60 AND mm.MUUnGroupCode=8 AND d.DS1='Z03.01'
		AND EXISTS(SELECT 1 
					FROM dbo.t_Meduslugi m1 INNER JOIN #sprDiag dd ON
							m1.DiagnosisCode=dd.DS1
					WHERE m1.rf_idCase=c.id
					)
/*
2.	���� � ������� ������ ������������ ������ �� ������ 60.8.* � ZL_LIST\ZAP\Z_SL\SL\DS1 like �C%�, �� ���� �� � ����� ���� USL ZL_LIST\ZAP\Z_SL\SL\USL\DS=ZL_LIST\ZAP\Z_SL\SL\DS1
*/								
SELECT DISTINCT c.id,306
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20200101'		
			INNER JOIN dbo.t_Meduslugi m ON
        m.rf_idCase = c.id
			INNER JOIN vw_sprMU mm ON
        mm.MU=m.MUCode				
			INNER JOIN dbo.vw_Diagnosis d ON
        c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND mm.MUGroupCode=60 AND mm.MUUnGroupCode=8 AND d.DS1 LIKE 'C%'
		AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi m1 WHERE m1.rf_idCase=c.id AND m1.DiagnosisCode=d.DS1)

--SELECT * FROM dbo.t_Meduslugi m1 WHERE m1.rf_idCase=125324832

--SELECT * FROM dbo.vw_Diagnosis WHERE rf_idCase=125324832

GO
DROP TABLE #sprDiag