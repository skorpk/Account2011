USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test416]    Script Date: 25.01.2021 11:09:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test416]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

	INSERT #tError
	SELECT DISTINCT c.id,416
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND a.ReportMonth=@month
			AND a.ReportYear=@year
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase						
			AND c.DateEnd>='20180501'			
					INNER JOIN dbo.t_PurposeOfVisit pp ON
			c.id=pp.rf_idCase              		           
	where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND f.TypeFile='H' AND pp.rf_idV025='1.3' AND pp.DN IS  null

IF @year<2021
begin
	INSERT #tError
	SELECT DISTINCT c.id,416
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND a.ReportMonth=@month
			AND a.ReportYear=@year
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase						
			AND c.DateEnd>='20180501'
				  INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase            			
					INNER JOIN dbo.vw_sprMU_CEL cc ON
			m.MES=cc.MU
					INNER JOIN dbo.t_PurposeOfVisit pp ON
			c.id=pp.rf_idCase              
	where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND f.TypeFile='H' AND pp.rf_idV025='1.3' AND cc.IsNextVisit='1.3' AND pp.DN IS NULL

	INSERT #tError
	SELECT DISTINCT c.id,416
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND a.ReportMonth=@month
			AND a.ReportYear=@year
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase						
			AND c.DateEnd>='20180501'
				  INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase            			
					INNER JOIN dbo.vw_sprMU_CEL cc ON
			m.MUCode=cc.MU
					INNER JOIN dbo.t_PurposeOfVisit pp ON
			c.id=pp.rf_idCase              
	where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND f.TypeFile='H' AND m.Price>0 AND pp.rf_idV025='1.3' AND cc.IsNextVisit='1.3' AND pp.DN IS NULL

	INSERT #tError
	SELECT DISTINCT c.id,416
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND a.ReportMonth=@month
			AND a.ReportYear=@year
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase						
			AND c.DateEnd>='20180501'
				  INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase            			
					INNER JOIN dbo.t_PurposeOfVisit p ON
			c.id=p.rf_idCase		
	where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND f.TypeFile='H' AND p.DN IS NOT NULL AND NOT EXISTS(SELECT 1 FROM dbo.vw_sprMU_CEL WHERE MU=m.MES AND IsNextVisit='1.3' )

	INSERT #tError
	SELECT DISTINCT c.id,416
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND a.ReportMonth=@month
			AND a.ReportYear=@year
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase						
			AND c.DateEnd>='20180501'			             			
					INNER JOIN dbo.t_PurposeOfVisit p ON
			c.id=p.rf_idCase		
	where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND f.TypeFile='H' AND c.IsCompletedCase=0  AND p.DN IS NOT NULL 
			AND NOT EXISTS(SELECT 1 
							FROM dbo.vw_sprMU_CEL cc INNER JOIN dbo.t_Meduslugi m ON 
											cc.mu=m.MUCode
							WHERE m.rf_idCase=c.id AND cc.IsNextVisit='1.3' AND m.Price>0
							)

END
ELSE
BEGIN
			INSERT #tError
	SELECT DISTINCT c.id,416
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND a.ReportMonth=@month
			AND a.ReportYear=@year
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase						
			AND c.DateEnd>='20210101'
					INNER JOIN dbo.t_PurposeOfVisit pp ON
			c.id=pp.rf_idCase              
	where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND f.TypeFile='H' AND pp.rf_idV025 IS NOT NULL AND NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprV025 WHERE IDPC=pp.rf_idV025)
end