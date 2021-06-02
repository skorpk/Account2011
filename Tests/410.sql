USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='141024' AND ReportYear=2019 AND NumberRegister=3

SELECT * from vw_getIdFileNumber f WHERE f.id=@idFile

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

select DISTINCT c.id,410 ,c.GUID_Case,IsNeedDisp
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180101'
where a.rf_idFiles=@idFile AND c.rf_idV009=317 AND c.IsNeedDisp IS NOT null and c.IsNeedDisp<3

SELECT * FROM vw_sprV009 WHERE id=317


select DISTINCT c.id,410
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180101'
				INNER JOIN dbo.t_DS2_Info d2 ON
		c.id=d2.rf_idCase              
where a.rf_idFiles=@idFile AND c.rf_idV009=317 AND d2.IsNeedDisp IS NOT NULL AND d2.IsNeedDisp<3


;WITH cteD
AS
(
SELECT c.id,c.GUID_Case,SUM(ISNULL(c.IsNeedDisp,0)+ISNULL(d2.IsNeedDisp,0)) AS IsNeedDisp
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180101'
			LEFT JOIN dbo.t_DS2_Info d2 ON
		c.id=d2.rf_idCase          
where a.rf_idFiles=@idFile AND c.rf_idV009 IN(355,356)
GROUP BY c.id,c.GUID_Case
)
select DISTINCT id,GUID_Case,410,IsNeedDisp FROM cteD WHERE IsNeedDisp=3

select * FROM vw_sprV009 WHERE id IN(355,356)

select DISTINCT c.id,410
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180101'
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase              
where a.rf_idFiles=@idFile AND c.rf_idV009=318 AND ISNULL(c.IsNeedDisp,9) IN (1,2) AND d.DS1 NOT LIKE 'E78.[0-9]'

select DISTINCT c.id,410
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180101'
				INNER JOIN dbo.t_DS2_Info d2 ON
		c.id=d2.rf_idCase              
where a.rf_idFiles=@idFile AND c.rf_idV009=318 AND ISNULL(d2.IsNeedDisp,9) IN(1,2) AND d2.DiagnosisCode NOT LIKE 'E78.[0-9]'