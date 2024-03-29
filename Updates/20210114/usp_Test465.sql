USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test465]    Script Date: 26.01.2021 8:03:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test465]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
INSERT #tError 
SELECT c.id,465
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase
		AND c.DateEnd>='20190101'	
		AND c.DateEnd<'20210101'				
				INNER JOIN dbo.vw_CoefficientAvr cf ON
		c.id=cf.rf_idCase								
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.IT_SL<>cf.AvrValc AND cf.CountIT_SL>1
----------------------------------------------------------
INSERT #tError 
SELECT c.id,465
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase
		AND c.DateEnd>='20210101'				
				INNER JOIN dbo.vw_CoefficientAvr cf ON
		c.id=cf.rf_idCase								
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND (c.IT_SL<>1.8 AND cf.AvrValc>1.8)

INSERT #tError 
SELECT c.id,465
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase
		AND c.DateEnd>='20210101'				
				INNER JOIN dbo.vw_CoefficientAvr cf ON
		c.id=cf.rf_idCase								
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.IT_SL<>cf.AvrValc AND cf.AvrValc<=1.8
go
