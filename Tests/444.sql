USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='103001' AND ReportYear=2020 AND NumberRegister=89


SELECT ErrorNumber,COUNT(rf_idCase) AS CountCase FROM dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile GROUP BY ErrorNumber ORDER BY countCase DESC

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

;WITH cteDate
AS(
	SELECT cc.id,r.id AS idPac,cc.DateBegin,cc.DateEnd, MIN(c.DateBegin) AS DateBegCase, MAX(c.DateEnd) AS DateEndCase
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
	where a.rf_idFiles=@idFile 
	GROUP BY cc.id,r.id,cc.DateBegin,cc.DateEnd
)
SELECT DISTINCT cc.id,444
FROM cteDate c INNER JOIN dbo.t_Case cc ON
		c.idPac=cc.rf_idRecordCase
WHERE c.DateBegin<>c.DateBegCase OR c.DateEnd<>c.DateEndCase

--SELECT * FROM dbo.t_Case WHERE id=124147201
SELECT * FROM dbo.t_RecordCase WHERE id=124178187

SELECT * FROM dbo.t_CompletedCase WHERE rf_idRecordCase=124178187

SELECT * FROM dbo.t_Case WHERE rf_idRecordCase=124178187
