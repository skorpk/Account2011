USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test405]    Script Date: 04.01.2019 14:52:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test405]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
insert #tError
select DISTINCT c.id,405
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase	
		AND c.DateEnd<'20190101'
				INNER JOIN dbo.t_AdditionalCriterion ac ON
		c.id=ac.rf_idCase						
where a.rf_idFiles=@idFile AND ac.rf_idAddCretiria IS NOT NULL AND c.rf_idV006 >2

insert #tError
select DISTINCT c.id,405
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase	
		AND c.DateEnd<'20190101'
				INNER JOIN dbo.t_AdditionalCriterion ac ON
		c.id=ac.rf_idCase	
where a.rf_idFiles=@idFile AND ac.rf_idAddCretiria IS NOT NULL AND NOT EXISTS(SELECT * FROM dbo.vw_sprAddCriterion WHERE code=ac.rf_idAddCretiria) 							

/*
Если присутствует, то N_KSG не пусто. Значение должно соответствовать V024 (выбираются только действующие на DATE_Z_2 записи).

*/
insert #tError
select DISTINCT c.id,405
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase	
		AND c.DateEnd>='20190101'
				INNER JOIN dbo.t_AdditionalCriterion ac ON
		c.id=ac.rf_idCase	
where a.rf_idFiles=@idFile AND ac.rf_idAddCretiria IS NOT NULL AND NOT EXISTS(SELECT 1 FROM t_mes WHERE rf_idCase=c.id AND IsCSGTag=2)

insert #tError
select DISTINCT c.id,405
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase	
			INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase	          
				INNER JOIN dbo.t_AdditionalCriterion ac ON
		c.id=ac.rf_idCase	
where a.rf_idFiles=@idFile AND ac.rf_idAddCretiria IS NOT NULL AND NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprV024 WHERE IDDKK=ac.rf_idAddCretiria and  DATEBEG<=cc.DateEnd AND DATEEND>=cc.DateEnd)
/*
Если CRIT like ‘FR%’ or like 'fr%', то ONK_SL/K_FR >=0 (not is null), и в SL, в котором  CRIT like ‘FR%’ or like 'fr%' существует тег ONK_USL, для которого USL_TIP in (3,4).
*/
insert #tError
select DISTINCT c.id,405
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase	
			INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase	          
				INNER JOIN dbo.t_AdditionalCriterion ac ON
		c.id=ac.rf_idCase	
where a.rf_idFiles=@idFile AND ac.rf_idAddCretiria LIKE 'FR%' AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_SL WHERE rf_idCase=c.id AND ISNULL(K_FR,0)>0)

insert #tError
select DISTINCT c.id,405
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase	
			INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase	          
				INNER JOIN dbo.t_AdditionalCriterion ac ON
		c.id=ac.rf_idCase	
where a.rf_idFiles=@idFile AND ac.rf_idAddCretiria LIKE 'FR%' AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_USL WHERE rf_idCase=c.id AND rf_idN013 IN(3,4))