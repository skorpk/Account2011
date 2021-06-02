USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT


select @idFile=id from vw_getIdFileNumber where CodeM='805965' and NumberRegister=125 and ReportYear=2020

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

SELECT 1,c.id,'310'
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase								
				INNER JOIN dbo.t_Meduslugi m ON
        c.id=m.rf_idCase
where a.rf_idFiles=@idFile AND m.MUCode LIKE '60.9.%' AND EXISTS(SELECT mm.rf_idCase FROM dbo.t_Meduslugi mm WHERE rf_idCase=c.id GROUP BY mm.rf_idCase HAVING COUNT(*)>1)

--Если МГИ, то основной диагноз должен быть равен диагнозу на уровне USL
SELECT 2,c.id,'310'
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase								
			  INNER JOIN dbo.vw_Diagnosis d ON
        c.id=d.rf_idCase
				INNER JOIN dbo.t_Meduslugi m ON
        c.id=m.rf_idCase
where a.rf_idFiles=@idFile AND m.MUCode LIKE '60.9.%' AND d.DS1<>m.DiagnosisCode

--Если МГИ, и по услуги нет совпадения с таблицой справочников, то не должно быть блока B_Diag
SELECT distinct 3,c.id,'310'
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase											  
				INNER JOIN dbo.t_Meduslugi m ON
        c.id=m.rf_idCase
				INNER JOIN dbo.t_ONK_SL o ON
         c.id=o.rf_idCase
				INNER JOIN dbo.t_DiagnosticBlock db ON
         o.id=db.rf_idONK_SL
where a.rf_idFiles=@idFile AND m.MUCode LIKE '60.9.%' AND NOT EXISTS(SELECT 1 FROM dbo.vw_sprMGI_N010_N012 n WHERE n.mu=m.MUCode)

--Если МГИ, и по услуги есть совпадения с таблицой sprMUN010
SELECT DISTINCT 4,c.id,'310'
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase											  
			    inner join dbo.t_CompletedCase cc on
		r.id=cc.rf_idRecordCase											  
				INNER JOIN dbo.vw_Diagnosis d ON
        c.id=d.rf_idCase
				INNER JOIN dbo.t_Meduslugi m ON
        c.id=m.rf_idCase
				INNER JOIN dbo.vw_sprMGI_N010_N012 mg ON
        m.MUCode=mg.MU
		AND d.RubricName=mg.DS_Igh
		AND cc.DateEnd BETWEEN mg.DATEBEG AND mg.DATEEND
where a.rf_idFiles=@idFile AND m.MUCode LIKE '60.9.%' AND NOT EXISTS(SELECT 1 
																	 FROM dbo.t_ONK_SL o INNER JOIN dbo.t_DiagnosticBlock d ON
																				o.id=d.rf_idONK_SL
																	 WHERE o.rf_idCase=c.id AND d.TypeDiagnostic=2 AND d.REC_RSLT=1)
SELECT DISTINCT 5,c.id,'310'
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			 inner join dbo.t_CompletedCase cc on
		r.id=cc.rf_idRecordCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase											  
			 INNER JOIN dbo.vw_Diagnosis d ON
        c.id=d.rf_idCase
				INNER JOIN dbo.t_Meduslugi m ON
        c.id=m.rf_idCase
				INNER JOIN dbo.vw_sprMGI_N010_N012 mg ON
        m.MUCode=mg.MU
		AND cc.DateEnd BETWEEN mg.DATEBEG AND mg.DATEEND
				INNER JOIN dbo.t_ONK_SL o ON
         c.id=o.rf_idCase
				INNER JOIN dbo.t_DiagnosticBlock db ON
         o.id=db.rf_idONK_SL
where a.rf_idFiles=@idFile AND m.MUCode LIKE '60.9.%' AND db.TypeDiagnostic=2 AND db.REC_RSLT=1
		AND NOT EXISTS(SELECT 1 FROM dbo.vw_sprMGI_N010_N012 n WHERE n.mu=m.MUCode AND d.RubricName=n.DS_Igh AND db.CodeDiagnostic=n.Diag_Code AND cc.DateEnd BETWEEN n.DATEBEG AND n.DATEEND)


