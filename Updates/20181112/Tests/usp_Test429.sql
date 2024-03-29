USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test429]    Script Date: 05.01.2019 10:12:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test429]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
insert #tError
SELECT DISTINCT c.id,429
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'
		AND c.DateEnd<'20190101'
		 	  INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
			  INNER JOIN dbo.vw_sprMKB10 m ON
		d.DS1=m.DiagnosisCode					
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase   		
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprN004 WHERE ( DS_N=m.DiagnosisCode OR DS_N=m.MainDS OR ISNULL(DS_N,m.MainDS)=m.MainDS) AND ID_N=sl.rf_idN004)
/*
Если DS1_T=0 and Age >17, то значение должно присутствовать обязательно и соответствовать справочнику N004 (выбираются только действующие на DATE_Z_2 записи).
Для установления факта соответствия необходимо сначала отфильтровать записи в N004 по условию DS_N=DS1, и если выборка не пуста, значение тега ONK_N должно соответствовать  
значению поля ID_N  одной из отфильтрованных записей. Если выборка пуста, то отбор проводится по условию: DS_N=LEFT(DS1;3), и если выборка не пуста, 
то значение тега ONK_N должно соответствовать  значению поля ID_N  одной из отфильтрованных записей. Если в справочнике отсутствуют записи, удовлетворяющие фильтру DS_N=LEFT(DS1;3), 
то соответствие проверяется на множестве записей, для которых DS_N is null
*/

insert #tError
SELECT DISTINCT c.id,429
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'
			  INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase 
		 	  INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
			  INNER JOIN dbo.vw_sprMKB10 m ON
		d.DS1=m.DiagnosisCode					
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase   		
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.DS1_T=0 AND c.Age>17
AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprN004 WHERE ( DS_N=m.DiagnosisCode OR DS_N=m.MainDS OR ISNULL(DS_N,m.MainDS)=m.MainDS) AND ID_N=sl.rf_idN004 AND DATEBEG<=cc.DateEnd AND cc.DateEnd<=DATEEND) 
GO

