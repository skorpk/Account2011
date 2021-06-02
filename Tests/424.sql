USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT,
	@month TINYINT=1,
	@year SMALLINT=2019

select @idFile=id from vw_getIdFileNumber where CodeM='101004' and NumberRegister=4 and ReportYear=2019

select * from vw_getIdFileNumber where id=@idFile

SELECT DISTINCT c.id,424
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'		
			INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase    			
				INNER JOIN dbo.t_DirectionMU dm ON
		c.id=dm.rf_idCase              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND dm.TypeDirection=3 
		AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprV029 WHERE IDMET=dm.MethodStudy AND DATEBEG<=cc.DateEnd AND DATEEND>=cc.DateEnd)

/*
≈сли MET_ISSL in (1, 2, 3,4), то в NAPR_USL должна быть указана  услуга из номенклатуры услуг с типом равным коду из MET_ISSL. 
≈сли в NAPR_USL указана услуг и в Ќ—» не установлено соответствие дл€ этой услуги, то проверка на соответствии значению из MET_ISSL не проводитс€. 
*/

SELECT DISTINCT c.id,424 ,DirectionMU,MethodStudy
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'					
				INNER JOIN dbo.t_DirectionMU dm ON
		c.id=dm.rf_idCase              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND dm.MethodStudy>0 AND dm.MethodStudy<5 
	AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.V001 WHERE IDRB=dm.DirectionMU AND ISNULL(TypeDiagnostic,dm.MethodStudy)=dm.MethodStudy AND c.DateEnd>=DATEBEG AND c.DateEnd<DATEEND)

SELECT * FROM oms_nsi.dbo.V001 WHERE IDRB='A07.28.002'	

SELECT DISTINCT c.id,424
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'					
				INNER JOIN dbo.t_DirectionMU dm ON
		c.id=dm.rf_idCase              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND dm.TypeDirection=3 AND dm.MethodStudy>0 AND dm.MethodStudy<5 
		AND NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.V001 WHERE IDRB=dm.DirectionMU AND TypeDiagnostic=dm.MethodStudy)