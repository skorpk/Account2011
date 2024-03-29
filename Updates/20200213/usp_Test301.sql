USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test301]    Script Date: 20.02.2020 13:54:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test301]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

insert #tError
SELECT DISTINCT c.id,301
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20200101'						
			INNER JOIN dbo.t_Diagnosis d ON
		c.id=d.rf_idCase	 			
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.rf_idV006=1 AND d.DiagnosisGroup ='P07' AND c.Age<1 AND r.BirthWeight IS null

