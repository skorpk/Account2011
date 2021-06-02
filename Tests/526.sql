USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='521001' AND ReportYear=2018 AND NumberRegister=118

SELECT * FROM vw_getIdFileNumber f WHERE id=@idFile

declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6),
		@typeFile char(1)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod =rc.rf_idMO, @typeFile=UPPER(f.TypeFile)
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile


select DISTINCT c.id,526,d.TypeDisp
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase								
				INNER JOIN dbo.t_DispInfo d ON
		c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprV016TFOMS WHERE Code=d.TypeDisp)

select DISTINCT c.id,526,d.TypeDisp,m.MES
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase								
				INNER JOIN dbo.t_MES m ON
		c.id=m.rf_idCase              
				INNER JOIN dbo.t_DispInfo d ON
		c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.vw_sprMUTypeDisp WHERE TypeDisp=d.TypeDisp AND MU=m.MES)

SELECT MU,TypeDisp INTO #tMU FROM oms_nsi.dbo.vw_sprMUTypeDisp

select DISTINCT c.id,526--,d.TypeDisp,m.MES
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase								
				INNER JOIN dbo.t_MES m ON
		c.id=m.rf_idCase              
				INNER JOIN #tMU d ON
		m.MES=d.MU
where a.rf_idFiles=@idFile AND NOT EXISTS(SELECT * FROM dbo.t_DispInfo WHERE TypeDisp=d.TypeDisp AND rf_idCase=c.id)


--SELECT * FROM oms_nsi.dbo.vw_sprMUTypeDisp WHERE MU='70.3.156'

select DISTINCT c.id,526,m.MUCode,TypeDisp
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase								
				INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase              
				INNER JOIN dbo.t_DispInfo d ON
		c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND m.Price>0 AND m.MUCode LIKE '2.%' AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.vw_sprMUTypeDisp WHERE TypeDisp=d.TypeDisp AND MU=m.MUCode)

SELECT * FROM oms_nsi.dbo.vw_sprMUTypeDisp WHERE TypeDisp='ÄÂ3'
SELECT * FROM dbo.vw_sprMU WHERE MU='2.90.2'
DROP TABLE #tMU
--SELECT * FROM oms_nsi.dbo.vw_sprMUTypeDisp WHERE MU LIKE '2.91.%'