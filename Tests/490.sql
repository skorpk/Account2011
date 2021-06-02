USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT	

select @idFile=id from vw_getIdFileNumber where CodeM='103001' and NumberRegister=679 and ReportYear=2019

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

CREATE TABLE #tCSG(CSG VARCHAR(20),ReportYear SMALLINT)

INSERT #tCSG(CSG,ReportYear) 
SELECT code,2019 AS ReportYear FROM dbo.vw_sprCSG WHERE code ='st19.049'
UNION all
SELECT code,2019 AS ReportYear FROM dbo.vw_sprCSG WHERE code LIKE 'st19.05[0-5]'
UNION all
SELECT code,2019 AS ReportYear FROM dbo.vw_sprCSG WHERE code LIKE 'ds19.01[1-5]'


SELECT DISTINCT c.id,490
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'							 
				INNER JOIN dbo.t_MES m ON
        m.rf_idCase = c.id
				INNER JOIN #tCSG cc ON
        m.MES=cc.CSG		 				
				INNER JOIN dbo.t_ONK_USL u ON
        c.id=u.rf_idCase
				INNER JOIN dbo.t_ONK_SL sl ON
        c.id=sl.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT 1 FROM dbo.t_AdditionalCriterion aa WHERE aa.rf_idCase=c.id AND aa.rf_idAddCretiria LIKE 'mt%')
		AND u.rf_idN013=4 AND sl.DS1_T<3


SELECT DISTINCT c.id,490
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'							 
				INNER JOIN dbo.t_MES m ON
        m.rf_idCase = c.id
				INNER JOIN #tCSG cc ON
        m.MES=cc.CSG		 				
				INNER JOIN dbo.t_ONK_USL u ON
        c.id=u.rf_idCase
				INNER JOIN dbo.t_ONK_SL sl ON
        c.id=sl.rf_idCase
				INNER JOIN dbo.t_AdditionalCriterion ad ON
         c.id=ad.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND EXISTS(SELECT IDDKK FROM oms_nsi.dbo.sprV024 WHERE IDDKK NOT LIKE 'mt%'AND IDDKK NOT LIKE 'fr%' AND IDDKK=ad.rf_idAddCretiria)
		AND u.rf_idN013=4 AND sl.DS1_T<3


SELECT DISTINCT c.id,490
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'							 
				INNER JOIN dbo.t_MES m ON
        m.rf_idCase = c.id
				INNER JOIN #tCSG cc ON
        m.MES=cc.CSG		 								
				INNER JOIN dbo.t_ONK_SL sl ON
        c.id=sl.rf_idCase
				INNER JOIN dbo.t_AdditionalCriterion ad ON
         c.id=ad.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND ad.rf_idAddCretiria LIKE 'mt%' AND sl.DS1_T<3
	AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_USL u WHERE u.rf_idCase=c.id AND u.rf_idN013=4)


SELECT DISTINCT c.id,490
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'							 
				INNER JOIN dbo.t_MES m ON
        m.rf_idCase = c.id
				INNER JOIN #tCSG cc ON
        m.MES=cc.CSG		 								
				INNER JOIN dbo.t_ONK_USL sl ON
        c.id=sl.rf_idCase
				INNER JOIN dbo.t_AdditionalCriterion ad ON
         c.id=ad.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND ad.rf_idAddCretiria LIKE 'mt%' AND sl.rf_idN013=4
	AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_SL u WHERE u.rf_idCase=c.id AND u.DS1_T<3)
GO
DROP TABLE #tCSG