USE [AccountOMS]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetCaseFromRegisterCaseDB]    Script Date: 12/20/2011 15:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_GetCaseFromRegisterCaseDB](@account varchar(15),@rf_idF003 char(6),@month tinyint,@year smallint)
RETURNS @case TABLE(
					ID_Patient varchar(36) NOT NULL,
					idRecordCase int NOT NULL,
					GUID_Case uniqueidentifier NOT NULL,
					rf_idV006 tinyint NULL,
					rf_idV008 smallint NULL,
					rf_idDirectMO char(6) NULL,
					HopitalisationType tinyint NULL,
					rf_idMO char(6) NOT NULL,
					rf_idV002 smallint NOT NULL,
					IsChildTariff bit NOT NULL,
					NumberHistoryCase nvarchar(50) NOT NULL,
					DateBegin date NOT NULL,
					DateEnd date NOT NULL,
					DS0 char(10) NULL,
					DS1 char(10) NULL,
					DS2 char(10) NULL,
					MES char(16) NULL,
					rf_idV009 smallint NOT NULL,
					rf_idV012 smallint NOT NULL,
					rf_idV004 int NOT NULL,
					IsSpecialCase tinyint NULL,
					rf_idV010 tinyint NOT NULL,
					Quantity decimal(5, 2) NULL,
					Tariff decimal(15, 2) NULL,
					AmountPayment decimal(15, 2) NOT NULL,
					SANK_MEK decimal(15, 2) NULL,
					SANK_MEE decimal(15, 2) NULL,
					SANK_EKMP decimal(15, 2) NULL
				)
as
begin
declare @number int,
		@property tinyint,
		@smo char(5)
		
select @number=dbo.fn_NumberRegister(@account),@smo=dbo.fn_PrefixNumberRegister(@account),@property=dbo.fn_PropertyNumberRegister(@account)
--select @number=SUBSTRING(@account,7,1),@property=SUBSTRING(@account,9,1),@smo=LEFT(@account,5)

insert @case
select distinct rc.ID_Patient,c.idRecordCase,c.GUID_Case,c.rf_idV006,c.rf_idV008,rf_idDirectMO,c.HopitalisationType,
		c.rf_idMO,c.rf_idV002,c.IsChildTariff,c.NumberHistoryCase,c.DateBegin,c.DateEnd,
		dbo.fn_GetDS0RegisterCaseDB(c.id),dbo.fn_GetDS1RegisterCaseDB(c.id),dbo.fn_GetDS2RegisterCaseDB(c.id),
		mes.MES,c.rf_idV009,c.rf_idV012,c.rf_idV004,c.IsSpecialCase,c.rf_idV010,mes.Quantity,mes.Tariff,
		c.AmountPayment,dbo.fn_GetMEKRegisterCaseDB(c.id) as SANK_MEK,dbo.fn_GetMEERegisterCaseDB(c.id) as SANK_MEE,		
		dbo.fn_GetEKMPRegisterCaseDB(c.id) as SANK_EKMP
from RegisterCases.dbo.t_RegisterCaseBack reg inner join RegisterCases.dbo.t_RecordCaseBack rec on
				reg.id=rec.rf_idRegisterCaseBack and
				reg.ref_idF003=@rf_idF003 and
				reg.ReportMonth=@month and
				reg.ReportYear=@year and
				reg.NumberRegister=@number and
				reg.PropertyNumberRegister=@property
							inner join RegisterCases.dbo.t_PatientBack p on
				rec.id=p.rf_idRecordCaseBack and
				p.rf_idSMO=@smo
							inner join RegisterCases.dbo.t_CaseBack cb on
				rec.id=cb.rf_idRecordCaseBack and
				cb.TypePay=1
							inner join RegisterCases.dbo.t_Case c on
				rec.rf_idCase=c.id
							inner join RegisterCases.dbo.t_RecordCase rc on
				c.rf_idRecordCase=rc.id
							inner join RegisterCases.dbo.t_Diagnosis d on
				c.id=d.rf_idCase
							left join RegisterCases.dbo.t_Mes mes on
				c.id=mes.rf_idCase
							left join RegisterCases.dbo.t_FinancialSanctions fin on
				c.id=fin.rf_idCase
RETURN
end;
