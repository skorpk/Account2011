USE RegisterCases
GO
DECLARE @idFile int	=193776		

create table #tError (rf_idCase bigint,ErrorNumber VARCHAR(12))

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

DECLARE @period INT

SET @period=CONVERT([int],CONVERT([char](4),@year,(0))+right('0'+CONVERT([varchar](2),@month,(0)),(2)),(0))
------------------------
---------------only H file type--------------
IF @typeFile='H'
BEGIN
	exec usp_Test507 @idFile,@month,@year,@codeLPU	
	exec usp_Test509 @idFile,@month,@year,@codeLPU
	exec usp_Test510 @idFile,@month,@year,@codeLPU
	exec usp_Test512 @idFile,@month,@year,@codeLPU
	exec usp_Test543 @idFile,@month,@year,@codeLPU
	--exec usp_Test544 @idFile,@month,@year,@codeLPU
	exec usp_Test547 @idFile,@month,@year,@codeLPU
	exec usp_Test553 @idFile,@month,@year,@codeLPU
	exec usp_Test539 @idFile,@month,@year,@codeLPU
	exec usp_Test570 @idFile,@month,@year,@codeLPU
	exec usp_Test571 @idFile,@month,@year,@codeLPU
	exec usp_Test572 @idFile,@month,@year,@codeLPU
	exec usp_Test574 @idFile,@month,@year,@codeLPU
	exec usp_Test404 @idFile,@month,@year,@codeLPU
	exec usp_Test412 @idFile,@month,@year,@codeLPU
	--exec usp_Test413 @idFile,@month,@year,@codeLPU
	exec usp_Test414 @idFile,@month,@year,@codeLPU --включить позже
	exec usp_Test415 @idFile,@month,@year,@codeLPU--включить позже
	exec usp_Test416 @idFile,@month,@year,@codeLPU
	exec usp_Test417 @idFile,@month,@year,@codeLPU
	IF @year>2017
	BEGIN
		exec usp_Test405 @idFile,@month,@year,@codeLPU	  
		exec usp_Test406 @idFile,@month,@year,@codeLPU	  
		exec usp_Test407 @idFile,@month,@year,@codeLPU	
		exec usp_Test408 @idFile,@month,@year,@codeLPU	
		exec usp_Test409 @idFile,@month,@year,@codeLPU	
	END
	--IF @period>201808 
	--BEGIN
		exec usp_Test419 @idFile,@month,@year,@codeLPU	  
		exec usp_Test420 @idFile,@month,@year,@codeLPU	 
		exec usp_Test421 @idFile,@month,@year,@codeLPU	  
		exec usp_Test422 @idFile,@month,@year,@codeLPU	  
		exec usp_Test423 @idFile,@month,@year,@codeLPU	  
		exec usp_Test424 @idFile,@month,@year,@codeLPU	  
		exec usp_Test425 @idFile,@month,@year,@codeLPU	  
		exec usp_Test426 @idFile,@month,@year,@codeLPU	  
		exec usp_Test427 @idFile,@month,@year,@codeLPU	  

		exec usp_Test428 @idFile,@month,@year,@codeLPU	  
		exec usp_Test429 @idFile,@month,@year,@codeLPU	  
		exec usp_Test430 @idFile,@month,@year,@codeLPU	  

		exec usp_Test431 @idFile,@month,@year,@codeLPU	  
		exec usp_Test432 @idFile,@month,@year,@codeLPU	  
		exec usp_Test433 @idFile,@month,@year,@codeLPU	  
		exec usp_Test434 @idFile,@month,@year,@codeLPU	  
		exec usp_Test435 @idFile,@month,@year,@codeLPU	  
		exec usp_Test436 @idFile,@month,@year,@codeLPU	  
		exec usp_Test437 @idFile,@month,@year,@codeLPU	  
		exec usp_Test438 @idFile,@month,@year,@codeLPU	  
		exec usp_Test439 @idFile,@month,@year,@codeLPU	  
		exec usp_Test440 @idFile,@month,@year,@codeLPU	  
		exec usp_Test441 @idFile,@month,@year,@codeLPU	  
		exec usp_Test442 @idFile,@month,@year,@codeLPU	
		----------------------------------------------
		exec usp_Test443 @idFile,@month,@year,@codeLPU	  
		exec usp_Test444 @idFile,@month,@year,@codeLPU	  
		exec usp_Test445 @idFile,@month,@year,@codeLPU	  
		exec usp_Test446 @idFile,@month,@year,@codeLPU	  
		exec usp_Test447 @idFile,@month,@year,@codeLPU	  
		exec usp_Test448 @idFile,@month,@year,@codeLPU	  
		exec usp_Test449 @idFile,@month,@year,@codeLPU	  
		exec usp_Test450 @idFile,@month,@year,@codeLPU	  
		exec usp_Test451 @idFile,@month,@year,@codeLPU	  
		exec usp_Test452 @idFile,@month,@year,@codeLPU	  
		exec usp_Test453 @idFile,@month,@year,@codeLPU	  
		exec usp_Test454 @idFile,@month,@year,@codeLPU	  
		exec usp_Test455 @idFile,@month,@year,@codeLPU	  
		exec usp_Test456 @idFile,@month,@year,@codeLPU	  
		exec usp_Test457 @idFile,@month,@year,@codeLPU	  
		exec usp_Test458 @idFile,@month,@year,@codeLPU	  
		exec usp_Test459 @idFile,@month,@year,@codeLPU	
		
		exec usp_Test460 @idFile,@month,@year,@codeLPU	  
		exec usp_Test461 @idFile,@month,@year,@codeLPU	  
		exec usp_Test462 @idFile,@month,@year,@codeLPU	  
		exec usp_Test463 @idFile,@month,@year,@codeLPU	  
		exec usp_Test464 @idFile,@month,@year,@codeLPU	  
		exec usp_Test465 @idFile,@month,@year,@codeLPU	  
		exec usp_Test474 @idFile,@month,@year,@codeLPU	  
		exec usp_Test577 @idFile,@month,@year,@codeLPU
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
-----------14.02.2019--------------------
	exec usp_Test466 @idFile,@month,@year,@codeLPU
	exec usp_Test467 @idFile,@month,@year,@codeLPU
	exec usp_Test468 @idFile,@month,@year,@codeLPU
	exec usp_Test469 @idFile,@month,@year,@codeLPU
	exec usp_Test470 @idFile,@month,@year,@codeLPU
	exec usp_Test471 @idFile,@month,@year,@codeLPU
	exec usp_Test472 @idFile,@month,@year,@codeLPU
	exec usp_Test473 @idFile,@month,@year,@codeLPU
	---------30.01.2020----------------
	exec usp_Test499 @idFile,@month,@year,@codeLPU
	exec usp_Test300 @idFile,@month,@year,@codeLPU
END
exec usp_Test304 @idFile,@month,@year,@codeLPU
exec usp_Test303 @idFile,@month,@year,@codeLPU
EXEC usp_Test306 @idFile,@month,@year,@codeLPU
exec usp_Test307 @idFile,@month,@year,@codeLPU
exec usp_Test308 @idFile,@month,@year,@codeLPU
---07.09.2020 по требованию Калиничева В.А включил прием реестров по диспансеризации
--exec usp_Test309 @idFile,@month,@year,@codeLPU 
exec usp_Test310 @idFile,@month,@year,@codeLPU
-------------10.08.2020
exec usp_Test311 @idFile,@month,@year,@codeLPU
exec usp_Test312 @idFile,@month,@year,@codeLPU
exec usp_Test313 @idFile,@month,@year,@codeLPU
exec usp_Test314 @idFile,@month,@year,@codeLPU
exec usp_Test315 @idFile,@month,@year,@codeLPU
--exec usp_Test302 @idFile,@month,@year,@codeLPU --отменяем совсем
exec usp_Test301 @idFile,@month,@year,@codeLPU

exec usp_Test519 @idFile,@month,@year,@codeLPU
exec usp_Test520 @idFile,@month,@year,@codeLPU
exec usp_Test521 @idFile,@month,@year,@codeLPU
exec usp_Test522 @idFile,@month,@year,@codeLPU
exec usp_Test475 @idFile,@month,@year,@codeLPU
exec usp_Test476 @idFile,@month,@year,@codeLPU
exec usp_Test477 @idFile,@month,@year,@codeLPU
exec usp_Test478 @idFile,@month,@year,@codeLPU
exec usp_Test479 @idFile,@month,@year,@codeLPU
exec usp_Test480 @idFile,@month,@year,@codeLPU
-----16.12.2019---
exec usp_Test484 @idFile,@month,@year,@codeLPU
exec usp_Test485 @idFile,@month,@year,@codeLPU
exec usp_Test486 @idFile,@month,@year,@codeLPU
exec usp_Test487 @idFile,@month,@year,@codeLPU
exec usp_Test488 @idFile,@month,@year,@codeLPU
exec usp_Test489 @idFile,@month,@year,@codeLPU
exec usp_Test490 @idFile,@month,@year,@codeLPU
exec usp_Test491 @idFile,@month,@year,@codeLPU
exec usp_Test492 @idFile,@month,@year,@codeLPU
exec usp_Test493 @idFile,@month,@year,@codeLPU
exec usp_Test494 @idFile,@month,@year,@codeLPU
exec usp_Test495 @idFile,@month,@year,@codeLPU
--------27.01.2020-----
--exec usp_Test496 @idFile,@month,@year,@codeLPU отменил в связи с тем что будит новое письмо 
exec usp_Test497 @idFile,@month,@year,@codeLPU
exec usp_Test498 @idFile,@month,@year,@codeLPU
----------------------------
exec usp_Test481 @idFile,@month,@year,@codeLPU
exec usp_Test482 @idFile,@month,@year,@codeLPU
exec usp_Test483 @idFile,@month,@year,@codeLPU
exec usp_Test523 @idFile,@month,@year,@codeLPU
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
exec usp_Test567 @idFile,@month,@year,@codeLPU
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

----------------21.04.2020------------
/*именоваться проверки будут названию элемента, которые подвергается контролю
в соответствии новым справочникам Q15 и Q16
*/
EXEC usp_Test_IT_SL @idFile,@month,@year,@codeLPU
-----------------13.08.2020--------------
EXEC usp_Test_RSLT @idFile,@month,@year,@codeLPU
EXEC usp_Test_NumHist @idFile,@month,@year,@codeLPU

select distinct ErrorNumber,@idFile,c.id
FROM #tError e INNER JOIN t_Case c ON 
		e.rf_idCase=c.id
		--		INNER JOIN t_Case cc ON
		--c.rf_idRecordCase=cc.rf_idRecordCase     
GO
DROP TABLE #tError	