USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test518]    Script Date: 26.01.2017 16:28:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test518]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
INSERT #tError
select c.id,518
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>'20160430'
						INNER JOIN vw_CSLP_Coefficient co ON
			c.id=co.rf_idCase
WHERE c.IT_SL<>co.Sum_CSLP

--error 518
insert #tError
select DISTINCT c.id,518
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>'20160430'
						INNER JOIN dbo.t_Coefficient co ON
			c.id=co.rf_idCase
WHERE NOT EXISTS(SELECT * FROM oms_nsi.dbo.tSLP WHERE code=co.Code_SL)			                      

insert #tError
select DISTINCT c.id,518
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>'20160430'
						INNER JOIN dbo.t_Coefficient co ON
			c.id=co.rf_idCase
						INNER JOIN (VALUES(1,0,4),(2,74,120)) v(code,ageStart, ageEnd) ON
			co.Code_SL=v.code
			AND c.age<=v.AgeStart
			AND c.age>=v.AgeEnd			                      

insert #tError
select DISTINCT c.id,518
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>'20160430'
						INNER JOIN dbo.t_Coefficient co ON
			c.id=co.rf_idCase
WHERE NOT EXISTS(SELECT * FROM dbo.VW_sprCoefficient WHERE code=co.Code_SL AND coefficient=co.Coefficient AND c.DateEnd>=dateBeg AND c.DateEnd<=dateEnd)			                      
--В справочник КСГ 2017 введено новое поле noKSLP. Если для КСГ noKSLP=1, то КСЛП не может быть применен. 
insert #tError
select DISTINCT c.id,518
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>'20160430'
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase                      
						INNER JOIN dbo.t_Coefficient co ON
			c.id=co.rf_idCase
WHERE EXISTS(SELECT * FROM dbo.vw_sprCSG WHERE code=m.MES AND noKSLP=1 AND c.DateEnd>=dateBeg AND c.DateEnd<=dateEnd)
go

