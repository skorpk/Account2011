USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test556]    Script Date: 31.01.2017 8:10:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test556]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	

--соответствие профиля оказанной медицинской помощи профилю, установленному для этого кода законченного случая в Справочнике медицинских услуг и их тарифов, 
--с учетом детских и взрослых профилей
insert #tError
select distinct c.id,556
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			AND c.DateEnd>=@dateStart AND c.DateEnd<=@dateEnd	
						inner join dbo.t_MES m on
			c.id=m.rf_idCase
						INNER JOIN dbo.vw_sprMUCompletedCase s ON
			m.MES=s.MU
						left join (SELECT * FROM vw_sprMuProfilPaymentByAge) v on
			c.IsChild=v.Age
			AND c.rf_idV002=v.ProfileCode
			and m.MES=v.MUCode
where v.MUCode is null
