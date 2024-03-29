USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test574]    Script Date: 01.04.2021 10:55:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test574]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--DS
insert #tError
select distinct c.id,574
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join t_Meduslugi m on
			c.id=m.rf_idCase								
						left join oms_NSI.dbo.sprMKB mkb on
			m.DiagnosisCode=mkb.DiagnosisCode
where a.rf_idFiles=@idFile and mkb.DiagnosisCode is null


insert #tError
select distinct c.id,574
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						JOIN dbo.t_CompletedCase cc ON
                    cc.rf_idRecordCase = r.id
						inner join t_Meduslugi m on
			c.id=m.rf_idCase								
where a.rf_idFiles=@idFile and NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprMKBPeriod mkb WHERE mkb.DiagnosisCode=m.DiagnosisCode and cc.DateEnd>=mkb.DateBeg AND cc.DateEnd<=mkb.DateEnd)