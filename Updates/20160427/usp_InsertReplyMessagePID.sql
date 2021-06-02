USE WCF_DB
GO
CREATE PROCEDURE usp_InsertReplyMessagePID				
				@fam VARCHAR(40),
				@im VARCHAR(40),
				@ot VARCHAR(40) =null,
				@doctype TINYINT=null,
				@doc VARCHAR(33)=null,
				@dr VARCHAR(10),
				@snils VARCHAR(14),
				@IsTrusted CHAR(1),
				@userID INT,
				@codeError CHAR(2),
				@code TINYINT
AS
DECLARE @id INT		

INSERT dbo.t_RequestMessage( UserId ,FAM ,IM ,OT ,BirthDay ,SNILS ,TypeDoc ,DOC)
VALUES  ( @userID ,@fam,@im,@ot,@dr,REPLACE(REPLACE(@snils,' ',''),'-',''),@doctype,@doc)

SELECT @id=@@IDENTITY

INSERT dbo.t_ReplyMessage( rf_idRequestMessage ,TypeReplyMessage ,CodeReplyMessage ,DateReply)
VALUES  ( @id ,@codeError, @code ,GETDATE())
go

