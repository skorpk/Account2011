USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT	

select @idFile=id from vw_getIdFileNumber where CodeM='804504' and NumberRegister=3 and ReportYear=2021

SELECT  ErrorNumber,COUNT(rf_idCase) from dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile GROUP BY ErrorNumber

select * from vw_getIdFileNumber where id=@idFile

declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile

select distinct c1.id,568,GUID_MU
from(
		select c.id,m.GUID_MU as ID_U
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase
								inner join t_Meduslugi m on
					c.id=m.rf_idCase
		where a.rf_idFiles=@idFile
	) c1 inner join (
						select m.GUID_MU
						from t_RegistersCase a inner join t_RecordCase r on
										a.id=r.rf_idRegistersCase
													inner join t_Case c on																																	r.id=c.rf_idRecordCase
													inner join t_Meduslugi m on
								c.id=m.rf_idCase				
						where a.rf_idFiles=@idFile
						group by m.GUID_MU
						having COUNT(*)>1
					) c2 on c1.ID_U=c2.GUID_MU	
