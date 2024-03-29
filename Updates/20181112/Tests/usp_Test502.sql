USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test502]    Script Date: 11.01.2019 13:26:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test502]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
---27.02.2014
--в обязательном порядке должен присутствовать составной тег USL (один или несколько), содержащий сведения о нахождении пациента в профильном отделении стационара. Причем:
--если PROFIL=158 в теге SLUCH, то в теге USL должна быть представлена только услуга с кодом 1.11.2,
--если PROFIL<>158 в теге SLUCH, то в теге USL должна быть представлена услуга с кодом 1.11.1 и могут быть представлены услуги из Номенклатуры медицинских услуг V001
insert #tError
select distinct c.id,502
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
WHERE c.rf_idV010=32 AND c.rf_idV002<>158 AND NOT EXISTS(SELECT * FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND MUCode='1.11.1')

insert #tError
select distinct c.id,502
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
WHERE c.rf_idV010=32 AND c.rf_idV002=158 AND NOT EXISTS(SELECT * FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND MUCode='1.11.2')
-------------------------------------------------
SELECT mu, 31 AS VIDPOM INTO #tMU FROM dbo.vw_sprMU WHERE MUGroupCode=60 AND MUUnGroupCode=3

insert #tError
select distinct c.id,502
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						INNER JOIN dbo.t_Meduslugi mm  ON
			c.id=mm.rf_idCase			
WHERE c.rf_idV010=32 AND c.rf_idV002<>158 AND mm.MUCode='1.11.1'
		AND EXISTS(SELECT 1 
					FROM dbo.t_Meduslugi m INNER JOIN dbo.t_Case cc ON
									m.rf_idCase=c.id                  
					WHERE cc.id=c.id AND mm.MUCode<>'1.11.1' AND NOT EXISTS(SELECT 1 FROM #tMU WHERE MUCode=m.MUCode AND VIDPOM=cc.rf_idV008)
					)

insert #tError
select distinct c.id,502
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						INNER JOIN dbo.t_Meduslugi mm  ON
			c.id=mm.rf_idCase			
WHERE c.rf_idV010=32 AND c.rf_idV002=158 AND mm.MUCode='1.11.2'
		AND EXISTS(SELECT 1 
					FROM dbo.t_Meduslugi m INNER JOIN dbo.t_Case cc ON
									m.rf_idCase=c.id                  
					WHERE cc.id=c.id AND mm.MUCode<>'1.11.2' AND NOT EXISTS(SELECT 1 FROM #tMU WHERE MUCode=m.MUCode AND VIDPOM=cc.rf_idV008)
					)

insert #tError
select distinct c.id,502
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
WHERE c.rf_idV010=43 AND NOT EXISTS(SELECT * FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND MUCode LIKE '55.1.%')


insert #tError
select distinct c.id,502
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						INNER JOIN dbo.t_Meduslugi mm  ON
			c.id=mm.rf_idCase			
WHERE c.rf_idV010=43 AND mm.MUCode LIKE '55.1.%'
			AND EXISTS(SELECT 1 
					FROM dbo.t_Meduslugi m 
					WHERE m.rf_idCase=c.id AND mm.MUCode NOT LIKE '55.1.%' AND NOT EXISTS(SELECT 1 FROM #tMU WHERE MUCode=m.MUCode )
					)