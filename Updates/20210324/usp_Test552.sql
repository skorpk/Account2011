USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test552]    Script Date: 24.03.2021 8:07:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test552]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
DECLARE @typeFile CHAR(1)

SELECT @typeFile =UPPER(TypeFile) from dbo.t_File WHERE id=@idFile
--DS0 DS2   DS3
insert #tError
select distinct c.id,552 as Error
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join dbo.t_Diagnosis d on
			c.id=d.rf_idCase									
where a.rf_idFiles=@idFile AND NOT EXISTS(SELECT * FROM dbo.vw_sprMKB10 WHERE DiagnosisCode=ISNULL(d.DiagnosisCode,'bla-bla'))

insert #tError
select distinct c.id,552 as Error
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join dbo.t_DS2_Info d on
			c.id=d.rf_idCase									
where a.rf_idFiles=@idFile AND NOT EXISTS(SELECT * FROM dbo.vw_sprMKB10 WHERE DiagnosisCode=ISNULL(d.DiagnosisCode,'bla-bla'))

-------12.03.2021---------------
insert #tError
select distinct c.id,552
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase
								JOIN dbo.t_CompletedCase cc ON
                    cc.rf_idRecordCase = r.id
								inner join (SELECT DISTINCT rf_idCase,DiagnosisCode AS DS1 FROM dbo.t_Diagnosis 
											UNION ALL
											SELECT DISTINCT rf_idCase,DiagnosisCode AS DS1 FROM dbo.t_DS2_Info )  d on
					c.id=d.rf_idCase					
where a.rf_idFiles=@idFile and NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprMKBPeriod mkb WHERE mkb.DiagnosisCode=d.DS1 and cc.DateEnd>=mkb.DateBeg AND cc.DateEnd<=mkb.DateEnd)

insert #tError
select distinct c.id,552
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase
								inner join (SELECT DISTINCT rf_idCase,DiagnosisCode AS DS1 FROM dbo.t_Diagnosis 
											UNION ALL
											SELECT DISTINCT rf_idCase,DiagnosisCode AS DS1 FROM dbo.t_DS2_Info ) d on
					c.id=d.rf_idCase
								INNER JOIN dbo.vw_RegisterPatient p ON
				p.rf_idFiles=@idFile
				and r.id=p.rf_idRecordCase					
where a.rf_idFiles=@idFile AND NOT EXISTS(SELECT 1 FROM oms_NSI.dbo.sprMKB mkb WHERE d.DS1=(mkb.DiagnosisCode) AND p.rf_idV005=ISNULL(mkb.Sex,p.rf_idV005) )