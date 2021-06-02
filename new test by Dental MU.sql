USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM ='255315' and ReportYear=2017 AND NumberRegister=977

select * from vw_getIdFileNumber where id=@idFile

--SET @idFile=105765

declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
--устанавливаем дату начала и дату окончания отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	

------------------------проверка на то что при определенных Кодах ЗС должны быть определенные стомат.услуг-------------------------------------------
--INSERT #tError
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
--INSERT #tError
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
--INSERT #tError
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
--INSERT #tError
SELECT rf_idCase,515
FROM cteCompareMU
WHERE (CASE WHEN IsDentalMUCheck=1 and Quantity<>quantityInVisitEqually THEN 9
			WHEN IsDentalMUCheck=2 and Quantity>=quantityInVisitLess THEN 9
			WHEN IsDentalMUCheck=3 and Quantity<=quantityInVisitMore THEN 9
			ELSE 0 END )=9


DROP TABLE #tmpMU
