USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test515]    Script Date: 02.05.2017 16:19:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test515]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
-------------------------02.02.2016------------------------------------------------------
/*
Для услуг из 57 класса должна быть обязаельно только одна из услуг класса 2 с количеством 1 и нулевой стоимостью.
*/
INSERT #tError
select distinct c.id,515
from t_RegistersCase a inner join t_RecordCase r on
			   a.id=r.rf_idRegistersCase
			   and a.rf_idFiles=@idFile 				
				  inner join t_Case c on
			   r.id=c.rf_idRecordCase
			   AND c.DateEnd>'20160101'
					INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase 						                    
WHERE m.MUCode LIKE '57.%' AND NOT EXISTS(SELECT * FROM dbo.t_Meduslugi WHERE rf_idCase=c.id AND MUCode LIKE '2.%' AND Quantity=1 AND Price=0)

INSERT #tError
select distinct c.id,515
from t_RegistersCase a inner join t_RecordCase r on
			   a.id=r.rf_idRegistersCase
			   and a.rf_idFiles=@idFile 				
				  inner join t_Case c on
			   r.id=c.rf_idRecordCase
			   AND c.DateEnd>'20160101'
					INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase 						                    
WHERE m.MUCode LIKE '57.%' AND EXISTS(SELECT rf_idCase FROM dbo.t_Meduslugi WHERE rf_idCase=c.id AND MUCode LIKE '2.%' GROUP BY rf_idCase HAVING COUNT(*)>1)
------------------------------------------------20170502---------------------------------------
INSERT #tError
select DISTINCT c.id,515
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile					
						inner join t_Case c on
				r.id=c.rf_idRecordCase
						INNER JOIN dbo.t_MES m ON
				c.id=m.rf_idCase
						INNER JOIN dbo.vw_sprMUDentalChecks md ON
				m.MES=md.MU
						INNER JOIN dbo.t_Meduslugi mm ON
				c.id=mm.rf_idCase						
WHERE md.IsCompletedCase=1 AND md.IsDentalMUCheck>0 AND NOT EXISTS(SELECT * 
																	FROM dbo.t_Meduslugi m INNER JOIN  OMS_NSI.dbo.sprDentalMU dm ON
																					m.MUSurgery=dm.code                                                                                               
																	WHERE m.rf_idCase=c.id AND dm.isVisit=1)
;WITH cteCompare
AS(
	select c.id as rf_idCase, COUNT(mm.rf_idCase) AS Quantity,md.quantityInVisitEqually, md.quantityInVisitLess, md.quantityInVisitMore, md.IsDentalMUCheck
	from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile					
							inner join t_Case c on
					r.id=c.rf_idRecordCase
							INNER JOIN dbo.t_MES m ON
					c.id=m.rf_idCase
							INNER JOIN dbo.vw_sprMUDentalChecks md ON
					m.MES=md.MU
							INNER JOIN dbo.t_Meduslugi mm ON
					c.id=mm.rf_idCase
							INNER JOIN OMS_NSI.dbo.sprDentalMU dm ON
					mm.MUSurgery=dm.code				                      
	WHERE dm.isVisit=1 AND md.IsCompletedCase=1 AND md.IsDentalMUCheck>0
	GROUP BY c.id, md.quantityInVisitEqually, md.quantityInVisitLess, md.quantityInVisitMore, md.IsDentalMUCheck
)
INSERT #tError
SELECT rf_idCase,515
FROM cteCompare 
WHERE (CASE WHEN IsDentalMUCheck=1 and Quantity<>quantityInVisitEqually THEN 9
			WHEN IsDentalMUCheck=2 and Quantity>=quantityInVisitLess THEN 9
			WHEN IsDentalMUCheck=3 and Quantity<=quantityInVisitMore THEN 9
			ELSE 0 END )=9

select DISTINCT c.id as rf_idCase, md.quantityInVisitEqually, md.quantityInVisitLess, md.quantityInVisitMore, md.IsDentalMUCheck
INTO #tmpMU
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile					
						inner join t_Case c on
				r.id=c.rf_idRecordCase
						INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase
						INNER JOIN dbo.vw_sprMUDentalChecks md ON
				m.MUCode=md.MU					
WHERE md.IsCompletedCase=0 AND md.IsDentalMUCheck>0

------------------------проверка на то что при определенных Кодах МУ должны быть определенные стомат.услуг-------------------------------------------
INSERT #tError
SELECT DISTINCT cc.rf_idCase,515
FROM #tmpMU cc 
WHERE  NOT EXISTS(SELECT * 
				  FROM dbo.t_Meduslugi m INNER JOIN  OMS_NSI.dbo.sprDentalMU dm ON
				  				m.MUSurgery=dm.code                                                                                               
				  WHERE m.rf_idCase=cc.rf_idCase AND dm.isVisit=1)
								 
;WITH cteCompareMU AS
(
	SELECT cc.rf_idCase,COUNT(m.rf_idCase) AS Quantity,cc.quantityInVisitEqually,cc.quantityInVisitLess, cc.quantityInVisitMore, cc.IsDentalMUCheck
	FROM #tmpMU cc INNER JOIN dbo.t_Meduslugi m ON
		  		 cc.rf_idCase=m.rf_idCase
						INNER JOIN OMS_NSI.dbo.sprDentalMU dm ON
					m.MUSurgery=dm.code
	WHERE dm.isVisit=1
	GROUP BY cc.rf_idCase,cc.quantityInVisitEqually,cc.quantityInVisitLess, cc.quantityInVisitMore, cc.IsDentalMUCheck
)
INSERT #tError
SELECT rf_idCase,515
FROM cteCompareMU
WHERE (CASE WHEN IsDentalMUCheck=1 and Quantity<>quantityInVisitEqually THEN 9
			WHEN IsDentalMUCheck=2 and Quantity>=quantityInVisitLess THEN 9
			WHEN IsDentalMUCheck=3 and Quantity<=quantityInVisitMore THEN 9
			ELSE 0 END )=9


DROP TABLE #tmpMU
