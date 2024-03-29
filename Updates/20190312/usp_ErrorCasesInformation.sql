USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_ErrorCasesInformation]    Script Date: 13.03.2019 13:38:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[usp_ErrorCasesInformation]
			@idFile Int
as
select c.id,c.idRecordCase, c.rf_idV006 AS USL_OK, c.rf_idV008 AS VIDPOM, c.rf_idV014 AS V014, c.rf_idV018 AS V018, c.rf_idV019 AS V019,
		CASE WHEN c.HopitalisationType=1 THEN 'П' WHEN c.HopitalisationType=2 THEN 'Э' ELSE NULL END AS HospitalisationType, 
	   c.rf_idV002 AS Profil, 
	   CASE WHEN IsChildTariff=0 THEN 'В' ELSE 'Д' END AS IsChildTariff  , NumberHistoryCase, DateBegin, DateEnd, rf_idV009 AS RSLT,
	   c.rf_idV012 AS ISHOD, c.rf_idV004 AS PRVS, c.AmountPayment, c.Age, c.IsCompletedCase,e.ErrorNumber
INTO #tmpCase
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase									
						INNER JOIN dbo.t_ErrorProcessControl e ON
			c.id=e.rf_idCase

SELECT mu,MUName INTO #tMU FROM dbo.vw_sprMUCompletedCase 
UNION ALL 
SELECT code,name FROM dbo.vw_sprCSG

CREATE NONCLUSTERED INDEX IX_t ON #tMU(mu) INCLUDE(MUName)


SELECT c.id, c.idRecordCase, c.USL_OK, c.VIDPOM, c.V014, c.V018, c.V019, c.HospitalisationType, c.Profil, c.IsChildTariff, c.NumberHistoryCase,
          c.DateBegin, c.DateEnd, c.RSLT, c.ISHOD, c.PRVS, c.AmountPayment, c.Age, c.IsCompletedCase
          ,CAST(c.ErrorNumber AS VARCHAR(3))+' - '+e.DescriptionError AS ErrorNumber, RTRIM(m.MES) AS MES, MUName, m.Tariff
FROM #tmpCase c INNER JOIN dbo.t_MES m ON
		c.id=m.rf_idCase
				INNER JOIN vw_ErrorsDescription e ON
		c.ErrorNumber=e.Code
				inner JOIN #tMU mu ON
		m.MES=mu.mU
WHERE c.IsCompletedCase=1
UNION ALL
SELECT c.id, c.idRecordCase, c.USL_OK, c.VIDPOM, c.V014, c.V018, c.V019, c.HospitalisationType, c.Profil, c.IsChildTariff, c.NumberHistoryCase,
          c.DateBegin, c.DateEnd, c.RSLT, c.ISHOD, c.PRVS, c.AmountPayment, c.Age, c.IsCompletedCase
          ,CAST(c.ErrorNumber AS VARCHAR(3))+' - '+e.DescriptionError AS ErrorNumber, RTRIM(m.MES) AS MES, null, m.Tariff
FROM #tmpCase c INNER JOIN dbo.t_MES m ON
		c.id=m.rf_idCase
				INNER JOIN vw_ErrorsDescription e ON
		c.ErrorNumber=e.Code				
WHERE c.IsCompletedCase=1 AND NOT EXISTS(SELECT 1 FROM #tMU WHERE MU=m.MES)
UNION ALL
SELECT c.id, c.idRecordCase, c.USL_OK, c.VIDPOM, c.V014, c.V018, c.V019, c.HospitalisationType, c.Profil, c.IsChildTariff, c.NumberHistoryCase,
          c.DateBegin, c.DateEnd, c.RSLT, c.ISHOD, c.PRVS, c.AmountPayment, c.Age, c.IsCompletedCase
          ,CAST(c.ErrorNumber AS VARCHAR(3))+' - '+e.DescriptionError AS ErrorNumber,NULL,NULL,NULL 
FROM #tmpCase c INNER JOIN vw_ErrorsDescription e ON
		c.ErrorNumber=e.Code
WHERE IsCompletedCase=0
ORDER BY idRecordCase

DROP TABLE #tmpCase	
