USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='101801' AND ReportYear=2020 AND NumberRegister=12199

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
WHERE rb.IsAttendant=1 AND rb.TypeReliability=1 AND (p.Ot IS NOT NULL and p.Ot<>'-' or r.IsChild<>0)

 
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
WHERE rb.IsAttendant=1 AND rb.TypeReliability=2 AND (p.Fam IS NOT NULL or r.IsChild<>0)

 
select c.id as rf_idCase,525,im,r.IsChild,rb.TypeReliability,r.ID_Patient
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
WHERE rb.IsAttendant=1 AND rb.TypeReliability=3 AND (p.Im IS NOT NULL or r.IsChild<>0)
---------------------Сопровождающий----------------------------
 
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
WHERE rb.IsAttendant=2 AND rb.TypeReliability=1 AND (EXISTS(SELECT * FROM dbo.t_RegisterPatientAttendant WHERE rf_idRegisterPatient=p.id AND Ot IS NOT NULL) OR r.IsNew=0)

 
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
WHERE rb.IsAttendant=2 AND rb.TypeReliability=2 AND (EXISTS(SELECT * FROM dbo.t_RegisterPatientAttendant WHERE rf_idRegisterPatient=p.id AND Fam IS NOT NULL) OR r.IsNew=0)

 
select c.id as rf_idCase,525,rb.*
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
WHERE rb.IsAttendant=2 AND rb.TypeReliability=3 AND (EXISTS(SELECT * FROM dbo.t_RegisterPatientAttendant WHERE rf_idRegisterPatient=p.id AND Im IS NOT NULL) OR r.IsNew=0)

SELECT * FROM dbo.t_RegisterPatientAttendant WHERE rf_idRegisterPatient=121093166
