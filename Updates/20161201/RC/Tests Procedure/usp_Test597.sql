USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test597]    Script Date: 26.01.2017 13:33:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test597]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--Изменения формата. Проверка не работает для файлов типа HR c 22.01.2017
/*
проверка на правомочность проведения диспансеризации определенных групп взрослого населения, 
профилактических осмотров взрослого населения, профилактических осмотров несовершеннолетних (далее - Диспансеризация)
*/

declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	
DECLARE @dateStartLicense DATE
SELECT @dateStartLicense=DateStart FROM sprLPULicense WHERE CodeM=@codeLPU

INSERT #tError( rf_idCase, ErrorNumber )
SELECT DISTINCT t.id,597
FROM (
		select DISTINCT c.id,c.DateBegin,c.GUID_Case
		from t_RegistersCase a inner join t_RecordCase r on
								a.id=r.rf_idRegistersCase
								and a.rf_idFiles=@idFile
										inner join t_Case c on
								r.id=c.rf_idRecordCase							
								AND c.DateEnd>=@dateStart 
										inner join dbo.t_Meduslugi m on
								c.id=m.rf_idCase  						
										INNER JOIN dbo.vw_sprMuWithParamAccount l ON
								m.MUCode=l.MU
								AND m.Price>0
								AND l.AccountParam IS NOT NULL	
										INNER JOIN (VALUES( 'F'),('O'),('R') ) v(Letter) ON
								l.AccountParam=v.Letter
		UNION ALL
		select DISTINCT c.id,c.DateBegin,c.GUID_Case
		from t_RegistersCase a inner join t_RecordCase r on
								a.id=r.rf_idRegistersCase
								and a.rf_idFiles=@idFile
										inner join t_Case c on
								r.id=c.rf_idRecordCase							
								AND c.DateEnd>=@dateStart 
										inner join dbo.t_MES m on
								c.id=m.rf_idCase  						
										INNER JOIN (SELECT MU,AccountParam from dbo.vw_sprMuWithParamAccount 
													UNION ALL 
													SELECT MU,AccountParam from dbo.vw_sprCSGWithParamAccount) l ON
								m.MES=l.MU	
										INNER JOIN (VALUES( 'F'),('O'),('R') ) v(Letter) ON
								l.AccountParam=v.Letter							
		) t
WHERE t.DateBegin<ISNULL(@dateStartLicense,'20200101')
ORDER BY t.id
GO