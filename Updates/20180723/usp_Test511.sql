USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test511]    Script Date: 23.07.2018 10:42:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test511]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--511
--Если поля заполнены, то проводится проверка возраста пациента: на дату начала лечения пациент должен быть старше 1 года
insert #tError 
select c.id,511
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013------------------обязательное условие	
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCase
						INNER JOIN t_RefRegisterPatientRecordCase r1 ON
			r.id=r1.rf_idRecordCase
						INNER JOIN dbo.t_RegisterPatient p ON
			r1.rf_idRegisterPatient=p.id
						INNER JOIN dbo.t_BirthWeight w ON
			c.id=w.rf_idCase
where c.Age<12--DATEDIFF(Year,c.DateBegin,p.BirthDay)>1
