USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test553]    Script Date: 12.03.2021 9:33:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test553]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--DS01
--Сверка на справочник. 
insert #tError
select distinct c.id,553
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase
								inner join (SELECT DISTINCT rf_idCase,DiagnosisCode AS DS1 FROM dbo.t_Diagnosis WHERE TypeDiagnosis=1) d on
					c.id=d.rf_idCase
								INNER JOIN dbo.vw_RegisterPatient p ON
				p.rf_idFiles=@idFile
				and r.id=p.rf_idRecordCase
								left join oms_NSI.dbo.sprMKB mkb on
					d.DS1=(mkb.DiagnosisCode)
					AND p.rf_idV005=ISNULL(mkb.Sex,p.rf_idV005)
where a.rf_idFiles=@idFile and mkb.DiagnosisCode is null
--на соответствие диагноза из ОМС
insert #tError
select distinct c.id,553
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase
								inner join (SELECT DISTINCT rf_idCase,DiagnosisCode AS DS1 FROM dbo.t_Diagnosis WHERE TypeDiagnosis=1) d on
					c.id=d.rf_idCase
								left join vw_sprMKB10InOMS mkb on
					d.DS1=(mkb.DiagnosisCode)
					and c.DateEnd>=mkb.DateBeg
					and c.DateEnd<=mkb.DateEnd
where a.rf_idFiles=@idFile and mkb.DiagnosisCode is null
--на соответствие диагноза из ОМС
insert #tError
select distinct c.id,553
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase
								JOIN dbo.t_CompletedCase cc ON
                        cc.rf_idRecordCase = r.id
								inner join (SELECT DISTINCT rf_idCase,DiagnosisCode AS DS1 FROM dbo.t_Diagnosis WHERE TypeDiagnosis=1) d on
					c.id=d.rf_idCase					
where a.rf_idFiles=@idFile and NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprMKBPeriod mkb WHERE mkb.DiagnosisCode=d.DS1 and cc.DateEnd>=mkb.DateBeg AND cc.DateEnd<=mkb.DateEnd)
GO
