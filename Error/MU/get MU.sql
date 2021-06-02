use AccountOMS
go
declare @p1 xml,
		@idFile int=7363
		
SELECT	@p1=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'c:\Test\20120203\HM255627S34001_111203.xml',SINGLE_BLOB) HRM (ZL_LIST)


declare @tmpCase as table(id int,idRecord int,GUID_CASE uniqueidentifier)

insert @tmpCase
select c.id,c.idRecordCase,c.GUID_Case
from t_File f inner join t_RegistersAccounts a on
		f.id=a.rf_idFiles
			inner join t_RecordCasePatient r on
		a.id=r.rf_idRegistersAccounts
			inner join t_Case c on
		r.id=c.rf_idRecordCasePatient
where f.id=@idFile

declare @t6 as table (
					   IDCASE int,
					   ID_C uniqueidentifier,
					   IDSERV int,
					   ID_U uniqueidentifier,
					   LPU nvarchar(6),
					   PROFIL smallint,
					   DET tinyint,
					   DATE_IN date,
					   DATE_OUT date,
					   DS nvarchar(10),
					   CODE_USL nvarchar(16),
					   KOL_USL numeric(6, 2),
					   TARIF numeric(15, 2),
					   SUMV_USL numeric(15, 2),
					   PRVS bigint,
					   COMENTU nvarchar(250)
					   )
DECLARE @idoc int					   
EXEC sp_xml_preparedocument @idoc OUTPUT, @p1
insert @t6
SELECT IDCASE,ID_C,IDSERV,ID_U,LPU,PROFIL,DET,replace(DATE_IN,'-',''),replace(DATE_OUT,'-',''),DS,CODE_USL,KOL_USL,TARIF,SUMV_USL,PRVS,COMENTU
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/SLUCH/USL',3)
	WITH(
			IDCASE int '../IDCASE',
			ID_C uniqueidentifier '../ID_C',
			IDSERV INT ,
			ID_U uniqueidentifier ,
			LPU nchar(6) ,
			PROFIL smallint,
			DET tinyint ,
			DATE_IN nchar(10),
			DATE_OUT nchar(10),
			DS nchar(10),
			CODE_USL nchar(16),
			KOL_USL DECIMAL(6,2),
			TARIF DECIMAL(15,2) ,	
			SUMV_USL DECIMAL(15,2),	
			PRVS bigint ,
			COMENTU NVARCHAR(250) 
		)

EXEC sp_xml_removedocument @idoc


if NOT EXISTS (select m.*
				from t_File f inner join t_RegistersAccounts a on
						f.id=a.rf_idFiles
							inner join t_RecordCasePatient r on
						a.id=r.rf_idRegistersAccounts
							inner join t_Case c on
						r.id=c.rf_idRecordCasePatient
							inner join t_Meduslugi m on
						c.id=m.rf_idCase
				where f.id=@idFile
				)
begin
	select c.id,t1.IDSERV, t1.ID_U, t1.LPU, t1.PROFIL, t1.DET,t1.DATE_IN,t1.DATE_OUT,t1.DS,mu.MUGroupCode,mu.MUUnGroupCode,mu.MUCode
				,t1.KOL_USL,t1.TARIF,t1.SUMV_USL,t1.PRVS,t1.COMENTU
	from @t6 t1 inner join @tmpCase c on
					t1.ID_C=c.GUID_Case
					and t1.IDCASE=c.idRecord	
					left join vw_sprMU mu on
				t1.CODE_USL=mu.MU
	where t1.ID_U is not null
	group by c.id,t1.IDSERV, t1.ID_U, t1.LPU, t1.PROFIL, t1.DET,t1.DATE_IN,t1.DATE_OUT,t1.DS,mu.MUGroupCode,mu.MUUnGroupCode,mu.MUCode
			,t1.KOL_USL,t1.TARIF,t1.SUMV_USL,t1.PRVS,t1.COMENTU
end