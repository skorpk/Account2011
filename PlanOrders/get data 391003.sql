use RegisterCases

declare @month tinyint=12,
		@year smallint=2011,
		@codeLPU char(6)='391003'
		
select p.*,u.unitName
from dbo.fn_PlanOrders(@codeLPU,@month,@year) p inner join vw_sprUnit u on
			p.UnitCode=u.unitCode

select f.id,fb.id,f.DateRegistration,f.FileNameHR,fb.FileNameHRBack,fb.MM,fb.PackID,fb.UserName,fb.DateCreate,f.CountSluch,a.NumberRegister
		,ab.PropertyNumberRegister,a.AmountPayment
from t_File f inner join t_FileBack fb on
			f.id=fb.rf_idFiles
			  inner join t_RegistersCase a on
			 f.id=a.rf_idFiles
			 inner join t_RegisterCaseBack ab on
			fb.id=ab.rf_idFilesBack
where f.CodeM=@codeLPU
