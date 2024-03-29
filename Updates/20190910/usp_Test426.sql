USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test426]    Script Date: 10.09.2019 14:30:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test426]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

insert #tError
SELECT DISTINCT c.id,426
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
				INNER JOIN dbo.t_Consultation sl ON
		c.id=sl.rf_idCase 
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprn019 WHERE id_cons=sl.PR_CONS AND DATEBEG<=cc.DateEnd AND DATEEND>=cc.DateEnd)
--Тег CONS присутствует обязательно, если DS_ONK=1 или установлен диагноз ЗНО(DS1 like C% or DS1 like D0% or «Нейтропения»).
SELECT DiagnosisCode INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%' OR MainDS LIKE 'D0%' 
SELECT DiagnosisCode into #tDiag2 FROM vw_sprMKB10 WHERE MainDS >'C80' AND MainDS<'C97'

insert #tError
SELECT DISTINCT c.id,426
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase		
			INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase 
			INNER JOIN #tDiag dd ON
		d.DS1=dd.DiagnosisCode         
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT 1 FROM dbo.t_Consultation WHERE c.id=rf_idCase)

insert #tError
SELECT DISTINCT c.id,426
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase					
			INNER JOIN t_DS_ONK_REAB dd ON
		c.id=dd.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND dd.DS_ONK=1 AND NOT EXISTS(SELECT 1 FROM dbo.t_Consultation WHERE c.id=rf_idCase)

INSERT #tError
SELECT DISTINCT c.id,426
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase		
			INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase 
			INNER JOIN #tDiag dd ON
		d.DS2=dd.DiagnosisCode  			
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND d.DS1='D70' AND NOT EXISTS(SELECT 1 FROM dbo.t_Consultation WHERE c.id=rf_idCase)
		AND NOT EXISTS(SELECT 1 FROM #tDiag2 WHERE DiagnosisCode=d.DS2)


--Если PR_CONS in (1,2,3), то значение DT_CONS должно присутствовать обязательно
insert #tError
SELECT DISTINCT c.id,426
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'					
				INNER JOIN dbo.t_Consultation sl ON
		c.id=sl.rf_idCase              				
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.PR_CONS IN(1,2,3) AND sl.DateCons IS NULL

--если PR_CONS in (0,4), то DT_CONS должно отсутствовать
insert #tError
SELECT DISTINCT c.id,426
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'					
				INNER JOIN dbo.t_Consultation sl ON
		c.id=sl.rf_idCase              				
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.PR_CONS IN(0,4) AND sl.DateCons IS NOT NULL

--Если DT_CONS присутствует, то должно принадлежать либо текущему году, либо предыдущему году
DECLARE @dtStart DATE,
		@dtEnd DATE
SELECT @dtStart=CAST(@year-1 AS CHAR(4))+'0101', @dtEnd=CAST(@year+1 AS CHAR(4))+'0101'
        
insert #tError
SELECT DISTINCT c.id,426
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'					
				INNER JOIN dbo.t_Consultation sl ON
		c.id=sl.rf_idCase              				
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.DateCons IS NOT NULL AND sl.DateCons<@dtStart AND sl.DateCons>@dtEnd

--DT_CONS должна быть меньше или ровна дате окончания случая        
insert #tError
SELECT DISTINCT c.id,426
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'					
				INNER JOIN dbo.t_Consultation sl ON
		c.id=sl.rf_idCase              				
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.DateCons IS NOT NULL AND sl.DateCons>c.DateEnd

--insert #tError
--SELECT DISTINCT c.id,426
--from t_File f INNER JOIN t_RegistersCase a ON
--		f.id=a.rf_idFiles
--		AND a.ReportMonth=@month
--		AND a.ReportYear=@year
--			  inner join t_RecordCase r on
--		a.id=r.rf_idRegistersCase
--			  inner join t_Case c on
--		r.id=c.rf_idRecordCase						
--		AND c.DateEnd>='20180901'					
--				INNER JOIN dbo.t_ONK_SL sl ON
--		c.id=sl.rf_idCase              
--where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.DateConsultation IS NOT NULL AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprn019 WHERE id_cons=sl.ConsultationInfo)

