use RegisterCases
go
declare @idFile int=4119

declare @tError as table(rf_idCase bigint,ErrorNumber smallint)

--дубликаты по ID_C
insert @tError
select distinct c1.id,71
from (
		select c.id,c.GUID_Case
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase
		where a.rf_idFiles=@idFile
		) c1 inner join (
							select c.GUID_Case
							from t_RegistersCase a inner join t_RecordCase r on
										a.id=r.rf_idRegistersCase
													inner join t_Case c on
										r.id=c.rf_idRecordCase
							where a.rf_idFiles=@idFile		
							group by c.GUID_Case
							having COUNT(*)>1
						) c2 on c1.GUID_Case=c2.GUID_Case
--дубликаты по IDCASE
insert @tError
select distinct c1.id,72
from (
		select c.id,c.idRecordCase
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase
		where a.rf_idFiles=@idFile
		) c1 inner join (
							select c.idRecordCase
							from t_RegistersCase a inner join t_RecordCase r on
										a.id=r.rf_idRegistersCase
													inner join t_Case c on																																	r.id=c.rf_idRecordCase													
							where a.rf_idFiles=@idFile
							group by c.idRecordCase
							having COUNT(*)>1
						) c2 on c1.idRecordCase=c2.idRecordCase
						
						
--дубликаты по IDSERV
insert @tError
select distinct c1.id,73
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
											inner join t_Case c on																																					r.id=c.rf_idRecordCase
											inner join t_Meduslugi m on
								c.id=m.rf_idCase			
											left join t_MES mes on
								m.rf_idCase=mes.rf_idCase
						where a.rf_idFiles=@idFile and mes.rf_idCase is null
						group by m.id
						having COUNT(*)>1
					) c2 on c1.IDSERV=c2.id

--дубликаты по ID_U
insert @tError
select distinct c1.id,74
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
--случаи в файле H без связи с файлом людей L
insert @tError
select distinct c.id,75
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
					inner join t_Case c on
			r.id=c.rf_idRecordCase
					left join (select * from t_RegisterPatient where rf_idFiles=@idFile) p on
			r.ID_Patient=p.ID_Patient
where p.id is null

--поиск дубликатов по ID_PAC в файле с людьми
insert @tError
select distinct c1.id,76
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
				

------------------------------

select ErrorNumber,@idFile,rf_idCase from @tError
