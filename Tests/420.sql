USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT,
	@month TINYINT,
	@year SMALLINT

select @idFile=id from vw_getIdFileNumber where CodeM='804504' and NumberRegister=19370 and ReportYear=2019

select * from vw_getIdFileNumber where id=@idFile

DECLARE @codeLPU CHAR(6),
		@dateReg DATE

select @month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile


SELECT DISTINCT c.id,420
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'	
				INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase						 
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.C_ZAB IS NOT NULL AND NOT EXISTS(SELECT * FROM  oms_nsi.dbo.sprV027 WHERE IDCZ=c.C_ZAB AND cc.DateEnd BETWEEN DATEBEG AND DATEEND)

SELECT DISTINCT c.id,420 ,d.DS1
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'							 
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase              				
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.C_ZAB IS NULL AND c.rf_idV006=3 AND d.DS1 NOT LIKE 'Z[0-9][0-9]%'

/*
SELECT c.C_ZAB ,d.DS1
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'							 
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase              				
where c.GUID_Case IN('085E033B-599F-D5B8-9B93-48D396B3CC9B',
'EEADC495-2D34-A535-6F5B-7EEF96B3DF38',
'1CBDFBE1-865D-E56F-B5C2-55E996B3A226',
'386B838F-95B8-8E79-0B52-5B2596B477F0',
'D194FFA3-5800-DAEB-0A80-611196AFF3BA',
'C4494F39-C4A0-51D2-A5CA-F1CC96AD0A76',
'3F0981EC-E77E-584F-6A5C-6F6596AC52DE',
'93896F8F-C7E3-FBE7-F431-BD1096B3B565',
'900908D1-0962-D8D8-E043-B4E596ACA8D5',
'E7E76610-3DD6-ED1F-7C25-307E96B38F5F',
'DD559B3D-05CE-67F5-273D-420796B43AAB',
'97287722-C436-9E2E-66A4-FF0796B44589',
'453EDFAB-0895-ADF4-D4C2-AFEE96AC87BA',
'163D55D7-1DAD-AA28-3B70-5AED96B3990E',
'4A02C969-E5B1-B280-3D29-878596B4541E',
'30754E12-0962-F14A-5A21-253096B465F1',
'D52064D0-88AE-B9C2-6874-BE6996BD46AE',
'55755E6D-BAE7-1838-1E3C-29E796B407AA',
'3B1D9352-194B-5ABE-F1E2-B34A96AC7930',
'301B0940-C81F-48FA-DC48-08C096B419E9',
'7162D418-E5AC-8DEB-910D-00CB96B3EFBF')
 */


--Тег обязательно присутствует, если (DS1 is like C% or DS1 like D0%)
SELECT DiagnosisCode INTO #tDS1 FROM dbo.vw_sprMKB10 WHERE DiagnosisCode LIKE 'C%'
INSERT #tDS1( DiagnosisCode ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE DiagnosisCode LIKE 'D0%'

SELECT DISTINCT c.id,420,c.GUID_Case
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'							 
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase              				
				INNER JOIN #tDS1 dd ON
		d.DS1=dd.DiagnosisCode              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.C_ZAB IS NULL 

--Тег обязательно присутствует, если (DS1 like D70% and один из сопутствующих DS2 из диапазона (C00-C80,C97))
SELECT DiagnosisCode,MainDS INTO #tDS2 FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'C00' AND 'C80'
INSERT #tDS2 SELECT DiagnosisCode,MainDS FROM dbo.vw_sprMKB10 WHERE MainDS='C97'


SELECT DISTINCT c.id,420,DS2, dd.*
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'							 
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase              				
				INNER JOIN #tDS2 dd ON
		d.DS2=dd.DiagnosisCode              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.C_ZAB IS NULL AND d.DS1 LIKE 'D70%'
go
DROP TABLE #tDS1
DROP TABLE #tDS2
