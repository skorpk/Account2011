USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test512]    Script Date: 05.01.2019 10:58:42 ******/
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
WHERE m.MUSurgery IS NOT NULL AND NOT EXISTS(SELECT * FROM vw_sprV001_DentalMU WHERE IDRB=m.MUSurgery)

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
--Если в качестве значения указан код из номенклатуры медицинских услуг (V001), то проверяется наличие тега VID_VME  и его значение должно быть непустым.
--insert #tError 
--select c.id,512
--from t_RegistersCase a inner join t_RecordCase r on
--			a.id=r.rf_idRegistersCase
--			and a.rf_idFiles=@idFile
--			AND a.ReportYear>2013------------------обязательное условие	
--						INNER JOIN dbo.t_Case c ON
--			r.id=c.rf_idRecordCase
--						INNER JOIN dbo.t_Meduslugi m ON
--			c.id=m.rf_idCase
--						INNER JOIN vw_sprV001_DentalMU v ON
--			m.MUCode=v.IDRB
--WHERE ISNULL(m.MUSurgery,'bla-bla')<>m.MUCode	
go