USE RegisterCases
GO
SELECT c.MU,
	cast(replace('<Root><Num num="'+LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(MUName,'����������� ������ ��������������� �� ������� �������',''),'����������� ������ ��������������� ������ (� ��������',''),' ���), 1 ����',''),', 2 ���� ',''),'����������� ������ ��������������� ������ (� �������� ',''),'����������� ������ ��������������� ������  (',''),'����������� ������ ��������������� ������ (� ������� ',''),'���) ��� ���������������� ������������, 1 ����',''),'� �������� ',''),'����) ��� ���������������� ������������, 1 ����',''),'), 1 ���� (����.1 ��� � 2 ����)',''),' ����), 1 ����',''),' ����) ��� ������������ ����, 1 ����',''),' ���) ��� ���������������� ������������, ��� ������������ ����, 1 ����',''),' ���) ��� ������������ ����, 1 ����',''),' ����) ��� ���������������� ������������, ��� ������������ ����, 1 ����',''),'  ���) ��� �����������,  ��� ��������������� ������������, 1 ����',''),' ���) ��� �����������, 1 ����',''),' ���) ��� ���������������� ������������, ��� �����������, 1 ����',''),' ���) ��� ��������������� ������������, 1 ���� ��� ���������������� ������������',''),' ���) ��� ��������������� ������������, 1 ����',''),' ��� ���������������� ������������',''),' ���),  ��� ��������������� ������������, 1 ����',''),' ���) ��� �����������,  ��� ��������������� ������������, 1 ����',''),' ���), ��� �����������,  ��� ��������������� ������������, 1 ����',''),' ���) ��� ������������ ����,  ��� ��������������� ������������, 1 ����',''),' ���) ��� ������������ ����, 1 ����',''),' ���) ��� �����������, ��� ��������������� ������������, 1 ����',''),' ���), ��� ������������ ����,  ��� ��������������� ������������, 1 ����',''),' ���), ��� ��������������� ������������, 1 ����','')))+'" /></Root>',',','" /><Num num="') as xml) AS MUNAme
INTO #t
FROM dbo.vw_sprMUCompletedCase c 			
WHERE MUGroupCode=70 AND MUUnGroupCode=3 AND EXISTS(SELECT 1 FROM dbo.t_AgeMU2 a WHERE c.mu=a.MU)

--SELECT * FROM #t

;WITH cte
AS(
SELECT s.MU,m.c.value('@num[1]','smallint') AS Age
FROM #t s CROSS APPLY s.MUName.nodes('/Root/Num') as m(c)
)
SELECT *
FROM cte c WHERE NOT EXISTS(SELECT * FROM dbo.t_AgeMU2 a WHERE a.MU=c.MU AND a.age=c.age)

SELECT c.MU,MUName	
FROM dbo.vw_sprMUCompletedCase c 			
WHERE MUGroupCode=70 AND MUUnGroupCode=3 AND not EXISTS(SELECT 1 FROM dbo.t_AgeMU2 a WHERE c.mu=a.MU)

go

DROP TABLE #t