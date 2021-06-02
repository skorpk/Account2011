USE RegisterCases
go
IF OBJECT_ID('vw_sprMuProfilPaymentByAge',N'V') IS NOT NULL
DROP VIEW vw_sprMuProfilPaymentByAge
GO
CREATE VIEW vw_sprMuProfilPaymentByAge
AS
--0 is adult
--1 is child
select MUCode,ProfileCode,PaymentMethodCode,case when AgeGroup=2 then 1 else 0 end as Age
from oms_NSI.dbo.V_MUProfileAndPayment 
go