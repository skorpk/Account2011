USE [OMS_NSI]
GO

/****** Object:  Table [dbo].[sprOKATO]    Script Date: 18.04.2017 13:25:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[sprOKATO](
	[ter] [char](2) NULL,
	[kod1] [char](3) NULL,
	[kod2] [char](3) NULL,
	[kod3] [char](3) NULL,
	[razdel] [char](1) NULL,
	[namel] [varchar](250) NULL,
	[centrum] [varchar](80) NULL,
	[nomdescr] [varchar](500) NULL,
	[nomakt] [char](3) NULL,
	[status] [decimal](20, 5) NULL,
	[data_upd] [date] NULL,
	[UId] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[OKATOFull] [varchar](11) NULL,
	[OKATO] [char](5) NULL,
	[dateUTV] [date] NULL,
	[dateVVED] [date] NULL,
	[OKATO2]  AS (case when [kod3]<>'000' OR [kod3]='000' AND ([razdel]=(1) OR [razdel] IS NULL) then (([ter]+[kod1])+[kod2])+[kod3] else '0' end),
 CONSTRAINT [PK_sprOKATO] PRIMARY KEY CLUSTERED 
(
	[UId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


