USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test531]    Script Date: 25.01.2017 14:45:19 ******/

CREATE PROC [dbo].[usp_Test525]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--------------------Пациент-----------------------------------------
insert #tError 
select c.id as rf_idCase,525
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
				AND r.IsNew=0
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
							INNER JOIN t_ReliabilityPatient rb ON
				p.id=rb.rf_idRegisterPatient
WHERE rb.IsAttendant=1 AND rb.TypeReliability=1 AND p.Ot IS NOT NULL

insert #tError 
select c.id as rf_idCase,525
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
				AND r.IsNew=0
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
							INNER JOIN t_ReliabilityPatient rb ON
				p.id=rb.rf_idRegisterPatient
WHERE rb.IsAttendant=1 AND rb.TypeReliability=2 AND p.Fam IS NOT NULL

insert #tError 
select c.id as rf_idCase,525
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
				AND r.IsNew=0
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
							INNER JOIN t_ReliabilityPatient rb ON
				p.id=rb.rf_idRegisterPatient
WHERE rb.IsAttendant=1 AND rb.TypeReliability=3 AND p.Im IS NOT NULL		
---------------------Сопровождающий----------------------------
insert #tError 
select c.id as rf_idCase,525
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
				AND r.IsNew=1
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
							INNER JOIN t_ReliabilityPatient rb ON
				p.id=rb.rf_idRegisterPatient
WHERE rb.IsAttendant=2 AND rb.TypeReliability=1 AND EXISTS(SELECT * FROM dbo.t_RegisterPatientAttendant WHERE rf_idRegisterPatient=p.id AND Ot IS NOT NULL)

insert #tError 
select c.id as rf_idCase,525
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
				AND r.IsNew=1
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
							INNER JOIN t_ReliabilityPatient rb ON
				p.id=rb.rf_idRegisterPatient
WHERE rb.IsAttendant=2 AND rb.TypeReliability=2 AND EXISTS(SELECT * FROM dbo.t_RegisterPatientAttendant WHERE rf_idRegisterPatient=p.id AND Fam IS NOT NULL)

insert #tError 
select c.id as rf_idCase,525
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile							
				AND r.IsNew=1
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
							INNER JOIN t_ReliabilityPatient rb ON
				p.id=rb.rf_idRegisterPatient
WHERE rb.IsAttendant=2 AND rb.TypeReliability=3 AND EXISTS(SELECT * FROM dbo.t_RegisterPatientAttendant WHERE rf_idRegisterPatient=p.id AND Im IS NOT NULL)
		                          
GO
GRANT EXECUTE ON usp_Test525 TO db_RegisterCase