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
--          'Проверка заполнености поля диспансерного наблюдения' , 
--          'Проверка заполнености поля DN' , -- DescriptionError - varchar(250)
--          '2018-05-14 13:49:18' , -- DateBeg - date
--          ''  -- Reason - varchar(10)
--        ),
--		( 414 , 
--          'Проверка заполнености поля цели обращения' , 
--          'Проверка заполнености поля P_CEL' , -- DescriptionError - varchar(250)
--          '2018-05-14 13:49:18' , -- DateBeg - date
--          ''  -- Reason - varchar(10)
--        ),
--		( 415 , 
--          'Проверка заполнености поля профиля койки' , 
--          'Проверка заполнености поля PROFIL_K' , -- DescriptionError - varchar(250)
--          '2018-05-14 13:49:18' , -- DateBeg - date
--          ''  -- Reason - varchar(10)
--        ),
--		( 413 , 
--          'Проверка заполнености применения комбинированной схемы лекарственной терапии' , 
--          'Проверка заполнености поля DKK2' , -- DescriptionError - varchar(250)
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
          'Некорректное заполнение даты направления выданного МО' , 
          'Проверка заполнености поля NPR_DATE' , -- DescriptionError - varchar(250)
          '2018-05-15' , -- DateBeg - date
          '5.1.4.'  -- Reason - varchar(10)
        )
