USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test417]    Script Date: 02.07.2018 9:53:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROC dbo.usp_Test418
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
SELECT MU 
INTO #tMU
FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam IN('O','R','F','V','U')

insert #tError
SELECT DISTINCT c.id,418
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180701'	
			 INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
						INNER JOIN #tMU l ON
			m.MUCode=l.MU		  			
where a.rf_idFiles=@idFile AND f.TypeFile='H'

insert #tError
SELECT DISTINCT c.id,418
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180701'	
			 INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
						INNER JOIN #tMU l ON
			m.MES=l.MU		  			
where a.rf_idFiles=@idFile AND f.TypeFile='H'

DROP TABLE #tMU
go