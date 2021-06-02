use RegisterCases
go
if OBJECT_ID('usp_ErrorCasesInformation',N'P') is not null
drop proc usp_ErrorCasesInformation
go
create proc usp_ErrorCasesInformation
			@idFile Int
as
CREATE TABLE #tmpCase(
	id bigint NOT NULL,
	idRecordCase bigint NOT NULL,
	USL_OK tinyint NULL,
	VIDPOM smallint NULL,
	V014 tinyint NULL,
	V018 varchar(19) NULL,
	V019 smallint NULL,
	HospitalisationType CHAR(1) NULL,
	Profil smallint NOT NULL,
	IsChildTariff CHAR(1) NOT NULL,
	NumberHistoryCase nvarchar(50) NOT NULL,
	DateBegin date NOT NULL,
	DateEnd date NOT NULL,
	RSLT smallint NOT NULL,
	ISHOD smallint NOT NULL,
	PRVS int NOT NULL,
	AmountPayment decimal(15, 2) NOT NULL,
	Age int NULL,
	IsCompletedCase tinyint NULL,
	ErrorNumber  smallint
) 
INSERT #tmpCase( id ,idRecordCase ,USL_OK ,VIDPOM ,V014 ,V018 ,V019 ,HospitalisationType ,Profil ,IsChildTariff ,NumberHistoryCase ,
          DateBegin ,DateEnd ,RSLT ,ISHOD ,PRVS ,AmountPayment ,Age ,IsCompletedCase ,ErrorNumber)
select c.id,c.idRecordCase, c.rf_idV006 AS USL_OK, c.rf_idV008 AS VIDPOM, c.rf_idV014, c.rf_idV018, c.rf_idV019,
		CASE WHEN c.HopitalisationType=1 THEN 'Ï' WHEN c.HopitalisationType=2 THEN 'Ý' ELSE NULL END, 
	   c.rf_idV002 AS Profil, 
	   CASE WHEN IsChildTariff=0 THEN 'Â' ELSE 'Ä' END  , NumberHistoryCase, DateBegin, DateEnd, rf_idV009 AS RSLT,
	   c.rf_idV012 AS ISHOD, c.rf_idV004 AS PRVS, c.AmountPayment, c.Age, c.IsCompletedCase,e.ErrorNumber
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase									
						INNER JOIN dbo.t_ErrorProcessControl e ON
			c.id=e.rf_idCase
				

SELECT c.id, c.idRecordCase, c.USL_OK, c.VIDPOM, c.V014, c.V018, c.V019, c.HospitalisationType, c.Profil, c.IsChildTariff, c.NumberHistoryCase,
          c.DateBegin, c.DateEnd, c.RSLT, c.ISHOD, c.PRVS, c.AmountPayment, c.Age, c.IsCompletedCase
          ,CAST(c.ErrorNumber AS VARCHAR(3))+' - '+e.DescriptionError AS ErrorNumber, RTRIM(m.MES) AS MES, MUName, m.Tariff
FROM #tmpCase c INNER JOIN dbo.t_MES m ON
		c.id=m.rf_idCase
				INNER JOIN vw_ErrorsDescription e ON
		c.ErrorNumber=e.Code
				LEFT JOIN (SELECT mu,MUName FROM dbo.vw_sprMUCompletedCase UNION ALL SELECT code,name FROM dbo.vw_sprCSG) mu ON
		m.MES=mu.mU
UNION ALL
SELECT c.id, c.idRecordCase, c.USL_OK, c.VIDPOM, c.V014, c.V018, c.V019, c.HospitalisationType, c.Profil, c.IsChildTariff, c.NumberHistoryCase,
          c.DateBegin, c.DateEnd, c.RSLT, c.ISHOD, c.PRVS, c.AmountPayment, c.Age, c.IsCompletedCase
          ,CAST(c.ErrorNumber AS VARCHAR(3))+' - '+e.DescriptionError AS ErrorNumber,NULL,NULL,NULL 
FROM #tmpCase c INNER JOIN vw_ErrorsDescription e ON
		c.ErrorNumber=e.Code
WHERE IsCompletedCase=0
ORDER BY idRecordCase

DROP TABLE #tmpCase	
GO