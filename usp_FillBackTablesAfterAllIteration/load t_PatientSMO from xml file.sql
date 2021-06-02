use RegisterCases
go
select * 
from vw_getIdFileNumber v inner join t_FileBack fb on
			v.id=fb.rf_idFiles
where v.CodeM='136003' and NumberRegister=204 and ReportYear=2012

declare @doc xml,
		@idoc int

SELECT	@doc=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'c:\Test\20120203\HRM136003T34_120204.xml',SINGLE_BLOB) HRM (ZL_LIST)

declare @t3 as table(
						N_ZAP int,PR_NOV tinyint,ID_PAC nvarchar(36),VPOLIS tinyint,
						SPOLIS nchar(10),NPOLIS nchar(20),SMO nchar(5),SMO_OK nchar(5),SMO_NAM nvarchar(100),NOVOR nchar(9)
					)
EXEC sp_xml_preparedocument @idoc OUTPUT, @doc
insert @t3
SELECT N_ZAP,PR_NOV,ID_PAC,VPOLIS,SPOLIS,NPOLIS,SMO,SMO_OK,SMO_NAM,NOVOR
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/PACIENT',2)
	WITH(
			N_ZAP int '../N_ZAP',
			PR_NOV tinyint '../PR_NOV',
			ID_PAC nvarchar(36),
			VPOLIS tinyint ,
			SPOLIS nchar(10),
			NPOLIS nchar(20),
			SMO nchar(5) ,
			SMO_OK nchar(5),
			SMO_NAM nvarchar(100),
			NOVOR nchar(9) 
		)
EXEC sp_xml_removedocument @idoc		

insert t_PatientSMO(ref_idRecordCase,rf_idSMO,OKATO)
select t2.id,case when t1.SMO_OK!='18000' and t1.SMO is null then '34'
					when t1.SMO_OK='18000' and t1.SMO is null then '00'	else t1.SMO end,t1.SMO_OK
from @t3 t1 inner join t_RecordCase t2 on
			t1.ID_PAC=t2.ID_Patient and
			t1.N_ZAP=t2.idRecord
where t2.id!=3464855
group by t2.id,t1.SMO,t1.SMO_OK