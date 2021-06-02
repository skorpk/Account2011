USE RegisterCases
GO
DECLARE @idFile INT

SELECT @idFile=id FROM dbo.vw_getIdFileNumber WHERE id=98500--ReportYear=2017  AND CodeM='104001' AND NumberRegister=1

SELECT * FROM dbo.vw_getIdFileNumber WHERE id=@idFile

create table #tError (rf_idCase bigint,ErrorNumber smallint)

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

--insert #tError
select m.rf_idCase,516
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>'20160430'						
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase		
						INNER JOIN dbo.vw_sprCSG csg ON
			m.MES=csg.code
where c.rf_idV006=1 AND c.rf_idV008=31 AND ISNULL(csg.noKSLP,0)<>1 AND (c.Age>74 OR c.Age<4) AND c.IT_SL IS NULL

select m.rf_idCase,516
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>'20160430'						
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase		
						INNER JOIN dbo.vw_sprCSG csg ON
			m.MES=csg.code
where c.rf_idV006=1 AND c.rf_idV008=31 AND ISNULL(csg.noKSLP,0)<>1 AND (c.Age>74 OR c.Age<4) 
	AND NOT EXISTS(SELECT * FROM dbo.t_Coefficient WHERE rf_idCase=c.id AND Code_SL IS NOT NULL AND Coefficient IS NOT NULL)
go

DROP TABLE #tError


