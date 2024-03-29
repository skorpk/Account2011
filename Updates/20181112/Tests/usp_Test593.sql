USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test593]    Script Date: 25.01.2019 15:15:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test593]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
---2016-12-21
--1.	Если тег COMENTSL присутствует и если  в CODE_MES1 присутствуют услуги из класса 70.3* или 72.1* или в одном из тегов USL содержится хотя бы одна услуга из класса 2.84*
-- или из класса 2.90.* то в теге  COMENTSL  должно быть представлено одно из следующих значений: 10,  11,  14,  20,  21.
insert #tError
select c.id,593
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
						inner join t_MES mes on
				c.id=mes.rf_idCase	
						INNER JOIN (SELECT MU FROM dbo.vw_sprMUCompletedCase WHERE MUGroupCode=72 AND MUUnGroupCode=1
									UNION ALL 
									SELECT MU FROM dbo.vw_sprMUCompletedCase WHERE MUGroupCode=70 AND MUUnGroupCode=3
									) mc on
				mes.MES=mc.MU						
WHERE c.Comments IS NULL
/*Если  DISP равно или ДВ1 или ДВ2 или ДВ3 (добавлено это значение), то в теге  COMENTSL  должно быть представлено в обязательном порядке одно из следующих значений: 10,  11,  14,  20,  21*/
insert #tError
select c.id,593
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd<'20190101'
						INNER JOIN dbo.t_DispInfo d ON
				c.id=d.rf_idCase                      
WHERE UPPER(d.TypeDisp) IN ('ДВ1','ДВ2','ДВ3') AND NOT EXISTS(SELECT * FROM (VALUES('10'),('11'),('14'),('20'),('21')) v(Code) WHERE v.Code=c.Comments)
--------------------------------------------------2019-------------------------------------------------------

insert #tError
select c.id,593
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'
						INNER JOIN dbo.t_DispInfo d ON
				c.id=d.rf_idCase                      
WHERE UPPER(d.TypeDisp) IN ('ДВ1','ДВ2','ДВ3') AND LEN(ISNULL(c.Comments,''))<4

insert #tError
select c.id,593
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						inner join t_Case c on
				r.id=c.rf_idRecordCase	
				AND c.DateEnd>='20190101'
						INNER JOIN dbo.t_DispInfo d ON
				c.id=d.rf_idCase                      
WHERE UPPER(d.TypeDisp) IN ('ДВ1','ДВ2','ДВ3') AND c.Comments NOT LIKE '[1-2][0,1,4]:%'
---------------------- Перенесли из 524
---24.04.2017  в связи с диспансерным учетом беременных женщин
insert #tError
select DISTINCT c.id,593
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase				
			  inner join t_Case c on
		r.id=c.rf_idRecordCase
		AND c.DateEnd>'20170430'
		AND c.DateEnd<'20190101'
			  INNER JOIN dbo.t_Diagnosis d ON
		c.id=d.rf_idCase						  		
where a.rf_idFiles=@idFile AND d.DiagnosisGroup IN ('O10','O11','O12','O13','O14','O15','O16','O20','O21','O22','O23','O24','O25','O26','O28','O30','O31','O32','O33','O36','O40','O41','O43','O44','O45','O46','O47','O98','O99','Z33','Z34','Z35','Z36') 
		AND d.TypeDiagnosis=1 AND ISNULL(c.Comments,'9') NOT IN('5','6') AND c.rf_idV006=3 AND f.TypeFile='H'
--Для случаев, завершившихся после 01.05.2017 оказанного в амбулаторных условиях и имеющих в качестве основного диагноза один 
--из кодов групп МКБ-10 (O10-O16, O20-O26, O28, O30-O33, O36, O40-O41, O43-O47, O98-O99, Z33-Z36) проверяется обязательное наличие 
--в поле COMENTSL до «:» одного из следующих значений :  5, 6 (5- постановка на учет по беременности; 6 - продолжение наблюдения за беременной) 
insert #tError
select DISTINCT c.id,593
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase				
			  inner join t_Case c on
		r.id=c.rf_idRecordCase
		AND c.DateEnd>='20190101'
			  INNER JOIN dbo.t_Diagnosis d ON
		c.id=d.rf_idCase						  		
where a.rf_idFiles=@idFile AND d.DiagnosisGroup IN ('O10','O11','O12','O13','O14','O15','O16','O20','O21','O22','O23','O24','O25','O26','O28','O30','O31','O32','O33','O36','O40','O41','O43','O44','O45','O46','O47','O98','O99','Z33','Z34','Z35','Z36') 
		AND d.TypeDiagnosis=1 AND c.Comments IS NULL AND c.rf_idV006=3 AND f.TypeFile='H'

insert #tError
select DISTINCT c.id,593
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase				
			  inner join t_Case c on
		r.id=c.rf_idRecordCase
		AND c.DateEnd>='20190101'
			  INNER JOIN dbo.t_Diagnosis d ON
		c.id=d.rf_idCase						  		
where a.rf_idFiles=@idFile AND d.DiagnosisGroup IN ('O10','O11','O12','O13','O14','O15','O16','O20','O21','O22','O23','O24','O25','O26','O28','O30','O31','O32','O33','O36','O40','O41','O43','O44','O45','O46','O47','O98','O99','Z33','Z34','Z35','Z36') 
		AND d.TypeDiagnosis=1 AND c.Comments IS not NULL AND c.rf_idV006=3 AND f.TypeFile='H' AND DATALENGTH(c.Comments)!=3

insert #tError
select DISTINCT c.id,593
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase				
			  inner join t_Case c on
		r.id=c.rf_idRecordCase
		AND c.DateEnd>='20190101'
			  INNER JOIN dbo.t_Diagnosis d ON
		c.id=d.rf_idCase						  		
where a.rf_idFiles=@idFile AND d.DiagnosisGroup IN ('O10','O11','O12','O13','O14','O15','O16','O20','O21','O22','O23','O24','O25','O26','O28','O30','O31','O32','O33','O36','O40','O41','O43','O44','O45','O46','O47','O98','O99','Z33','Z34','Z35','Z36') 
		AND d.TypeDiagnosis=1 AND c.Comments IS not NULL AND c.rf_idV006=3 AND f.TypeFile='H' AND DATALENGTH(c.Comments)=3 AND c.Comments NOT in('5:;','6:;')

/*
13/04/2017
отменили с 04.01.2019
Для случаев, у которых или (условие оказания – стационар и код КСГ из диапазона 12???31[1-2]) или (условие оказания –дневной стационар и код КСГ из диапазона 22???11[7-8]) 
проверяется обязательное наличие значения в поле COMENTSL, причем значение должно быть равно одному из следующих значений :  0, 1, 2 (0 – без наличия системы кохлеарной имплантации у пациента; 
1 – медицинская реабилитация после кохлеарной имплантации, за исключением замены речевого процессора; 2 – медицинская реабилитация после замены речевого процессора)
*/

insert #tError
select DISTINCT c.id,593
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase				
			  inner join t_Case c on
		r.id=c.rf_idRecordCase
		AND c.DateEnd<'20190101'
			  INNER JOIN dbo.t_MES m ON
		c.id=m.rf_idCase						  		
where a.rf_idFiles=@idFile AND c.rf_idV006=1 AND m.MES LIKE '12___31[1-2]' AND c.Comments NOT IN ('0','1','2')

insert #tError
select DISTINCT c.id,593
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase				
			  inner join t_Case c on
		r.id=c.rf_idRecordCase
		AND c.DateEnd<'20190101'
			  INNER JOIN dbo.t_MES m ON
		c.id=m.rf_idCase						  		
where a.rf_idFiles=@idFile AND c.rf_idV006=2 AND m.MES LIKE '22___11[7-8]' AND c.Comments NOT IN ('0','1','2')
---15.06.2017  с прказом 02-28-185 от 05.06.2017
insert #tError
select DISTINCT c.id,593
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase				
			  inner join t_Case c on
		r.id=c.rf_idRecordCase
		AND c.DateEnd>'20170619'
			  INNER JOIN dbo.t_Diagnosis d ON
		c.id=d.rf_idCase						  		
where a.rf_idFiles=@idFile AND d.DiagnosisCode IN ('C00','C01','C02','C03','C04','C05','C06','C07','C08','C09','C10','C11','C12','C13','C14','C15','C16','C17','C18','C19','C20','C21','C22',
													'C23','C24','C25','C26','C30','C31','C32','C33','C34','C37','C38','C39','C40','C41','C43','C44','C45','C46','C47','C48','C49','C50','C51',
													'C52','C53','C54','C55','C56','C57','C58','C60','C61','C62','C63','C64','C65','C66','C67','C68','C69','C70','C71','C72','C73','C74','C75',
													'C76','C77','C78','C79','C80','C81','C82','C83','C84','C85','C86','C88','C90','C91','C92','C93','C94','C95','C96','C97')
		AND d.TypeDiagnosis =1 AND ISNULL(c.Comments,'9') NOT IN ('7','8')  AND f.TypeFile='H'
