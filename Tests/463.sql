USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT,
	@month TINYINT=1,
	@year SMALLINT=2019

select @idFile=id, @month=ReportMonth, @year=ReportYear from vw_getIdFileNumber where CodeM='101004' and NumberRegister=1 and ReportYear=2019

select * from vw_getIdFileNumber where id=@idFile


SELECT c.id,463
from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND a.ReportMonth=@month
			AND a.ReportYear=@year
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase						
			AND c.DateEnd>='20190101'									
					INNER JOIN dbo.t_MES mm ON
			c.id=mm.rf_idCase               
where a.rf_idFiles=@idFile AND mm.Tariff<>c.AmountPayment AND mm.IsCSGTag=1

SELECT c.id,463
from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND a.ReportMonth=@month
			AND a.ReportYear=@year
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase						
			AND c.DateEnd>='20190101'									
					INNER JOIN dbo.t_Meduslugi mm ON
			c.id=mm.rf_idCase               
where a.rf_idFiles=@idFile AND c.IsCompletedCase=0 
GROUP BY c.id, c.AmountPayment
HAVING c.AmountPayment<>SUM(mm.Quantity*mm.Price)