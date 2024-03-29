USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test566]    Script Date: 25.12.2018 16:22:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test566]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

---------------------------------------------------------------------------
--с 2019 года новая единая проверка суммы случая
;WITH cteSUM
AS(
SELECT c.id  AS rf_idCase,c.AmountPayment, 
	CASE WHEN c.IT_SL IS not NULL or k.ValueKiro IS NOT NULL THEN CAST(CAST(mes.Tariff* ISNULL(c.IT_SL,1) AS DECIMAL(15,0) )*ISNULL(k.ValueKiro ,1) AS DECIMAL(15,0))+SUM(m.TotalPrice)
		ELSE mes.tariff+SUM(m.TotalPrice) END AS SUM_M
from dbo.t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
				inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						inner join t_MES mes on
			c.id=mes.rf_idCase
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase              			        
					LEFT JOIN dbo.t_Kiro k ON
			c.id=k.rf_idCase   
WHERE f.TypeFile='H'
GROUP BY c.id,c.AmountPayment,mes.Tariff, c.IT_SL,k.ValueKiro,CAST(CAST(mes.Tariff* ISNULL(c.IT_SL,1) AS DECIMAL(15,0) )*ISNULL(k.ValueKiro ,1) AS DECIMAL(15,0))
UNION ALL
SELECT c.id  AS rf_idCase,c.AmountPayment,SUM(m.TotalPrice) AS SUM_M
from dbo.t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
				 inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase              			        					 
WHERE c.IsCompletedCase=0 AND f.TypeFile='H'
GROUP BY c.id,c.AmountPayment
)
insert #tError
select c.rf_idCase,566 
FROM cteSUM c
WHERE c.AmountPayment<>SUM_M 

insert #tError
SELECT DISTINCT c.id,566
FROM dbo.t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
				inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase							
						inner join t_MES mes on
			c.id=mes.rf_idCase
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase              			        
WHERE m.TotalPrice<>0.0 AND mes.Tariff<>0.0 AND mes.MES IS NULL AND f.TypeFile='H'

insert #tError
SELECT DISTINCT c.id,566
from dbo.t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
				inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase							
						inner join t_MES mes on
			c.id=mes.rf_idCase
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase              			        
WHERE m.TotalPrice<>0.0 AND mes.Tariff<>0.0 AND mes.MES IS NOT NULL AND m.MUCode NOT LIKE '60.3.%' AND f.TypeFile='H'  


insert #tError
SELECT DISTINCT c.id,566
from dbo.t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
				 inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						inner join t_MES mes on
			c.id=mes.rf_idCase
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase              			        
WHERE m.MUCode LIKE '60.3.%' AND m.TotalPrice=0 AND f.TypeFile='H'
GO
					
					