USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test505]    Script Date: 19.04.2021 9:30:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test505]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	
---	сверка основного DS,PROFIL,PRVS в случаях и медуслугах для IDSP=33 and 43
--06.02.2015
INSERT #tError
select c.id,505
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile 					
								inner join t_Case c on
					r.id=c.rf_idRecordCase	
					AND c.DateEnd>=@dateStart AND c.DateEnd<@dateEnd
					AND c.DateEnd<'20190101'													
								INNER JOIN dbo.t_Diagnosis d ON
					c.id=d.rf_idCase
					AND d.TypeDiagnosis=1
								INNER JOIN (VALUES (33),(43)) v010(id) ON
					c.rf_idV010=v010.id	
WHERE c.rf_idV002<>158 AND NOT EXISTS(SELECT * FROM dbo.t_Meduslugi mu WHERE mu.rf_idCase=c.id AND mu.DiagnosisCode=d.DiagnosisCode
																			AND mu.rf_idV002=c.rf_idV002 AND mu.rf_idV004=c.rf_idV004)

SELECT mu, 31 AS VIDPOM INTO #tMU FROM dbo.vw_sprMU WHERE MUGroupCode=60 AND MUUnGroupCode IN(3,10)

INSERT #tError
select c.id,505
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile 					
								inner join t_Case c on
					r.id=c.rf_idRecordCase	
					AND c.DateEnd>=@dateStart AND c.DateEnd<@dateEnd
					AND c.DateEnd>='20190101'													
								INNER JOIN dbo.t_Diagnosis d ON
					c.id=d.rf_idCase
					AND d.TypeDiagnosis=1
					           INNER JOIN dbo.t_Meduslugi m ON
					c.id=m.rf_idCase                             
WHERE c.rf_idV002<>158 AND c.rf_idV010=33 AND c.rf_idV006=1 AND c.rf_idV008=31 AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi mu WHERE mu.rf_idCase=c.id AND mu.DiagnosisCode=d.DiagnosisCode AND mu.rf_idV002=c.rf_idV002 AND mu.rf_idV004=c.rf_idV004)
		AND NOT EXISTS(SELECT * FROM #tMU WHERE MUCode=m.MUCode)

INSERT #tError
select c.id,505
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile 					
								inner join t_Case c on
					r.id=c.rf_idRecordCase	
					AND c.DateEnd>=@dateStart AND c.DateEnd<@dateEnd
					AND c.DateEnd>='20190101'													
								INNER JOIN dbo.t_Diagnosis d ON
					c.id=d.rf_idCase
					AND d.TypeDiagnosis=1
					           INNER JOIN dbo.t_Meduslugi m ON
					c.id=m.rf_idCase                             
WHERE c.rf_idV002<>158 AND c.rf_idV010 IN(43,33) AND c.rf_idV006=2 AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi mu WHERE mu.rf_idCase=c.id AND mu.DiagnosisCode=d.DiagnosisCode AND mu.rf_idV002=c.rf_idV002 AND mu.rf_idV004=c.rf_idV004)
		AND NOT EXISTS(SELECT * FROM #tMU WHERE MUCode=m.MUCode)
/*
если VIDPOM=32 и IDSP=32, то проводится проверка корректности оформления случая оказания медицинской помощи, 
оплачиваемого по законченному случаю. А именно, значения в тегах DS1, PROFIL, PRVS, 
представленные в разделе «Сведения о случае» (составной тег SLUCH) должны быть соответственно равны значениям в тегах DS, PROFIL, PRVS, 
представленным хотя бы в одном из разделов «Сведения об услуге» (составной тег USL),  
вне зависимости представлены в составном теге USL сведения о койко-днях с кодом 1.11.* или сведения о проведенных оперативных вмешательствах.
*/																			
INSERT #tError
select c.id,505
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile 								
								inner join t_Case c on
					r.id=c.rf_idRecordCase	
					AND c.DateEnd>=@dateStart AND c.DateEnd<@dateEnd	
					AND c.DateEnd<'20190101'												
								INNER JOIN dbo.t_Diagnosis d ON
					c.id=d.rf_idCase
					AND d.TypeDiagnosis=1
WHERE c.rf_idV010=32 AND c.rf_idV006=1 AND c.rf_idV002<>158 AND EXISTS(SELECT * FROM dbo.t_Meduslugi m LEFT JOIN oms_nsi.dbo.V001 v ON m.MUCode=v.IDRB
														WHERE v.IDRB IS null AND m.rf_idCase=c.id AND MUCode<>'1.11.1')		
