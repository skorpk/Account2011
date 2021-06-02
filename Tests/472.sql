USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='255627' AND ReportYear=2020 AND NumberRegister=129

SELECT * FROM vw_getIdFileNumber WHERE id=@idFile

declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6),
		@typeFile char(1)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod =rc.rf_idMO, @typeFile=UPPER(f.TypeFile)
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles		
WHERE f.id=@idFile							
SELECT @month,@year

SELECT c.id,472,p.rf_dV002
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
				INNER JOIN dbo.t_Prescriptions p ON
		c.id=p.rf_idCase		
where a.rf_idFiles=@idFile AND f.TypeFile='F' AND p.NAZR IN(4,5) 
AND NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprV002 WHERE id=ISNULL(p.rf_dV002,0) AND cc.DateEnd BETWEEN DateBeg AND DateEnd)

SELECT * FROM oms_nsi.dbo.sprV002 WHERE id=64