USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test566]    Script Date: 16.01.2018 10:44:14 ******/
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
--SUMV
/*
Если применяется способ оплаты по законченному случаю, то 
SUMV=(TARIF*K1)*K2,  где
K1=1, если КСЛП не применяется,
K1=IT_SL, если КСЛП применяется, в этом случае проводится округление полученного результата  до десятых долей  по правилам математического округления.
K2=1, если КИРО не применялся,
K2=VAL_K, если КИРО применялся. В этом случае проводится округление результата до десятых долей по правилам математического округления
*/
insert #tError
select mes.rf_idCase,566
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
					inner join t_MES mes on
			c.id=mes.rf_idCase					           
					LEFT JOIN dbo.t_Kiro k ON
			c.id=k.rf_idCase                  
where mes.Tariff*CAST(ISNULL(IT_SL,1) AS DECIMAL(11,1))*CAST(ISNULL(k.ValueKiro,1) AS DECIMAL(11,1))<>c.AmountPayment 

insert #tError
select c.id,566
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase			
where c.IsCompletedCase=1 AND c.AmountPayment<=0

--insert #tError
--select c.id,566
--from t_RegistersCase a inner join t_RecordCase r on
--			a.id=r.rf_idRegistersCase
--			and a.rf_idFiles=@idFile
--						inner join t_Case c on
--			r.id=c.rf_idRecordCase	
--					inner join t_MES mes on
--			c.id=mes.rf_idCase
--where cast((mes.Tariff*c.IT_SL) AS DECIMAL(15,1))<>c.AmountPayment AND c.IT_SL IS NOT NULL

--если применен способ оплаты, отличный от способа оплаты по законченному случаю, то значение должно быть равно сумме стоимостей всех услуг
--(стоимость услуг равна произведению количества услуг на тариф одной услуги) и должна быть больше 0
insert #tError
select c.id,566
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			AND c.IsCompletedCase=0
						left join dbo.t_Meduslugi m on
			c.id=m.rf_idCase
where a.rf_idFiles=@idFile
group by c.id,c.AmountPayment
having c.AmountPayment<>ISNULL(cast(SUM(m.Quantity*m.Price) as decimal(15,2)),0) 

insert #tError
select c.id,566
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase
where a.rf_idFiles=@idFile AND c.AmountPayment<=0 AND c.rf_idV006<>4
---------------------------------------------------------------------------
