USE oms_nsi
go
--INSERT dbo.sprAllErrors
--        ( Code ,
--          Error ,
--          DescriptionError ,
--          DateBeg ,
--          Reason
--        )
--VALUES  ( 416 , 
--          '�������� ������������ ���� ������������� ����������' , 
--          '�������� ������������ ���� DN' , -- DescriptionError - varchar(250)
--          '2018-05-14 13:49:18' , -- DateBeg - date
--          ''  -- Reason - varchar(10)
--        ),
--		( 414 , 
--          '�������� ������������ ���� ���� ���������' , 
--          '�������� ������������ ���� P_CEL' , -- DescriptionError - varchar(250)
--          '2018-05-14 13:49:18' , -- DateBeg - date
--          ''  -- Reason - varchar(10)
--        ),
--		( 415 , 
--          '�������� ������������ ���� ������� �����' , 
--          '�������� ������������ ���� PROFIL_K' , -- DescriptionError - varchar(250)
--          '2018-05-14 13:49:18' , -- DateBeg - date
--          ''  -- Reason - varchar(10)
--        ),
--		( 413 , 
--          '�������� ������������ ���������� ��������������� ����� ������������� �������' , 
--          '�������� ������������ ���� DKK2' , -- DescriptionError - varchar(250)
--          '2018-05-14 13:49:18' , -- DateBeg - date
--          ''  -- Reason - varchar(10)
--        )

INSERT dbo.sprAllErrors
        ( Code ,
          Error ,
          DescriptionError ,
          DateBeg ,
          Reason
        )
VALUES  ( 417 , 
          '������������ ���������� ���� ����������� ��������� ��' , 
          '�������� ������������ ���� NPR_DATE' , -- DescriptionError - varchar(250)
          '2018-05-15' , -- DateBeg - date
          '5.1.4.'  -- Reason - varchar(10)
        )
