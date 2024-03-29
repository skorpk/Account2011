USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test407]    Script Date: 24.01.2018 19:35:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test407]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
INSERT #tError
select DISTINCT c.id,407
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180101'
where a.rf_idFiles=@idFile AND c.rf_idSubMO IS NOT NULL AND NOT EXISTS(SELECT 1 FROM dbo.vw_sprMOMP_OMP v WHERE c.rf_idMO=v.CodeM AND c.rf_idV006=ISNULL(v.UslOk,c.rf_idV006) 
				AND c.DateEnd>=ISNULL(v.PlaceDateB,c.DateEnd) AND c.DateEnd<=ISNULL(v.PlaceDateE,c.DateEnd) AND c.DateEnd>=ISNULL(v.DeptDateB,c.DateEnd)
				AND c.DateEnd<=ISNULL(v.DeptDateE,c.DateEnd) )

insert #tError
select DISTINCT c.id,407
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180101'
		INNER JOIN 	vw_sprMOMP_OMP v ON
		c.rf_idMO=v.CodeM 
		AND c.rf_idV006=ISNULL(v.UslOk,c.rf_idV006) 
		AND c.DateEnd>=ISNULL(v.PlaceDateB,c.DateEnd) 
		AND c.DateEnd<=ISNULL(v.PlaceDateE,c.DateEnd) 
		AND c.DateEnd>=ISNULL(v.DeptDateB,c.DateEnd)
		AND c.DateEnd<=ISNULL(v.DeptDateE,c.DateEnd)
where a.rf_idFiles=@idFile AND NOT EXISTS(SELECT 1 FROM dbo.vw_sprMOMP_OMP v WHERE c.rf_idMO=v.CodeM AND c.rf_idV006=ISNULL(v.UslOk,c.rf_idV006) 
				AND c.DateEnd>=ISNULL(v.PlaceDateB,c.DateEnd) AND c.DateEnd<=ISNULL(v.PlaceDateE,c.DateEnd) AND c.DateEnd>=ISNULL(v.DeptDateB,c.DateEnd)
				AND c.DateEnd<=ISNULL(v.DeptDateE,c.DateEnd) AND ISNULL(c.rf_idSubMO,'bla-bla')=ISNULL(v.LPU1,'bla-bla'))

