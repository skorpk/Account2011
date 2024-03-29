USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test522]    Script Date: 14.05.2018 9:03:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  StoredProcedure [dbo].[usp_Test531]    Script Date: 25.01.2017 14:45:19 ******/

ALTER PROC [dbo].[usp_Test522]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

insert #tError
select DISTINCT c.id,522
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase				
			  inner join t_Case c on
		r.id=c.rf_idRecordCase				  		
where a.rf_idFiles=@idFile AND c.rf_idV008=32 AND 
	NOT EXISTS(SELECT * FROM dbo.t_SlipOfPaper s WHERE rf_idCase=c.id AND s.DateHospitalization IS NOT NULL AND s.GetDatePaper IS NOT NULL AND s.NumberTicket IS NOT NULL)
