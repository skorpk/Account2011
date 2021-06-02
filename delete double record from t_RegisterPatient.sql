use AccountOMS
go
CREATE TABLE #t_RegisterPatientTemp
(
	id int NOT NULL,
	rf_idFiles int NOT NULL,
	ID_Patient varchar(36) NOT NULL,
	Fam nvarchar(40) NOT NULL,
	Im nvarchar(40) NOT NULL,
	Ot nvarchar(40) NULL,
	rf_idV005 tinyint NOT NULL,
	BirthDay date NOT NULL,
	BirthPlace nvarchar(100) NULL,
	rf_idRecordCase int NULL
)

declare @t as table(id int,rf_idFiles int,rf_idRecordCase int)
insert @t
select min(id),p.rf_idFiles,p.rf_idRecordCase
from t_RegisterPatient p inner join (
										select rf_idFiles,rf_idRecordCase
										from t_RegisterPatient
										group by rf_idFiles,rf_idRecordCase
										having COUNT(*)>1
									) t on
					p.rf_idFiles=t.rf_idFiles
					and p.rf_idRecordCase=t.rf_idRecordCase
group by p.rf_idFiles,p.rf_idRecordCase

insert #t_RegisterPatientTemp
select p.*
from t_RegisterPatient p inner join @t t on
			p.id=t.id
begin transaction 
	delete from t_RegisterPatient where id in (
												select p.id 
												from t_RegisterPatient p inner join @t t on
														p.rf_idFiles=t.rf_idFiles
														and p.rf_idRecordCase=t.rf_idRecordCase	
											)
SET IDENTITY_INSERT dbo.t_RegisterPatient ON
	insert t_RegisterPatient(id,rf_idFiles,ID_Patient,Fam,Im,Ot,rf_idV005
							,BirthDay,BirthPlace,rf_idRecordCase)
	select id,rf_idFiles,ID_Patient,Fam,Im,Ot,rf_idV005,BirthDay,BirthPlace,rf_idRecordCase from #t_RegisterPatientTemp
	
	select rf_idFiles,rf_idRecordCase
	from t_RegisterPatient
	group by rf_idFiles,rf_idRecordCase
	having COUNT(*)>1
	
	select *
	from t_RegisterPatient p inner join @t t on
			p.id=t.id
commit
go
drop table #t_RegisterPatientTemp
