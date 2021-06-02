USE RegisterCases
GO
IF OBJECT_ID('usp_InsertLPUEnableCalendar', N'P') IS NOT NULL
	DROP PROC usp_InsertLPUEnableCalendar
GO
CREATE PROCEDURE usp_InsertLPUEnableCalendar
				@codeM CHAR(6),
				@type BIT,--1 то для PRN_NOV=1, если 0 то для PRN_NOV=0
				@typeOperation CHAR(1) -- вид операции I - вставить, D - удалить
AS
IF NOT EXISTS(SELECT * FROM sprLPUEnableCalendar WHERE CodeM=@codeM AND typePR_NOV=@type AND @typeOperation='I')
BEGIN
	INSERT sprLPUEnableCalendar(CodeM,typePR_NOV) VALUES(@codeM,@type)
END
IF EXISTS(SELECT * FROM sprLPUEnableCalendar WHERE CodeM=@codeM AND typePR_NOV=@type AND @typeOperation='D')
BEGIN 
	DELETE FROM sprLPUEnableCalendar WHERE CodeM=@codeM AND typePR_NOV=@type 
END
GO
--вставка данных
IF OBJECT_ID('usp_InsertAllLPUEnableCalendar', N'P') IS NOT NULL
	DROP PROC usp_InsertAllLPUEnableCalendar
GO
CREATE PROCEDURE usp_InsertAllLPUEnableCalendar
				@type BIT--1 то для PRN_NOV=1, если 0 то для PRN_NOV=0
AS
INSERT sprLPUEnableCalendar(CodeM,typePR_NOV)
select l.CodeM,@type
FROM vw_sprT001 l LEFT JOIN sprLPUEnableCalendar c ON
		l.CodeM=c.CodeM 
		and c.typePR_NOV=@type
where c.CodeM is null
GO
--удаляем все записи.
IF OBJECT_ID('usp_DeleteAllLPUEnableCalendar', N'P') IS NOT NULL
	DROP PROC usp_DeleteAllLPUEnableCalendar
GO
CREATE PROCEDURE usp_DeleteAllLPUEnableCalendar
				@type BIT--1 то для PRN_NOV=1, если 0 то для PRN_NOV=0
AS
delete from sprLPUEnableCalendar where typePR_NOV=@type
GO
---------------------------------------------VIEWS------------------------------------ы
--отображает список МО для которых проверка включена при первой подаче случая
IF OBJECT_ID('vw_LPUEnableCalendarPR_NOV0', N'V') IS NOT NULL
	DROP VIEW vw_LPUEnableCalendarPR_NOV0
GO
CREATE VIEW vw_LPUEnableCalendarPR_NOV0
AS
SELECT l.CodeM,l.NameS,CASE WHEN c.CodeM IS NULL THEN 'Нет' ELSE 'Да' END AS IsEnable
FROM vw_sprT001 l LEFT JOIN sprLPUEnableCalendar c ON
		l.CodeM=c.CodeM
		and c.typePR_NOV=0
GO
--отображает список МО для которых проверка включена при повторной подаче случая
IF OBJECT_ID('vw_LPUEnableCalendarPR_NOV1', N'V') IS NOT NULL
	DROP VIEW vw_LPUEnableCalendarPR_NOV1
GO
CREATE VIEW vw_LPUEnableCalendarPR_NOV1
AS
SELECT l.CodeM,l.NameS,CASE WHEN c.CodeM IS NULL THEN 'Нет' ELSE 'Да' END AS IsEnable
FROM vw_sprT001 l LEFT JOIN sprLPUEnableCalendar c ON
		l.CodeM=c.CodeM
		and c.typePR_NOV=1
GO
IF OBJECT_ID('usp_InsertLPUEnableCalendar', N'P') IS NOT NULL
	DROP PROC usp_InsertLPUEnableCalendar
GO
CREATE PROCEDURE usp_InsertLPUEnableCalendar
				@codeM CHAR(6),
				@type BIT,--1 то для PRN_NOV=1, если 0 то для PRN_NOV=0
				@typeOperation CHAR(1) -- вид операции I - вставить, D - удалить
AS
IF NOT EXISTS(SELECT * FROM sprLPUEnableCalendar WHERE CodeM=@codeM AND typePR_NOV=@type AND @typeOperation='I')
BEGIN
	INSERT sprLPUEnableCalendar(CodeM,typePR_NOV) VALUES(@codeM,@type)
END
IF EXISTS(SELECT * FROM sprLPUEnableCalendar WHERE CodeM=@codeM AND typePR_NOV=@type AND @typeOperation='D')
BEGIN 
	DELETE FROM sprLPUEnableCalendar WHERE CodeM=@codeM AND typePR_NOV=@type 
END
GO
--вставка данных
IF OBJECT_ID('usp_InsertAllLPUEnableCalendar', N'P') IS NOT NULL
	DROP PROC usp_InsertAllLPUEnableCalendar
GO
CREATE PROCEDURE usp_InsertAllLPUEnableCalendar
				@type BIT--1 то для PRN_NOV=1, если 0 то для PRN_NOV=0
AS
INSERT sprLPUEnableCalendar(CodeM,typePR_NOV)
select l.CodeM,@type
FROM vw_sprT001 l LEFT JOIN sprLPUEnableCalendar c ON
		l.CodeM=c.CodeM 
		and c.typePR_NOV=@type
where c.CodeM is null
GO
--удаляем все записи.
IF OBJECT_ID('usp_DeleteAllLPUEnableCalendar', N'P') IS NOT NULL
	DROP PROC usp_DeleteAllLPUEnableCalendar
GO
CREATE PROCEDURE usp_DeleteAllLPUEnableCalendar
				@type BIT--1 то для PRN_NOV=1, если 0 то для PRN_NOV=0
AS
delete from sprLPUEnableCalendar where typePR_NOV=@type
GO
---------------------------------------------VIEWS------------------------------------ы
--отображает список МО для которых проверка включена при первой подаче случая
IF OBJECT_ID('vw_LPUEnableCalendarPR_NOV0', N'V') IS NOT NULL
	DROP VIEW vw_LPUEnableCalendarPR_NOV0
GO
CREATE VIEW vw_LPUEnableCalendarPR_NOV0
AS
SELECT l.CodeM,l.NameS,CASE WHEN c.CodeM IS NULL THEN 'Нет' ELSE 'Да' END AS IsEnable
FROM vw_sprT001 l LEFT JOIN sprLPUEnableCalendar c ON
		l.CodeM=c.CodeM
		and c.typePR_NOV=0
GO
--отображает список МО для которых проверка включена при повторной подаче случая
IF OBJECT_ID('vw_LPUEnableCalendarPR_NOV1', N'V') IS NOT NULL
	DROP VIEW vw_LPUEnableCalendarPR_NOV1
GO
CREATE VIEW vw_LPUEnableCalendarPR_NOV1
AS
SELECT l.CodeM,l.NameS,CASE WHEN c.CodeM IS NULL THEN 'Нет' ELSE 'Да' END AS IsEnable
FROM vw_sprT001 l LEFT JOIN sprLPUEnableCalendar c ON
		l.CodeM=c.CodeM
		and c.typePR_NOV=1
GO