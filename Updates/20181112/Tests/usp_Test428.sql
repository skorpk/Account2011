USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test428]    Script Date: 05.01.2019 10:08:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test428]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
---1 test
insert #tError
SELECT DISTINCT c.id,428
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
where a.rf_idFiles=@idFile AND f.TypeFile='H' 
AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprN003 WHERE (DS_T=m.DiagnosisCode OR DS_T=m.MainDS OR ISNULL(DS_t,m.MainDS)=m.MainDS) AND ID_T=sl.rf_idN003)

/*
Если DS1_T=0 and Age >17, то значение должно присутствовать обязательно и соответствовать справочнику N003(выбираются только действующие на DATE_Z_2 записи). 
Для установления факта соответствия необходимо сначала отфильтровать записи в N003 по условию DS_T=DS1, и если выборка не пуста, значение тега ONK_T должно соответствовать
значению поля ID_T  одной из отфильтрованных записей. Если выборка пуста, то отбор проводится по условию: DS_T=LEFT(DS1;3), значение тега ONK_T должно соответствовать  
значению поля ID_T  одной из отфильтрованных записей. Если выборка пуста, то соответствие проверяется на множестве записей, для которых DS_T is null.
*/
insert #tError
SELECT DISTINCT c.id,428
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
AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprN003 WHERE (DS_T=m.DiagnosisCode OR DS_T=m.MainDS OR ISNULL(DS_t,m.MainDS)=m.MainDS) AND ID_T=sl.rf_idN003 AND DATEBEG<=cc.DateEnd AND cc.DateEnd<=DATEEND) 
