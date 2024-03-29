USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test507]    Script Date: 23.07.2018 10:30:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test507]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
		
----17.01.2014 Новые проверки
--Если поле заполнено, то проверяется возраст пациента: на дату начала лечения пациенту должно быть не более 60 дней
--указываю 61 день так как полных дней становиться на следующий день
insert #tError 
select c.id,507
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
where r.BirthWeight IS NOT NULL AND DATEDIFF(dd,c.DateBegin,p.BirthDay)>61
