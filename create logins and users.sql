use master
go
if NOT EXISTS(select * from  sys.server_principals where name='vlz\eagafonova')
CREATE LOGIN [vlz\eagafonova] FROM WINDOWS WITH DEFAULT_DATABASE=[RegisterCases], DEFAULT_LANGUAGE=[us_english]
GO
if NOT EXISTS(select * from  sys.server_principals where name='HOPER\ngrishin')
CREATE LOGIN [hoper\NGrishin] FROM WINDOWS WITH DEFAULT_DATABASE=[RegisterCases], DEFAULT_LANGUAGE=[us_english]
GO
if NOT EXISTS(select * from  sys.server_principals where name='hoper\PPestrecov')
CREATE LOGIN [hoper\PPestrecov] FROM WINDOWS WITH DEFAULT_DATABASE=[RegisterCases], DEFAULT_LANGUAGE=[us_english]
GO
if NOT EXISTS(select * from  sys.server_principals where name='uzh\NVelikanova')
CREATE LOGIN [uzh\NVelikanova] FROM WINDOWS WITH DEFAULT_DATABASE=[RegisterCases], DEFAULT_LANGUAGE=[us_english]
GO
if NOT EXISTS(select * from  sys.server_principals where name='uzh\DMihailenko')
CREATE LOGIN [uzh\DMihailenko] FROM WINDOWS WITH DEFAULT_DATABASE=[RegisterCases], DEFAULT_LANGUAGE=[us_english]
GO
if NOT EXISTS(select * from  sys.server_principals where name='sever\Oostapenko')
CREATE LOGIN [sever\Oostapenko] FROM WINDOWS WITH DEFAULT_DATABASE=[RegisterCases], DEFAULT_LANGUAGE=[us_english]
GO
if NOT EXISTS(select * from  sys.server_principals where name='sever\Vbelitskaya')
CREATE LOGIN [sever\Vbelitskaya] FROM WINDOWS WITH DEFAULT_DATABASE=[RegisterCases], DEFAULT_LANGUAGE=[us_english]
GO
if NOT EXISTS(select * from  sys.server_principals where name='sever\Rpolyanin')
CREATE LOGIN [sever\Rpolyanin] FROM WINDOWS WITH DEFAULT_DATABASE=[RegisterCases], DEFAULT_LANGUAGE=[us_english]
GO
if NOT EXISTS(select * from  sys.server_principals where name='med\SIGorina')
CREATE LOGIN [med\SIGorina] FROM WINDOWS WITH DEFAULT_DATABASE=[RegisterCases], DEFAULT_LANGUAGE=[us_english]
GO
if NOT EXISTS(select * from  sys.server_principals where name='VTFOMS\EPoletkina')
CREATE LOGIN [VTFOMS\EPoletkina] FROM WINDOWS WITH DEFAULT_DATABASE=[RegisterCases], DEFAULT_LANGUAGE=[us_english]
GO
use RegisterCases
go
if not exists(select * from  sys.database_principals where type=N'U' and name='EAgafonova')
CREATE USER EAgafonova FOR LOGIN [vlz\eagafonova] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='NGrishin')
CREATE USER NGrishin  FOR LOGIN [HOPER\NGrishin] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='PPestrecov')
CREATE USER PPestrecov FOR LOGIN [hoper\PPestrecov] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='NVelikanova')
CREATE USER Velikanova FOR LOGIN [uzh\NVelikanova] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='DMihailenko')
CREATE USER Mihailenko FOR LOGIN [uzh\DMihailenko] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='Oostapenko')
CREATE USER Oostapenko FOR LOGIN [sever\Oostapenko] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='Vbelitskaya')
CREATE USER Vbelitskaya FOR LOGIN [sever\Vbelitskaya] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='Rpolyanin')
CREATE USER Rpolyanin FOR LOGIN [sever\Rpolyanin] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='SIGorina')
CREATE USER SIGorina FOR LOGIN [med\SIGorina] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='MFedesheva')
CREATE USER MFedesheva FOR LOGIN [VTFOMS\MFedesheva] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='SRomanovskii')
CREATE USER SRomanovskii FOR LOGIN [VTFOMS\SRomanovskii] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='EPoletkina')
CREATE USER EPoletkina FOR LOGIN [VTFOMS\EPoletkina] WITH DEFAULT_SCHEMA=[dbo]
GO
use AccountOMS
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='EAgafonova')
CREATE USER EAgafonova FOR LOGIN [vlz\eagafonova] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='NGrishin')
CREATE USER NGrishin  FOR LOGIN [HOPER\NGrishin] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='PPestrecov')
CREATE USER PPestrecov FOR LOGIN [hoper\PPestrecov] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='NVelikanova')
CREATE USER Velikanova FOR LOGIN [uzh\NVelikanova] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='DMihailenko')
CREATE USER Mihailenko FOR LOGIN [uzh\DMihailenko] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='Oostapenko')
CREATE USER Oostapenko FOR LOGIN [sever\Oostapenko] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='Vbelitskaya')
CREATE USER Vbelitskaya FOR LOGIN [sever\Vbelitskaya] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='Rpolyanin')
CREATE USER Rpolyanin FOR LOGIN [sever\Rpolyanin] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='SIGorina')
CREATE USER SIGorina FOR LOGIN [med\SIGorina] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='MFedesheva')
CREATE USER MFedesheva FOR LOGIN [VTFOMS\MFedesheva] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='SRomanovskii')
CREATE USER SRomanovskii FOR LOGIN [VTFOMS\SRomanovskii] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='EPoletkina')
CREATE USER EPoletkina FOR LOGIN [VTFOMS\EPoletkina] WITH DEFAULT_SCHEMA=[dbo]
GO
USE [PolicyRegister]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='EAgafonova')
CREATE USER EAgafonova FOR LOGIN [vlz\eagafonova] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='NGrishin')
CREATE USER NGrishin  FOR LOGIN [HOPER\NGrishin] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='PPestrecov')
CREATE USER PPestrecov FOR LOGIN [hoper\PPestrecov] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='NVelikanova')
CREATE USER Velikanova FOR LOGIN [uzh\NVelikanova] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='DMihailenko')
CREATE USER Mihailenko FOR LOGIN [uzh\DMihailenko] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='Oostapenko')
CREATE USER Oostapenko FOR LOGIN [sever\Oostapenko] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='Vbelitskaya')
CREATE USER Vbelitskaya FOR LOGIN [sever\Vbelitskaya] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='Rpolyanin')
CREATE USER Rpolyanin FOR LOGIN [sever\Rpolyanin] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='SIGorina')
CREATE USER SIGorina FOR LOGIN [med\SIGorina] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='MFedesheva')
CREATE USER MFedesheva FOR LOGIN [VTFOMS\MFedesheva] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='SRomanovskii')
CREATE USER SRomanovskii FOR LOGIN [VTFOMS\SRomanovskii] WITH DEFAULT_SCHEMA=[dbo]
GO
if not exists(select * from  sys.database_principals where type=N'U' and name='EPoletkina')
CREATE USER EPoletkina FOR LOGIN [VTFOMS\EPoletkina] WITH DEFAULT_SCHEMA=[dbo]
GO