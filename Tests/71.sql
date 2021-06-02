USE RegisterCases
GO
DECLARE @idFile INT


select @idFile=id FROM dbo.vw_getIdFileNumber WHERE CodeM='146004' AND ReportYear=2021 AND NumberRegister=210

declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6)

SELECT * FROM dbo.vw_getIdFileNumber WHERE id=@idFile		
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod=rc.rf_idMO
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
--устанавливаем дату начала и дату окончания отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))

select distinct c1.id,71
from (
		select c.id,cc.GUID_ZSL
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase
								inner join dbo.t_CompletedCase cc on
				    r.id=cc.rf_idRecordCase							
		where a.rf_idFiles=@idFile
		) c1 inner join (
							select c.GUID_ZSL
							from t_RegistersCase a inner join t_RecordCase r on
										a.id=r.rf_idRegistersCase
													inner join dbo.t_CompletedCase c on
										r.id=c.rf_idRecordCase
							where a.rf_idFiles=@idFile		
							group by c.GUID_ZSL
							having COUNT(*)>1
						) c2 on c1.GUID_ZSL=c2.GUID_ZSL

select distinct c1.id,71
from(
		select c.id,r.ID_Patient
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase								
		where a.rf_idFiles=@idFile
	) c1 inner join (
					 select ID_Patient 
					 from t_RegisterPatient 
					 where rf_idFiles=@idFile
					 group by ID_Patient	
					 having COUNT(*)>1
					) c2 on c1.ID_Patient=c2.ID_Patient
--поиск не корректных значений в поле dbo.t_RegisterPatient.ID_Patient
select distinct c1.id,71
from(
		select c.id,r.ID_Patient
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase								
		where a.rf_idFiles=@idFile
	) c1 inner join (
					 select ID_Patient 
					 from t_RegisterPatient 
					 where rf_idFiles=@idFile and ID_Patient in ('','0')
					 group by ID_Patient	
					) c2 on c1.ID_Patient=c2.ID_Patient
--дубликаты по IDSERV
select distinct c1.id,71
from(
		select c.id,m.id as IDSERV
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase
				   				inner join t_Meduslugi m on
					c.id=m.rf_idCase
		where a.rf_idFiles=@idFile
	) c1 inner join (
						select m.id
						from t_RegistersCase a inner join t_RecordCase r on
										a.id=r.rf_idRegistersCase
											inner join t_Case c on																																					
								r.id=c.rf_idRecordCase
											inner join t_Meduslugi m on
								c.id=m.rf_idCase			
											left join t_MES mes on
								m.rf_idCase=mes.rf_idCase
						where a.rf_idFiles=@idFile and mes.rf_idCase is null
						group by m.id
						having COUNT(*)>1
					) c2 on c1.IDSERV=c2.id
					