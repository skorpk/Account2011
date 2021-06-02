USE RegisterCases
GO
if(OBJECT_ID('usp_Test_IT_SL',N'P')) is not null
	drop PROCEDURE dbo.usp_Test_IT_SL
go
CREATE PROC dbo.usp_Test_IT_SL
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--Если нет SL_COEF то IT_SL должен отсутствовать
INSERT #tError
SELECT c.id,'003F.00.1150'
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20200320'					
where a.rf_idFiles=@idFile AND c.IT_SL IS NOT NULL AND NOT EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=c.id)
--Если есть SL_COEF то IT_SL должен присутствовать
INSERT #tError
SELECT c.id,'003F.00.1170'
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20200320'					
where a.rf_idFiles=@idFile AND c.IT_SL IS NULL AND EXISTS(SELECT 1 FROM dbo.t_Coefficient WHERE rf_idCase=c.id)


GO
GRANT EXECUTE ON usp_Test_IT_SL TO db_RegisterCase