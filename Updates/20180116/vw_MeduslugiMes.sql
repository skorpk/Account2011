USE [RegisterCases]
GO

/****** Object:  View [dbo].[vw_MeduslugiMes]    Script Date: 16.01.2018 8:12:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER view [dbo].[vw_MeduslugiMes]
as
select m.*
from (
select m.id,m.rf_idCase,m.MUCode,m.IsChildTariff,m.Quantity,m.Price, 0 AS MUType from t_Meduslugi m
union all
select distinct c.id,mes.rf_idCase,mes.MES as MUCode,c.IsChildTariff,mes.Quantity,mes.Tariff, 1 AS MUType 
from t_MES mes inner join t_Case c on
		mes.rf_idCase=c.id
	) m left join vw_sprV001_DentalMU v001 on
	m.MUCode=v001.IDRB
where v001.IDRB is null
GO
GRANT SELECT ON vw_MeduslugiMes TO db_RegisterCase
