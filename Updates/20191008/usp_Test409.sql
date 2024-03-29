USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test409]    Script Date: 08.10.2019 14:38:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test409]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
insert #tError
select DISTINCT c.id,409
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180101'
where a.rf_idFiles=@idFile AND c.rf_idDepartmentMO IS NOT NULL AND NOT EXISTS(SELECT 1 FROM dbo.vw_sprMOMP_OMP v WHERE c.rf_idMO=v.CodeM 
																			AND ISNULL(c.rf_idDepartmentMO,0)=ISNULL(v.PODR,0)
																			AND ISNULL(c.rf_idSubMO,'bla-bla')=ISNULL(v.LPU1,'bla-bla')
																			)

insert #tError
select DISTINCT c.id,409
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180101'
			INNER JOIN dbo.t_Meduslugi m ON 
		c.id=m.rf_idCase
where a.rf_idFiles=@idFile AND c.rf_idDepartmentMO IS NOT NULL AND m.rf_idDepartmentMO IS null

