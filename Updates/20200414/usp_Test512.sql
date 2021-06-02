USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test512]    Script Date: 14.04.2020 15:03:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test512]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--512
--02.08.2016
insert #tError 
select c.id,512
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase						
WHERE m.MUSurgery IS NOT NULL AND NOT EXISTS(SELECT * FROM vw_sprV001_DentalMU WHERE IDRB=m.MUSurgery COLLATE Latin1_General_BIN)

--Если значение не совпадает со значением в теге CODE_USL или не соответствует номенклатуре медицинских услуг (V001)
insert #tError 
select c.id,512
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013
			AND a.ReportYear<2019
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
						INNER JOIN vw_sprV001_DentalMU v ON
			m.MUSurgery=v.IDRB
WHERE m.MUSurgery IS NOT NULL AND m.MUSurgery<>m.MUCode	

insert #tError 
select c.id,512
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
WHERE m.MUSurgery IS NOT NULL AND NOT EXISTS(SELECT 1 FROM vw_sprV001_DentalMU v WHERE v.IDRB=m.MUSurgery)
--не ввели в действие т.к. вылетает весь диализ
INSERT #tError
select DISTINCT c.id,512
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2018
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase						                
WHERE m.MUSurgery IS NOT NULL AND m.MUCode<>m.MUSurgery AND NOT EXISTS(SELECT 1 FROM dbo.vw_sprMU mm WHERE m.MUSurgery=mm.NomenclMUCode  AND m.MUCode=mm.MU)
--2020-04-14 Для услуг из V001 c установленным соответствием услугам из территориального справочника медуслуг в теге VID_VME 
--указывается код услуги из Номенклатуры, а в поле CODE_USL указывается соответствующий код из территориального справочника медуслуг.
INSERT #tError
select DISTINCT c.id,512
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2018
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase				
						INNER JOIN dbo.vw_sprMU mm ON
			m.MUSurgery=mm.NomenclMUCode		                
WHERE m.MUSurgery IS NOT NULL AND m.MUCode=m.MUSurgery AND EXISTS(SELECT 1 FROM dbo.vw_sprMU mm1 WHERE m.MUSurgery=mm1.NomenclMUCode  AND m.MUCode<>mm1.MU) 
