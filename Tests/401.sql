USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='611001' AND ReportYear=2018 AND NumberRegister=8


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

select DISTINCT c.id,401
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase	
			  INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase											
where a.rf_idFiles=@idFile AND m.IsNeedUsl IS NULL


select DISTINCT c.id,401
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase	
			  INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase											
where a.rf_idFiles=@idFile AND m.IsNeedUsl IS NOT NULL AND m.IsNeedUsl NOT IN (0,1,2)
/*
1.	Если поле заполнено 1 или 2, то в поле DISP должно быть представлено одно из следующих значений: или ДВ1 или ДВ2 или ОН1 или ОН2
*/

select DISTINCT c.id,401,m.IsNeedUsl,c.GUID_Case
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase	
			  INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase											
where a.rf_idFiles=@idFile AND m.IsNeedUsl IN (1,2) AND NOT EXISTS(SELECT * FROM dbo.t_DispInfo d WHERE d.rf_idCase=c.id AND d.TypeDisp IN('ДВ1','ДВ2','ОН1','ОН2','ОПВ'))