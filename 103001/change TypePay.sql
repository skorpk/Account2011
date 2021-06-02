use RegisterCases
go
declare @p1 xml,
		@ip int

SELECT	@p1=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'c:\Test\HRT34_M103001120101.xml',SINGLE_BLOB) HRM (ZL_LIST)
declare @t as table(id_c uniqueidentifier, pay tinyint)

EXEC sp_xml_preparedocument @ip OUTPUT, @p1

insert @t
select ID_C,OPLATA
FROM OPENXML (@ip, 'ZL_LIST/ZAP/SLUCH',3)
	WITH(
			N_ZAP int '../N_ZAP',
			ID_PAC nvarchar(36) '../PACIENT/ID_PAC',
			IDCASE int ,
			ID_C uniqueidentifier,
			OPLATA tinyint
		)
where OPLATA=2
EXEC sp_xml_removedocument @ip

--select c.GUID_Case,cb.TypePay,t.pay
update cb
set cb.TypePay=t.pay
from t_Case c inner join @t t on
		c.GUID_Case=t.id_c
				inner join t_RecordCaseBack rb on
		c.id=rb.rf_idCase
				inner join t_CaseBack cb on
		rb.id=cb.rf_idRecordCaseBack
				inner join t_RegisterCaseBack ab on
		rb.rf_idRegisterCaseBack=ab.id
		and ab.NumberRegister=1
go

select * from dbo.fn_PlanOrders('103001',1,2012)