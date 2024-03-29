USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test531]    Script Date: 26.01.2017 8:50:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test531]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--PR_NOV
insert #tError
select distinct c.id,531
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase								
where a.rf_idFiles=@idFile and r.IsNew>1
----------------------для записей с признаком 0-------------------------
insert #tError
select distinct c.id,531
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase																
where a.rf_idFiles=@idFile and r.IsNew=0 AND EXISTS(SELECT * FROM dbo.vw_CaseTypePay WHERE GUID_Case=c.GUID_Case AND TypePay=1)

insert #tError
select distinct c.id,531
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase																
where a.rf_idFiles=@idFile and r.IsNew=0 AND EXISTS(SELECT * FROM dbo.t_RecordCaseBack WHERE rf_idCase=c.id)

----------------------для записей с признаком 1-------------------------
insert #tError
select distinct c.id,531
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase																
where a.rf_idFiles=@idFile and r.IsNew=1 AND NOT EXISTS(SELECT * FROM dbo.vw_CaseTypePay WHERE GUID_Case=c.GUID_Case AND TypePay=1)
go

