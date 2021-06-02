USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_RunRegisterSP_TK]    Script Date: 16.11.2018 10:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc dbo.usp_RunRegisterSP_TK
			@idFileBack int
as
IF EXISTS(SELECT 1 FROM dbo.vw_getFileBack WHERE idFileBack=@idFileBack AND Period<201901)
BEGIN
exec usp_RegisterSP_TK @idFileBack
END
ELSE 
BEGIN
exec usp_RegisterSP_TK2019 @idFileBack
END
select rf_idFiles from t_FileBack where id=@idFileBack
GO
