USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_RunFirstProcessControl]    Script Date: 11.05.2018 7:27:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--не запускать пока не пройдена стадия тестирования	
ALTER proc [dbo].[usp_RunFirstProcessControl]
			@idFile int			
as
set nocount on

create table #tError (rf_idCase bigint,ErrorNumber smallint)

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
------------------------
---------------only H file type--------------
IF @typeFile='H'
BEGIN
	exec usp_Test507 @idFile,@month,@year,@codeLPU	
	exec usp_Test509 @idFile,@month,@year,@codeLPU
	exec usp_Test510 @idFile,@month,@year,@codeLPU
	exec usp_Test512 @idFile,@month,@year,@codeLPU
	exec usp_Test543 @idFile,@month,@year,@codeLPU
	exec usp_Test544 @idFile,@month,@year,@codeLPU
	exec usp_Test547 @idFile,@month,@year,@codeLPU
	exec usp_Test553 @idFile,@month,@year,@codeLPU
	
	exec usp_Test570 @idFile,@month,@year,@codeLPU
	exec usp_Test571 @idFile,@month,@year,@codeLPU
	exec usp_Test572 @idFile,@month,@year,@codeLPU
	exec usp_Test574 @idFile,@month,@year,@codeLPU
	exec usp_Test404 @idFile,@month,@year,@codeLPU
	exec usp_Test412 @idFile,@month,@year,@codeLPU
	--exec usp_Test413 @idFile,@month,@year,@codeLPU
	--exec usp_Test414 @idFile,@month,@year,@codeLPU
	IF @year>2017
	BEGIN
		exec usp_Test405 @idFile,@month,@year,@codeLPU	  
		exec usp_Test406 @idFile,@month,@year,@codeLPU	  
		exec usp_Test407 @idFile,@month,@year,@codeLPU	
		exec usp_Test408 @idFile,@month,@year,@codeLPU	
		exec usp_Test409 @idFile,@month,@year,@codeLPU	
	END  

	IF @codeLPU<>'125901'
	begin
		exec usp_Test577 @idFile,@month,@year,@codeLPU
	end
	--exec usp_Test594 @idFile,@month,@year,@codeLPU --отменена для HR и FR
END

IF @typeFile='F'
BEGIN
	 exec usp_Test526 @idFile,@month,@year,@codeLPU
	 exec usp_Test527 @idFile,@month,@year,@codeLPU
	 exec usp_Test528 @idFile,@month,@year,@codeLPU
	 exec usp_Test529 @idFile,@month,@year,@codeLPU
	 exec usp_Test400 @idFile,@month,@year,@codeLPU
	 exec usp_Test401 @idFile,@month,@year,@codeLPU
	 exec usp_Test403 @idFile,@month,@year,@codeLPU
	 exec usp_Test410 @idFile,@month,@year,@codeLPU
	 exec usp_Test411 @idFile,@month,@year,@codeLPU

	 exec usp_Test596 @idFile,@month,@year,@codeLPU
	 exec usp_Test597 @idFile,@month,@year,@codeLPU
	 exec usp_Test592 @idFile,@month,@year,@codeLPU
	 exec usp_Test593 @idFile,@month,@year,@codeLPU

	 
END


exec usp_Test519 @idFile,@month,@year,@codeLPU
exec usp_Test520 @idFile,@month,@year,@codeLPU
exec usp_Test521 @idFile,@month,@year,@codeLPU
exec usp_Test522 @idFile,@month,@year,@codeLPU
IF @year>2016
begin
	exec usp_Test523 @idFile,@month,@year,@codeLPU
end
exec usp_Test524 @idFile,@month,@year,@codeLPU
exec usp_Test525 @idFile,@month,@year,@codeLPU
-------------------------
exec usp_Test50 @idFile,@month,@year,@codeLPU
exec usp_Test501 @idFile,@month,@year,@codeLPU
exec usp_Test502 @idFile,@month,@year,@codeLPU
exec usp_Test504 @idFile,@month,@year,@codeLPU
exec usp_Test505 @idFile,@month,@year,@codeLPU

exec usp_Test508 @idFile,@month,@year,@codeLPU

exec usp_Test511 @idFile,@month,@year,@codeLPU

exec usp_Test514 @idFile,@month,@year,@codeLPU
exec usp_Test515 @idFile,@month,@year,@codeLPU
exec usp_Test516 @idFile,@month,@year,@codeLPU
exec usp_Test518 @idFile,@month,@year,@codeLPU
exec usp_Test531 @idFile,@month,@year,@codeLPU
exec usp_Test532 @idFile,@month,@year,@codeLPU
exec usp_Test533 @idFile,@month,@year,@codeLPU
exec usp_Test534 @idFile,@month,@year,@codeLPU
exec usp_Test535 @idFile,@month,@year,@codeLPU
exec usp_Test536 @idFile,@month,@year,@codeLPU
exec usp_Test537 @idFile,@month,@year,@codeLPU
exec usp_Test538 @idFile,@month,@year,@codeLPU
exec usp_Test541 @idFile,@month,@year,@codeLPU
exec usp_Test542 @idFile,@month,@year,@codeLPU

exec usp_Test545 @idFile,@month,@year,@codeLPU
exec usp_Test546 @idFile,@month,@year,@codeLPU

exec usp_Test548 @idFile,@month,@year,@codeLPU
exec usp_Test549 @idFile,@month,@year,@codeLPU
exec usp_Test55 @idFile,@month,@year,@codeLPU
exec usp_Test550 @idFile,@month,@year,@codeLPU
exec usp_Test551 @idFile,@month,@year,@codeLPU,@mcod
exec usp_Test552 @idFile,@month,@year,@codeLPU
exec usp_Test554 @idFile,@month,@year,@codeLPU --включил для всех типов файлов 08.02.2017

exec usp_Test556 @idFile,@month,@year,@codeLPU
exec usp_Test557 @idFile,@month,@year,@codeLPU
exec usp_Test558 @idFile,@month,@year,@codeLPU
exec usp_Test559 @idFile,@month,@year,@codeLPU,@dateReg
exec usp_Test560 @idFile,@month,@year,@codeLPU
exec usp_Test561 @idFile,@month,@year,@codeLPU
exec usp_Test562 @idFile,@month,@year,@codeLPU
--exec usp_Test563 @idFile,@month,@year,@codeLPU --отменена для HR и FR
exec usp_Test564 @idFile,@month,@year,@codeLPU
exec usp_Test565 @idFile,@month,@year,@codeLPU
exec usp_Test566 @idFile,@month,@year,@codeLPU
exec usp_Test568 @idFile,@month,@year,@codeLPU
exec usp_Test569 @idFile,@month,@year,@codeLPU

exec usp_Test573 @idFile,@month,@year,@codeLPU

exec usp_Test575 @idFile,@month,@year,@codeLPU
exec usp_Test576 @idFile,@month,@year,@codeLPU

exec usp_Test578 @idFile,@month,@year,@codeLPU
exec usp_Test579 @idFile,@month,@year,@codeLPU
exec usp_Test580 @idFile,@month,@year,@codeLPU
exec usp_Test582 @idFile,@month,@year,@codeLPU
exec usp_Test583 @idFile,@month,@year,@codeLPU
--exec usp_Test584 @idFile,@month,@year,@codeLPU -- проверка отменена 14.08.2017 по приказу Антоновой т.к. в некоторых МУ происходит интеграция одной системы с другой
exec usp_Test591 @idFile,@month,@year,@codeLPU


exec usp_Test595 @idFile,@month,@year,@codeLPU

exec usp_Test598 @idFile,@month,@year,@codeLPU
exec usp_Test63 @idFile,@month,@year,@codeLPU
exec usp_Test65 @idFile,@month,@year,@codeLPU
exec usp_Test66 @idFile,@month,@year,@codeLPU
exec usp_Test71 @idFile,@month,@year,@codeLPU

begin transaction
begin try
	if(select @@SERVERNAME)!='TSERVER'
	begin
		insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
		select distinct ErrorNumber,@idFile,rf_idCase from #tError
	end
	drop table #tError
end try
begin catch
if @@TRANCOUNT>0
	select ERROR_MESSAGE()	
	rollback transaction
end catch
if @@TRANCOUNT>0
	commit transaction
