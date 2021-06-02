USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='103001' AND ReportYear=2020 AND NumberRegister=118


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

SELECT * FROM dbo.vw_getIdFileNumber WHERE id=@idFile

SELECT DISTINCT c.id,417  ,DirectionDate,c.GUID_Case,cc.DateBegin,c.NumberHistoryCase
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase            
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180501'			  
				INNER JOIN dbo.t_DirectionDate pp ON
		c.id=pp.rf_idCase              
where a.rf_idFiles=@idFile AND (DirectionDate<DATEADD(month,-6,cc.DateBegin) OR DirectionDate>cc.DateBegin)