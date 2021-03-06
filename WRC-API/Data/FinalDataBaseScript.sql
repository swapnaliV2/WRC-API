USE [master]
GO
/****** Object:  Database [WRC-CMS]    Script Date: 3/23/2017 2:55:50 PM ******/
CREATE DATABASE [WRC-CMS]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'WRC-CMS', FILENAME = N'D:\Data\MSSql\WRC-CMS.mdf' , SIZE = 4096KB , MAXSIZE = UNLIMITED, FILEGROWTH = 5120KB )
 LOG ON 
( NAME = N'WRC-CMS_log', FILENAME = N'D:\Data\MSSql\WRC-CMS_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [WRC-CMS] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [WRC-CMS].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [WRC-CMS] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [WRC-CMS] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [WRC-CMS] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [WRC-CMS] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [WRC-CMS] SET ARITHABORT OFF 
GO
ALTER DATABASE [WRC-CMS] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [WRC-CMS] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [WRC-CMS] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [WRC-CMS] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [WRC-CMS] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [WRC-CMS] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [WRC-CMS] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [WRC-CMS] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [WRC-CMS] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [WRC-CMS] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [WRC-CMS] SET  DISABLE_BROKER 
GO
ALTER DATABASE [WRC-CMS] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [WRC-CMS] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [WRC-CMS] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [WRC-CMS] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [WRC-CMS] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [WRC-CMS] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [WRC-CMS] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [WRC-CMS] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [WRC-CMS] SET  MULTI_USER 
GO
ALTER DATABASE [WRC-CMS] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [WRC-CMS] SET DB_CHAINING OFF 
GO
ALTER DATABASE [WRC-CMS] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [WRC-CMS] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [WRC-CMS]
GO
/****** Object:  StoredProcedure [dbo].[SP_ChkContentName]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_ChkContentName] 
	@SiteId int,
	@ContentName nvarchar(100)
AS
BEGIN
DECLARE @Exists INT

IF EXISTS(Select Oid from StaticContents where Name=@ContentName and Views in(Select distinct Oid from Views where Site=@SiteId))
BEGIN
	SET @Exists = 1
END
ELSE
BEGIN
    SET @Exists = 0
END
	RETURN @Exists
END

GO
/****** Object:  StoredProcedure [dbo].[SP_ChkSiteName]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_ChkSiteName] 	
	@SiteName nvarchar(100)
AS
BEGIN
DECLARE @Exists INT

IF EXISTS(Select Oid from Site where Name=@SiteName)
BEGIN
	SET @Exists = 1
END
ELSE
BEGIN
    SET @Exists = 0
END
	RETURN @Exists
END

GO
/****** Object:  StoredProcedure [dbo].[SP_ContentOfViewAddUp]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Proc [dbo].[SP_ContentOfViewAddUp]
@Id int,
@Order int,
@ContentId int,
@ViewId int,
@SiteId int


as

if(@Id = -1)
begin
	if(@Order=0)
	begin
		Set @Order =(select MAX([Order]) from ContentOfView where ViewId=@ViewId)
		if(@Order is null)
		Begin
			Set @Order=1;
		End
		ELSE
		Begin
			Set @Order=@Order+1;
		End
	end
	if not Exists(Select * from ContentOfView where  ViewId=@ViewId and SiteId=@SiteId and ContentId=@ContentId)
	begin
		Insert into ContentOfView(ContentId,ViewId,SiteId,[Order])
		Values (@ContentId,@ViewId,@SiteId,@Order)
		Set @Id = SCOPE_IDENTITY()
	end
		Set @Id=-1
end
else
begin
	Update ContentOfView set ContentId=@ContentId,ViewId=@ViewId,SiteId=@SiteId,[Order]=@Order
	where Id=@Id
end

GO
/****** Object:  StoredProcedure [dbo].[SP_ContentOfViewDel]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[SP_ContentOfViewDel]
@Id int

as

Delete from ContentOfView where Id=@Id


GO
/****** Object:  StoredProcedure [dbo].[SP_ContentOfViewSelect]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SP_ContentOfViewSelect -1,0,2111

CREATE Proc [dbo].[SP_ContentOfViewSelect]
@Id int,
@LoadOnlyActive bit,
@SiteId int

as

Select * from ContentOfView where SiteId=@SiteId and (@Id =-1 Or Id=@Id) 

GO
/****** Object:  StoredProcedure [dbo].[SP_ContentsAddUp]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- SP_ContentsAddUp -1,126,'fghgfj',null,1,2,0,1,'ABC'
--Drop Proc [dbo].[SP_StaticContentsAddUp]
CREATE Proc [dbo].[SP_ContentsAddUp]
@Id int,
@Name Varchar(100),
@Type int,
@Orientation int,
@Data varchar(max),
@Description varchar(max),
@IsActive bit,
@SiteId int

as

if(@Id = -1)
begin
	Insert into Content(Name,[Type],Orientation,Data,[Description],IsActive,SiteId)
	Values (@Name,@Type,@Orientation,@Data,@Description,@IsActive,@SiteId)
	
	Set @Id = SCOPE_IDENTITY() 
end
else
begin
	Update Content set Name=@Name,[Type]=@Type,Orientation=@Orientation,Data=@Data,[Description]=@Description,IsActive=@IsActive,SiteId=@SiteId
	where Id=@Id
end

GO
/****** Object:  StoredProcedure [dbo].[SP_ContentsDel]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[SP_ContentsDel]
@Id int

as

Delete from ContentOfView where ContentId=@Id
Delete from Content where Id=@Id


GO
/****** Object:  StoredProcedure [dbo].[SP_ContentsSelect]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SP_ContentsSelect -1,0,2103

CREATE Proc [dbo].[SP_ContentsSelect]
@Id int,
@LoadOnlyActive bit,
@SiteId int

as

Select * from Content where SiteId=@SiteId and (@Id =-1 Or Id=@Id) and (@LoadOnlyActive=0 Or IsActive=@LoadOnlyActive)

--Below queries not required.
--Declare @SiteName nvarchar(100)

--if (@ViewId=0 and @SiteId!=0)
--Begin
--Print('A')
--set @SiteName=(select Title from [Site] where Id=@SiteId)

--Select C.*,@SiteId as 'Site',IsNull(@SiteName,'') as 'SiteName' from Content C where ((@Id=-1 or C.Id=@Id) and (@LoadOnlyActive=0 or C.IsActive=@LoadOnlyActive))
--and C.View in(select Id from View where (@SiteId=0 or Site=@SiteId))
--End
--Else
--Begin
--Print('B')
--declare @site int

--set @site=(select top 1 IsNull(Site,0) from View where Id=@ViewId)
--set @SiteName=(select Title from Site where Id=@site)
--select *,@site as 'Site',IsNull(@SiteName,'') as 'SiteName' from Content where View in(select Id from View where Site=@site)

--End

GO
/****** Object:  StoredProcedure [dbo].[SP_GetSearchList]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- SP_GetSearchList ''
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetSearchList]
	-- Add the parameters for the stored procedure here
	@Name nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * from Site where Title like '%'+@Name+'%' --and IsActive=1
END

GO
/****** Object:  StoredProcedure [dbo].[SP_GetViewContents]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--SP_GetViewContents 137,2111
CREATE proc [dbo].[SP_GetViewContents] 
@ViewId int,
@SiteId int

as

Select CV.Id,C.Name, C.Type, C.Orientation, C.Data, CV.[Order],(select max([Order]) from ContentOfView where ViewId=@ViewId) MaxOrder,IIF(CV.Id is null,0,1) IsSelected from Content C Inner join 
ContentOfView CV on C.Id=CV.ContentId and C.SiteId=@SiteId and CV.SiteId=@SiteId
and CV.ViewId=@ViewId
Order by IsSelected desc, Name Asc


GO
/****** Object:  StoredProcedure [dbo].[SP_MenuAddUp]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[SP_MenuAddUp]
@Id int,
@Name varchar(100),
@URL varchar(250),
@IsExternal bit,
@Order int,
@ViewId int,
@SiteId int

as

if(@Id = -1)
begin

	if(@Order=0)
	begin
		Set @Order =(select MAX([Order]) from Menu where SiteId=@SiteId)
		if(@Order is null)
		Begin
			Set @Order=1;
		End
		ELSE
		Begin
			Set @Order=@Order+1;
		End
	end
	
	Insert into Menu(Name,URL,IsExternal,[Order],ViewId,SiteId)
	Values (@Name,@URL,@IsExternal,@Order,@ViewId,@SiteId)
	SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
end
else
begin
	Update Menu set Name=@Name,URL=@URL,IsExternal=@IsExternal,[Order]=@Order,SiteId=@SiteId,ViewId=@ViewId
	where Id=@Id
	SELECT @Id AS [SCOPE_IDENTITY]
end

GO
/****** Object:  StoredProcedure [dbo].[SP_MenuDel]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Proc [dbo].[SP_MenuDel]
@Id int

as

Delete from Menu where Id=@Id

GO
/****** Object:  StoredProcedure [dbo].[SP_MenuSelect]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Proc [dbo].[SP_MenuSelect]
@Id int,
@SiteId int,
@ViewId int

as
Select *,
(select max([Order]) from Menu where SiteId=@SiteId) MaxOrder 
from Menu where SiteId=@SiteId and (@Id=-1 or Id=@Id) and (@ViewId=-1 or ViewId=@ViewId)
Order by [Order]



GO
/****** Object:  StoredProcedure [dbo].[SP_MenuUpDown]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


	Create proc [dbo].[SP_MenuUpDown]
	@id int,
	@SiteId int,
	@MoveUp int
	
	as
		
	--set @id=33
	--set @SiteId=2111
	--set @MoveUp=1

	Update Menu set Flag=@MoveUp, [Order]=[Order]+@MoveUp  where  Id=@id and SiteId=@SiteId

	Update M Set Flag=0,M.[OldOrder]=M.[Order], M.[Order]=RN
	from (
	Select ROW_NUMBER() OVER (Order by [Order], flag asc) AS RN, Id from Menu where SiteId=@SiteId
	) as T
	Inner join Menu M on T.Id=M.Id
		
		
GO
/****** Object:  StoredProcedure [dbo].[Sp_RenderView]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--exec Sp_RenderView 2078,0
CREATE Proc [dbo].[Sp_RenderView] --1,64
@SiteId int,
@ViewId int


as

if(@ViewId=0)
begin
	Select top 1 @ViewId=Id from [View] where SiteId=@SiteId and IsDefault=1 and IsActive=1
end


Select Id,Name,url,Title,Logo,IsActive from [Site] where Id=@SiteId

Select Id,Name,URL,IsExternal,[Order],ViewId,SiteId from Menu where SiteId=@SiteId Order by [Order]

Select Id,Name,Title,Logo,Orientation,IsActive,Authorized,IsDefault,SiteId from [View] where Id = @ViewId and SiteId=@SiteId

Select c.Id,c.Name,c.Type,c.Orientation,c.Data,c.Description,c.IsActive,c.SiteId,CV.[Order] from ContentOfView CV inner Join Content C on CV.ContentId=C.Id
where ViewId=@ViewId and c.IsActive=1
Order by CV.[Order]



GO
/****** Object:  StoredProcedure [dbo].[SP_SiteAddUp]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Proc [dbo].[SP_SiteAddUp]
@Id int,
@Name Varchar(100),
@url varchar(max),
@Logo varbinary(max),
@Title varchar(250),
@IsActive bit

as
if(@Id = -1)
begin
	Insert into [Site](Name,url,Logo,Title,IsActive)
	Values (@Name,@url,@Logo,@Title,@IsActive)
	SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY];
end
else
begin
	Update [Site] set Name=@Name,url=@url,Logo=@Logo,Title=@Title,IsActive=@IsActive
	where Id=@Id
	SELECT @Id AS [SCOPE_IDENTITY]
end


GO
/****** Object:  StoredProcedure [dbo].[SP_SiteDBAddUp]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Proc [dbo].[SP_SiteDBAddUp]
@Id int,
@Name Varchar(100),
@Server Varchar(50),
@Database Varchar(50),
@UserID Varchar(20),
@Password Varchar(20),
@Description Varchar(Max),
@SiteId Varchar(100)

as
if(@Id = -1)
begin
	Insert into SiteDB (Name,[Server],[Database],UserID,[Password],[Description],SiteId)
	Values (@Name,@Server,@Database,@UserID,@Password,@Description,@SiteId)
	SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY];
end
else
begin
	Update SiteDB set Name=@Name,[Server]=@Server,[Database]=@Database,UserID=@UserID,[Password]=@Password,[Description]=@Description,SiteId=@SiteId
	where Id=@Id
	SELECT @Id AS [SCOPE_IDENTITY]
end


GO
/****** Object:  StoredProcedure [dbo].[SP_SiteDBDel]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[SP_SiteDBDel]
@Id int

as

Delete from [SiteDB] where Id=@Id



GO
/****** Object:  StoredProcedure [dbo].[SP_SiteDBSelect]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[SP_SiteDBSelect]
@Id int,
@SiteId int



as



Select * from [SiteDB] where SiteId=@SiteId and (@Id=-1 or Id=@Id)



GO
/****** Object:  StoredProcedure [dbo].[SP_SiteDel]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[SP_SiteDel]
@Id int

as

Delete From Menu Where SiteId=@Id
Delete from [ContentOfView] where SiteId=@Id
Delete from [Content] where SiteId=@Id
Delete from [View] where SiteId=@Id

Delete from [SiteDB] where SiteId=@Id
Delete from [SiteMisc] where SiteId=@Id
Delete from [Site] where Id=@Id




GO
/****** Object:  StoredProcedure [dbo].[SP_SiteMiscAddUp]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create Proc [dbo].[SP_SiteMiscAddUp]
@Id int,
@Key Varchar(100),
@Value Varchar(Max),
@SiteId Varchar(100)

as
if(@Id = -1)
begin
	Insert into SiteMisc ([Key],Value,SiteId)
	Values (@Key,@Value,@SiteId)
	SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY];
end
else
begin
	Update SiteMisc set [Key]=@Key,Value=@Value,SiteId=@SiteId
	where Id=@Id
	SELECT @Id AS [SCOPE_IDENTITY]
end


GO
/****** Object:  StoredProcedure [dbo].[SP_SiteMiscDel]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[SP_SiteMiscDel]
@Id int

as

Delete from [SiteMisc] where Id=@Id



GO
/****** Object:  StoredProcedure [dbo].[SP_SiteMiscSelect]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[SP_SiteMiscSelect]
@Id int,
@SiteId int

as

Select * from [SiteMisc] where SiteId=@SiteId and (@Id=-1 or Id=@Id)



GO
/****** Object:  StoredProcedure [dbo].[SP_SiteSelect]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SP_SiteSelect -1,0,''
CREATE Proc [dbo].[SP_SiteSelect]
@Id int,
@LoadOnlyActive bit,
@SiteName varchar(100)

as

Select * from Site where ((@Id=-1 or Id=@Id) and (@LoadOnlyActive=0 or IsActive=@LoadOnlyActive) and (@SiteName='' or Title like '%'+@SiteName+'%'))



GO
/****** Object:  StoredProcedure [dbo].[SP_ViewAddUp]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[SP_ViewAddUp]
@Id int, 
@Name Varchar(100),
@Title varchar(250),
@Logo binary,
@Orientation varchar(50),
@IsActive bit,
@Authorized bit,
@IsDefault bit,
@SiteId int

as

if(@Id = -1)
begin

	if(@IsDefault=1)
	begin
		Update [View] set IsDefault=0 where IsDefault=1 and SiteId=@SiteId
	end

	Insert into [View](Name,Title,Logo,Orientation,IsActive,Authorized,IsDefault,SiteId)
	Values (@Name,@Title,@Logo,@Orientation,@IsActive,@Authorized,@IsDefault,@SiteId)
	SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY];


end
else
begin
	Update [View] set Name=@Name,Title=@Title,Logo=@Logo,Orientation=@Orientation,IsActive=@IsActive,Authorized=@Authorized,IsDefault=@IsDefault,SiteId=@SiteId
	where Id=@Id
	SELECT @Id AS [SCOPE_IDENTITY]
end

GO
/****** Object:  StoredProcedure [dbo].[SP_ViewContentsDel]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[SP_ViewContentsDel]
@Id int

as 

Delete from ContentOfView where Id=@Id;


GO
/****** Object:  StoredProcedure [dbo].[SP_ViewContentUpDown]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


	CREATE proc [dbo].[SP_ViewContentUpDown]
	@id int,
	@ViewId int,
	@SiteId int,
	@MoveUp int
	
	as
		
	--set @id=33
	--set @ViewId=137
	--set @SiteId=2111
	--set @MoveUp=1

	Update ContentOfView set Flag=@MoveUp, [Order]=[Order]+@MoveUp  where  Id=@id and SiteId=@SiteId and ViewId=@ViewId

	Update CV Set Flag=0,Cv.[OldOrder]=CV.[Order], CV.[Order]=RN
	from (
	Select ROW_NUMBER() OVER (Order by [Order], flag asc) AS RN, Id from ContentOfView where SiteId=@SiteId and ViewId=@ViewId
	) as T
	Inner join ContentOfView CV on T.Id=CV.Id
	

	Select [Order],* from ContentOfView where SiteId=@SiteId and ViewId=@ViewId Order by 1, flag asc

GO
/****** Object:  StoredProcedure [dbo].[SP_ViewDel]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Proc [dbo].[SP_ViewDel]

@Id int



as


Delete from Menu where ViewId=@Id
Delete from ContentOfView where ViewId=@Id
Delete from [View] where Id=@Id 



GO
/****** Object:  StoredProcedure [dbo].[SP_ViewSelect]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Proc [dbo].[SP_ViewSelect]
@Id int,
@SiteId int,
@LoadOnlyActive bit,
@ViewName varchar(100)

as

Select * from [View] where SiteId=@SiteId and
((@Id=-1 or Id=@Id) and (@ViewName='' or Title=@ViewName)and (@LoadOnlyActive=0 or IsActive=@LoadOnlyActive))


GO
/****** Object:  UserDefinedFunction [dbo].[SplitString]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SplitString] ( @stringToSplit VARCHAR(MAX) )
RETURNS
 @returnList TABLE ([Name] [nvarchar] (500))
AS
BEGIN

 DECLARE @name NVARCHAR(255)
 DECLARE @pos INT

 WHILE CHARINDEX(',', @stringToSplit) > 0
 BEGIN
  SELECT @pos  = CHARINDEX(',', @stringToSplit)  
  SELECT @name = SUBSTRING(@stringToSplit, 1, @pos-1)

  INSERT INTO @returnList 
  SELECT @name

  SELECT @stringToSplit = SUBSTRING(@stringToSplit, @pos+1, LEN(@stringToSplit)-@pos)
 END

 INSERT INTO @returnList
 SELECT @stringToSplit

 RETURN
END
GO
/****** Object:  Table [dbo].[Content]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Content](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NULL,
	[Type] [int] NULL,
	[Orientation] [varchar](50) NULL,
	[Data] [varchar](max) NULL,
	[Description] [varchar](max) NULL,
	[IsActive] [bit] NULL,
	[SiteId] [int] NULL,
 CONSTRAINT [PK_StaticContents] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ContentOfView]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContentOfView](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ContentId] [int] NULL,
	[ViewId] [int] NULL,
	[SiteId] [int] NULL,
	[Order] [int] NULL,
	[flag] [int] NULL,
	[OldOrder] [int] NULL,
 CONSTRAINT [PK_ContentsOfPages] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Menu]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Menu](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NULL,
	[URL] [varchar](100) NULL,
	[IsExternal] [bit] NULL,
	[Order] [int] NULL,
	[ViewId] [int] NULL,
	[SiteId] [int] NULL,
	[OldOrder] [int] NULL,
	[Flag] [int] NULL,
 CONSTRAINT [PK_Menu] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Site]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Site](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NULL,
	[url] [varchar](max) NULL,
	[Title] [varchar](250) NULL,
	[Logo] [varbinary](max) NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_Sites] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SiteDB]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SiteDB](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NULL,
	[Server] [varchar](50) NULL,
	[Database] [varchar](50) NULL,
	[UserID] [varchar](20) NULL,
	[Password] [varchar](20) NULL,
	[Description] [varchar](max) NULL,
	[SiteId] [int] NULL,
 CONSTRAINT [PK_SiteDB] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SiteMisc]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SiteMisc](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Key] [varchar](50) NULL,
	[Value] [varchar](250) NULL,
	[SiteId] [int] NULL,
 CONSTRAINT [PK_SiteMisc] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Tracker]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Tracker](
	[Id] [uniqueidentifier] NOT NULL,
	[RequestData] [varchar](max) NULL,
	[DateTime] [datetime] NULL,
	[SiteId] [int] NULL,
 CONSTRAINT [PK_Tracker] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TrackerTransaction]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TrackerTransaction](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Token] [varchar](100) NULL,
	[ViewType] [int] NULL,
	[DateTime] [datetime] NULL,
	[Order] [int] NULL,
	[Data1] [varchar](max) NULL,
	[Data2] [varchar](max) NULL,
	[Data3] [varchar](max) NULL,
	[Data4] [varchar](max) NULL,
	[TrackerId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_TrackerTransaction] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[View]    Script Date: 3/23/2017 2:55:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[View](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NULL,
	[Title] [varchar](250) NULL,
	[Logo] [varchar](max) NULL,
	[Orientation] [varchar](50) NULL,
	[IsActive] [bit] NULL,
	[Authorized] [bit] NULL,
	[IsDefault] [bit] NULL,
	[SiteId] [int] NULL,
 CONSTRAINT [PK_Views] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET IDENTITY_INSERT [dbo].[Content] ON 

INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1033, N'About Us Content1', NULL, NULL, NULL, N'<p>Frankness applauded by supported ye household. Collected favourite now for for and rapturous repulsive consulted. An seems green be wrote again. She add what own only like. Tolerably we as extremity exquisite do commanded. Doubtful offended do entrance of landlord moreover is mistress in. Nay was appear entire ladies. Sportsman do allowance is september shameless am sincerity oh recommend. Gate tell man day that who.</p>
<p>Doubtful two bed way pleasure confined followed. Shew up ye away no eyes life or were this. Perfectly did suspicion daughters but his intention. Started on society an brought it explain. Position two saw greatest stronger old. Pianoforte if at simplicity do estimating.</p>
<p>Ought these are balls place mrs their times add she. Taken no great widow spoke of it small. Genius use except son esteem merely her limits. Sons park by do make on. It do oh cottage offered cottage in written. Especially of dissimilar up attachment themselves by interested boisterous. Linen mrs seems men table. Jennings dashwood to quitting marriage bachelor in. On as conviction in of appearance apartments boisterous.</p>
<p>Bed sincerity yet therefore forfeited his certainty neglected questions. Pursuit chamber as elderly amongst on. Distant however warrant farther to of. My justice wishing prudent waiting in be. Comparison age not pianoforte increasing delightful now. Insipidity sufficient dispatched any reasonably led ask. Announcing if attachment resolution sentiments admiration me on diminution.</p>
<p>Inquietude simplicity terminated she compliment remarkably few her nay. The weeks are ham asked jokes. Neglected perceived shy nay concluded. Not mile draw plan snug next all. Houses latter an valley be indeed wished merely in my. Money doubt oh drawn every or an china. Visited out friends for expense message set eat.</p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1034, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1035, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1036, N'About Us', NULL, NULL, NULL, N'<div class="textwidget">
<p>V2 is a global technology and product company serving the media and entertainment industry since 2003.</p>
<p>We provide digital supply chain and localization services to the largest media companies and online retailers, serving more than 150 international markets.&nbsp;</p>
</div>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1037, N'Contact Us', NULL, NULL, NULL, N'<div class="mod" data-md="1002" data-hveid="131" data-ved="0ahUKEwi8y7uAjbDSAhUMxrwKHaJzCnAQkCkIgwEoAjAQ">
<div class="_eFb">
<div class="_mr kno-fb-ctx" data-dtype="d3adr" data-ved="0ahUKEwi8y7uAjbDSAhUMxrwKHaJzCnAQghwIhAEoADAQ"><span class="_Xbe" style="font-size: large;">International Infotech Park, Tower No. 1, </span></div>
<div class="_mr kno-fb-ctx" data-dtype="d3adr" data-ved="0ahUKEwi8y7uAjbDSAhUMxrwKHaJzCnAQghwIhAEoADAQ"><span class="_Xbe" style="font-size: large;">First Floor, B 103/104,</span></div>
<div class="_mr kno-fb-ctx" data-dtype="d3adr" data-ved="0ahUKEwi8y7uAjbDSAhUMxrwKHaJzCnAQghwIhAEoADAQ"><span class="_Xbe" style="font-size: large;"> Swami Pranabananda Marg, Sector 30, </span></div>
<div class="_mr kno-fb-ctx" data-dtype="d3adr" data-ved="0ahUKEwi8y7uAjbDSAhUMxrwKHaJzCnAQghwIhAEoADAQ"><span class="_Xbe" style="font-size: large;">Vashi,</span><span style="font-size: large;">Navi Mumbai, Maharashtra 400703</span></div>
</div>
</div>
<div class="mod" data-md="1006" data-hveid="133" data-ved="0ahUKEwi8y7uAjbDSAhUMxrwKHaJzCnAQkCkIhQEoAzAR">
<div class="_eFb">
<div class="_mr kno-fb-ctx" data-dtype="d3ph" data-ved="0ahUKEwi8y7uAjbDSAhUMxrwKHaJzCnAQ8I0BCIYBKAAwEQ"><span class="_Xbe kno-fv" style="font-size: large;"><span class="_RCm">Phone:</span><span data-dtype="d3ph">022 4153 0200</span></span></div>
</div>
</div>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1039, N'C2', NULL, NULL, NULL, N'<p>sdshttp://192.168.35.124/WRCWebAPI/</p>
<p>s</p>
<p>ds</p>
<p>d</p>
<p>s</p>
<p>d</p>
<p>sd</p>
<p>s</p>
<p>dsdsdsd</p>
<p>sds</p>
<p>ds</p>
<p>d</p>
<p>sd</p>
<p></p>
<p>sdsd</p>
<p><span style="color: #a31515; font-family: Consolas; font-size: small;" size="2" face="Consolas" color="#a31515"><span style="color: #a31515; font-family: Consolas; font-size: small;" size="2" face="Consolas" color="#a31515"><span style="color: #a31515; font-family: Consolas; font-size: small;" size="2" face="Consolas" color="#a31515"></span></span></span></p>', 0, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1040, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1041, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1042, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1043, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1044, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1045, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1046, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1047, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1048, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1050, N'Test', NULL, NULL, NULL, N'<p><span style="text-align: left; color: #242729; text-transform: none; text-indent: 0px; letter-spacing: normal; font-family: Arial, ''Helvetica Neue'', Helvetica, sans-serif; font-size: 15px; font-style: normal; font-weight: normal; word-spacing: 0px; float: none; display: inline !important; white-space: normal; orphans: 2; widows: 2; background-color: #ffffff; font-variant-ligatures: normal; font-variant-caps: normal; -webkit-text-stroke-width: 0px;">I think the flaw here is that HTML is a<span class="Apple-converted-space">&nbsp;</span></span><a style="margin: 0px; padding: 0px; border: 0px currentColor; border-image: none; text-align: left; color: #005999; text-transform: none; text-indent: 0px; letter-spacing: normal; font-family: Arial, ''Helvetica Neue'', Helvetica, sans-serif; font-size: 15px; font-style: normal; font-weight: normal; text-decoration: none; word-spacing: 0px; white-space: normal; cursor: pointer; orphans: 2; widows: 2; background-color: #ffffff; font-variant-ligatures: normal; font-variant-caps: normal; -webkit-text-stroke-width: 0px;" href="http://www.google.com/?returnurl=http://en.wikipedia.org/wiki/Context-free_grammar" rel="noreferrer">Chomsky Type 2 grammar (context free grammar)</a><span style="text-align: left; color: #242729; text-transform: none; text-indent: 0px; letter-spacing: normal; font-family: Arial, ''Helvetica Neue'', Helvetica, sans-serif; font-size: 15px; font-style: normal; font-weight: normal; word-spacing: 0px; float: none; display: inline !important; white-space: normal; orphans: 2; widows: 2; background-color: #ffffff; font-variant-ligatures: normal; font-variant-caps: normal; -webkit-text-stroke-width: 0px;"><span class="Apple-converted-space">&nbsp;</span>and RegEx is a<span class="Apple-converted-space">&nbsp;</span></span><a style="margin: 0px; padding: 0px; border: 0px currentColor; border-image: none; text-align: left; color: #005999; text-transform: none; text-indent: 0px; letter-spacing: normal; font-family: Arial, ''Helvetica Neue'', Helvetica, sans-serif; font-size: 15px; font-style: normal; font-weight: normal; text-decoration: none; word-spacing: 0px; white-space: normal; cursor: pointer; orphans: 2; widows: 2; background-color: #ffffff; font-variant-ligatures: normal; font-variant-caps: normal; -webkit-text-stroke-width: 0px;" href="http://www.google.com/?returnurl=http://en.wikipedia.org/wiki/Regular_grammar" rel="noreferrer">Chomsky Type 3 grammar (regular grammar)</a><span style="text-align: left; color: #242729; text-transform: none; text-indent: 0px; letter-spacing: normal; font-family: Arial, ''Helvetica Neue'', Helvetica, sans-serif; font-size: 15px; font-style: normal; font-weight: normal; word-spacing: 0px; float: none; display: inline !important; white-space: normal; orphans: 2; widows: 2; background-color: #ffffff; font-variant-ligatures: normal; font-variant-caps: normal; -webkit-text-stroke-width: 0px;">. Since a Type 2 grammar is fundamentally more complex than a Type 3 grammar (see the<span class="Apple-converted-space">&nbsp;</span></span><a style="margin: 0px; padding: 0px; border: 0px currentColor; border-image: none; text-align: left; color: #005999; text-transform: none; text-indent: 0px; letter-spacing: normal; font-family: Arial, ''Helvetica Neue'', Helvetica, sans-serif; font-size: 15px; font-style: normal; font-weight: normal; text-decoration: none; word-spacing: 0px; white-space: normal; cursor: pointer; orphans: 2; widows: 2; background-color: #ffffff; font-variant-ligatures: normal; font-variant-caps: normal; -webkit-text-stroke-width: 0px;" href="http://www.google.com/?returnurl=http://en.wikipedia.org/wiki/Chomsky_hierarchy" rel="noreferrer">Chomsky hierarchy</a><span style="text-align: left; color: #242729; text-transform: none; text-indent: 0px; letter-spacing: normal; font-family: Arial, ''Helvetica Neue'', Helvetica, sans-serif; font-size: 15px; font-style: normal; font-weight: normal; word-spacing: 0px; float: none; display: inline !important; white-space: normal; orphans: 2; widows: 2; background-color: #ffffff; font-variant-ligatures: normal; font-variant-caps: normal; -webkit-text-stroke-width: 0px;">), you can''t possibly make this work. But many will try, some will claim success and others will find the fault and totally mess you up.</span></p>', 0, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1053, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1054, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1055, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1056, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1057, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1058, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1059, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1060, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1061, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1062, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1063, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1064, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1065, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1066, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1067, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1068, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1069, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1070, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1071, N'Welcome', NULL, NULL, NULL, N'<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>
<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1072, N'Contact Us', 2, N'1', NULL, N'', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1073, N'Contact Us', 2, N'1', NULL, N'', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1074, N'Contact Us', 2, N'1', NULL, N'', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1075, N'Contact Us', 2, N'1', NULL, N'', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1076, N'Contact Us', 2, N'1', NULL, N'', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1078, N'Contact Us', 2, N'1', NULL, N'', 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1079, N'Contact Us', 2, N'1', NULL, NULL, 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1080, N'fghgfj', 2, N'1', NULL, NULL, 1, NULL)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1086, N'Home', 0, N'1', N'"<p>Welcome</p>"', N'home content', 1, 2103)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1090, N'Contact Us', 0, N'2', N'"<p>Welcom</p>"', N'Contact us content', 1, 2103)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1091, N'About Us', 0, N'3', N'"<p>About V2</p>"', N'About us content', 1, 2103)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1092, N'Help', 0, N'4', N'"<p>Hello</p>"', N'help content2', 1, 2103)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1093, N'Home', 0, N'0', N'"<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>\r\n<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>"', N'Welcome', 1, 2105)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1094, N'Home', 2, N'0', N'{"st":1}', N'Welcome', 1, 2111)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1095, N'About Us', 2, N'1', N'{"st":"0,1"}', N'About us desc', 1, 2111)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1099, N'ghjhgj', 1, N'3', N'{"sd":"","st":0,"v":"137"}', N'hjhg', 1, 2111)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1104, N'Home', 0, N'0', N'{"sd":"<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>\r\n<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>","st":-1,"v":142}', N'Welcome', 1, 2116)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1115, N'test', 0, N'1', N'{"sd":"<p>welcom</p>","st":0,"v":null}', N'test1', 1, 2111)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1116, N'y', 0, N'0', N'{"sd":"<p>kolki</p>","st":0,"v":null}', N'y', 1, 2111)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1119, N'Home', 0, N'0', N'{"sd":"<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>\r\n<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>","st":-1,"v":148}', N'Welcome', 1, 2122)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1124, N'test', 1, N'6', N'{"sd":"","st":0,"v":"136"}', N'test', 1, 2111)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1125, N'test1', 2, N'9', N'{"sd":"","st":1,"v":null}', N'test1', 1, 2111)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1126, N'test2', 0, N'7', N'{"sd":"<p>hwllo</p>","st":0,"v":null}', N'test2', 1, 2111)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1127, N'test3', 1, N'3', N'{"st":0}', N'test3', 1, 2111)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1130, N'GNew Search', 1, N'3', N'{"v":"136,137,151"}', N'Te', 1, 2111)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1144, N'Home', 0, N'1', N'{"sd":"<p>Home</p>"}', N'Home', 1, 2078)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1145, N'Home', 0, N'0', N'{"sd":"<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>\r\n<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>","st":-1,"v":160}', N'Welcome', 1, 2126)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1146, N'Home', 0, N'0', N'{"sd":"<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>\r\n<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>","st":-1,"v":161}', N'Welcome', 1, 2127)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1147, N'Home', 0, N'0', N'{"sd":"<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>\r\n<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>","st":-1,"v":162}', N'Welcome', 1, 2129)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1148, N'C1', 0, N'1', N'{"sd":"<p>Hi.</p>"}', N'C1', 1, 2129)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1149, N'C2', 0, N'1', N'{"sd":"<p>Hi2</p>"}', N'C2', 1, 2129)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1150, N'Home', 0, N'0', N'{"sd":"<p><span style=''font-size: medium;''><b><span style=''text-decoration: underline;''>This is our default template.</span></b></span></p>\r\n<p><strong><span style=''text-decoration: underline;''>Welcome to our site.<img src=''http://localhost:49791/Scripts/tinymce/plugins/emotions/img/smiley-smile.gif'' alt=''Smile'' title=''Smile'' border=''0'' /></span></strong></p>","st":-1,"v":168}', N'Welcome', 1, 2130)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1151, N'FFF', 0, N'1', N'{"sd":"<p>FFF</p>"}', N'demo23', 1, 2111)
INSERT [dbo].[Content] ([Id], [Name], [Type], [Orientation], [Data], [Description], [IsActive], [SiteId]) VALUES (1154, N'static', 0, N'1', N'{"sd":"<p>hi</p>"}', N'static', 1, 2111)
SET IDENTITY_INSERT [dbo].[Content] OFF
SET IDENTITY_INSERT [dbo].[ContentOfView] ON 

INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (2, 1094, 137, 2111, 1, 0, 1)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (10, 1095, 137, 2111, 2, 0, 2)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (12, 1115, 137, 2111, 3, 0, 2)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (22, 1094, 136, 2111, 1, 0, NULL)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (23, 1095, 136, 2111, 2, 0, NULL)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (24, 1099, 136, 2111, 3, 0, NULL)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (25, 1115, 136, 2111, 4, 0, NULL)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (26, 1116, 136, 2111, 5, 0, NULL)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (27, 1127, 136, 2111, 6, 0, NULL)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (28, 1125, 136, 2111, 7, 0, NULL)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (29, 1126, 136, 2111, 8, 0, NULL)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (30, 1130, 136, 2111, 9, 0, NULL)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (31, 1099, 136, 2111, 11, 0, NULL)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (32, 1099, 137, 2111, 4, 0, 4)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (33, 1116, 137, 2111, 6, 0, 6)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (39, 1125, 137, 2111, 5, 0, 5)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (40, 1126, 137, 2111, 7, 0, 7)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (41, 1127, 137, 2111, 8, 0, 8)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (42, 1151, 137, 2111, 10, 0, 10)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (43, 1154, 164, 2111, 12, 0, NULL)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (44, 1130, 137, 2111, 9, 0, 9)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (46, 1154, 137, 2111, 11, 0, 11)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (53, 1094, 152, 2111, 5, 0, 5)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (54, 1095, 152, 2111, 3, 0, 2)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (57, 1115, 152, 2111, 4, 0, 4)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (58, 1099, 152, 2111, 7, 0, 7)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (59, 1116, 152, 2111, 8, 0, 8)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (60, 1125, 152, 2111, 6, 0, 6)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (61, 1126, 152, 2111, 9, 0, 9)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (62, 1127, 152, 2111, 10, 0, 10)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (63, 1130, 152, 2111, 2, 0, 2)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (64, 1151, 152, 2111, 11, 0, 11)
INSERT [dbo].[ContentOfView] ([Id], [ContentId], [ViewId], [SiteId], [Order], [flag], [OldOrder]) VALUES (65, 1154, 152, 2111, 1, 0, 1)
SET IDENTITY_INSERT [dbo].[ContentOfView] OFF
SET IDENTITY_INSERT [dbo].[Menu] ON 

INSERT [dbo].[Menu] ([Id], [Name], [URL], [IsExternal], [Order], [ViewId], [SiteId], [OldOrder], [Flag]) VALUES (4, N'Home', N'Home', 1, 1, 64, 2078, 0, 0)
INSERT [dbo].[Menu] ([Id], [Name], [URL], [IsExternal], [Order], [ViewId], [SiteId], [OldOrder], [Flag]) VALUES (7, N'Home', N'http://home.com', 1, 1, 136, 2111, 1, 0)
SET IDENTITY_INSERT [dbo].[Menu] OFF
SET IDENTITY_INSERT [dbo].[Site] ON 

INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2077, N'wrcstaging.harmonyis.net', N'http://localhost:49792/Site', N'North Central Ohio ADRN', NULL, 1)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2078, N'Harmony', N'http://localhost:49792/Site12', N'Harmony Vision', NULL, 1)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2079, N'V2 Solutions Pvt. Ltd.', N'http://www.vcsdata.com/website.html?webinfo=V2-Tech-Ventures-Pvt-Ltd', N'V2 Solutions Pvt. Ltd.', NULL, 1)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2082, N'New style3', N'http://localhost:49792/Site/AddView2', N'Site3', NULL, 0)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2083, N'New style4', N'http://localhost:49792/Site/AddView2', N'Site4', NULL, 1)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2084, N'New style5', N'http://localhost:49792/Site/AddView2', N'Site6', NULL, 1)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2085, N'site9', N'http://localhost:49792/Site/AddView2', N'site9', NULL, 0)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2086, N'10', N'http://localhost:49792/Site/AddView2', N'201', NULL, 1)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2087, N'11', N'http://localhost:49792/Site/AddSite', N'11', NULL, 0)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2089, N'13', N'http://localhost:49792/Site/AddSite', N'13', NULL, 0)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2090, N'Moen-Ullrich', N'robertschamplin.us', N'Incredible Granite Shoes', NULL, 0)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2091, N'Schaefer Group', N'abbott.us', N'Fantastic Car', NULL, 0)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2092, N'Tia, Kshlerin and Walter', N'kochsanford.co.uk', N'Fantastic Shoes', NULL, 0)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2099, N'cc 123', N'cc', N'cc1', 0x0000000000000065, 1)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2101, N'Content Test Site', N'http://localhost:49792/Site1', N'Conte', NULL, 1)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2102, N'site 2', N'http://localhost:49792/Site', N'Test', NULL, 1)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2103, N'Test Content Site2', N'http://localhost:49792/Site1', N'Test Content Site2', NULL, 1)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2104, N'aaaa', N'aaa', N'aaaa', NULL, 1)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2105, N'aaaa', N'aaaa', N'aaaa', NULL, 1)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2110, N'Site Test 101', N'http://localhost:49792/Site101', N'Site Test 101', NULL, 1)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2111, N'Site Test 102', N'http://localhost:49792/Site101', N'Site Test 102', NULL, 1)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2116, N'lsite', N'lsite', N'lsite', NULL, 1)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2122, N'virensite', N'virensite', N'virensite', NULL, 1)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2123, N's', N's', N's', NULL, 1)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2124, N'Viru 007', N'JamesBond Brother', N'Jab Tak hai James tab tak hai Bond', NULL, 1)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2125, N'GP', N'GP', N'GP', 0x52306C474F446C685A41426B4150634141414141414141414D7741415A6741416D5141417A4141412F774172414141724D7741725A6741726D5141727A4141722F774256414142564D7742565A6742566D5142567A4142562F774341414143414D7743415A6743416D5143417A4143412F774371414143714D7743715A6743716D5143717A4143712F774456414144564D7744565A6744566D5144567A4144562F77442F4141442F4D77442F5A67442F6D51442F7A41442F2F7A4D4141444D414D7A4D415A6A4D416D544D417A444D412F7A4D7241444D724D7A4D725A6A4D726D544D727A444D722F7A4E5641444E564D7A4E565A6A4E566D544E567A444E562F7A4F4141444F414D7A4F415A6A4F416D544F417A444F412F7A4F7141444F714D7A4F715A6A4F716D544F717A444F712F7A5056414450564D7A50565A6A50566D5450567A4450562F7A502F4144502F4D7A502F5A6A502F6D54502F7A44502F2F325941414759414D3259415A6D59416D5759417A4759412F325972414759724D3259725A6D59726D5759727A4759722F325A5641475A564D325A565A6D5A566D575A567A475A562F326141414761414D3261415A6D61416D5761417A4761412F326171414761714D3261715A6D61716D5761717A4761712F326256414762564D3262565A6D62566D5762567A4762562F32622F4147622F4D32622F5A6D622F6D57622F7A47622F2F356B41414A6B414D356B415A706B416D5A6B417A4A6B412F356B72414A6B724D356B725A706B726D5A6B727A4A6B722F356C56414A6C564D356C565A706C566D5A6C567A4A6C562F356D41414A6D414D356D415A706D416D5A6D417A4A6D412F356D71414A6D714D356D715A706D716D5A6D717A4A6D712F356E56414A6E564D356E565A706E566D5A6E567A4A6E562F356E2F414A6E2F4D356E2F5A706E2F6D5A6E2F7A4A6E2F2F387741414D77414D3877415A7377416D6377417A4D77412F387772414D77724D3877725A7377726D6377727A4D77722F387856414D78564D3878565A7378566D6378567A4D78562F387941414D79414D3879415A7379416D6379417A4D79412F387971414D79714D3879715A7379716D6379717A4D79712F387A56414D7A564D387A565A737A566D637A567A4D7A562F387A2F414D7A2F4D387A2F5A737A2F6D637A2F7A4D7A2F2F2F3841415038414D2F38415A7638416D6638417A5038412F2F3872415038724D2F38725A7638726D6638727A5038722F2F3956415039564D2F39565A7639566D6639567A5039562F2F2B4141502B414D2F2B415A762B416D662B417A502B412F2F2B7141502B714D2F2B715A762B716D662B717A502B712F2F2F5641502F564D2F2F565A762F566D662F567A502F562F2F2F2F41502F2F4D2F2F2F5A762F2F6D662F2F7A502F2F2F7741414141414141414141414141414143483542414541415077414C4141414141426B4147514141416A2F41472F6775484544686745414B684B716F4C4A77495A57484550315138554F78596B565572724A39793459746D7A5273324C35394D77634F6E446C7A726C79682B7367793544655435306779436F4D6A6A4D41625967674F7A436D5135733262413448714A4A677A786B474443526C43584271523473534C666A426D713657525930654E4A6375642F4F5A4B326B655148374F5668486E4F31694B634E584F7170556B7A5A317130624D57386C5575544330474442315841534B70514B644F4A543646692F4862316C56654E4C3075612B3461714D556873483058435844797A5A732B646C322B774857675A783561424D51624B7550465A7031454142684871626568337163536E676630516376557132797575306C794678487253334376486B4856334E476D7572433266596D54514C4733583838446D7064327978586C5462634855426C526B373876613463505845734F6A2F34714B6A57704733526B6C6B2F5339456E4C77623755556D2B4F31714B5A3936765933492B3835576B786F6754486B31427842427877467748594B646466616431714552346873723943476A57476F6344545653373131685570774853566D54692B32564B5A6666706952694E392B50474632673148614751414461716F31784E70663463575755573059595A4D6A6869534273354930472B61576A5332544857646667446659355A39314A6B71486D582F3533575255646761757870315333726E3246473231705054626872614E7442356A376D31346D306D386D474F4C47434E75687039624F636B6749482F564352546444516538364F4A423263576F46355A55614B486C647854524A69464767373255356D49724E57596D687566774D704E614A4C5A3548354D6F5A6C595558675945674E5232657A45305935626650555649684C2B7035456F71355A6C6B55692F5A72502F555655714B3973494C4C35593653576C6262313457526E2B5A3459435864746A70355364444D41416136454E5669466449536F686964467438764A77446A6F6149336D624C535A4C7557696B4F316F563736596E3579596D544158796969395142786959494B4B6D4545744B5976504B715773733361665A536A714E53786264744C794A2B477935316444314A3845346C306D534155544234476F43364D6179776C776F78384E5751467642534E4A7366763057563072324C32714B53744B2F55737130746B6A6A4A613848656975766D7743536D6939654C4D525345304D522F4A7656516C6738536B67713966726A4363636E2F3876496C62647143632B756B634F57336C6E3075347744315A55693664653665364C6134346F6F346937725178447444394B4172667A796F4D5A65313348707459784761724C516B6C54584E4B37686F5262335A74386A5A683171424D50442F4855444E4F4D515141326F4B5663786173684556306E5051737146535343306D74384E4C4C59306862664C536442556356786873736A6C317977665439506E5636474B3973475A634A77513278525976314B44695A63766D682B4B513332724C4B30476A41726B745330734339526C695343494A4A72786749677776783750447979364D4C4F4B35743561536935714C664C73494F4767347536747A6F4C5033504648504A6163392B62797632474B2B70476A5146496B6B77664379546A6E73784D2B4F5050504D33343738374A67442B5349425238326B474B5572335A52575A426E42775741764346774E444662676B4330515967742B674B436743454749516979436437654C53766E53566F7555345751523552434A4E374C686A524B57597833746D49634B6B57452F6471776A66696342427950734E6A70304D59774266594E427A6444434E596B6C6B433955534A62692F367041694757396268456D4D38743458494845454B567345597634786769783459334864416763374E44484D2B596E6A325449677833336532482B54734949756B48506A46686A5141775963414D326E71686D4D54444941672B34476B467077594662754F4F79484168464B4C7169676B527248755149387848686741557974556768506651786A324238555235666C4A38357871676D755A6B524C514A306F787031597257614C55794F436C5442466B615A787A7A6538593646324D4969436C47496F466D51455A446A794663495930554F66574D6579744148493963526A2F6D74343457525A4563357970474E536D72756B6D49346B413364534A444C384D53416E2B5261444F3459686931554D775A626D4F596F71376B4943724A79456139346852554A3834316430424962687651474F2B61526A30554B343454724F4159373468454D46395A546D426869524F6A4D6950384436746E41414D33734157633645344E2F477341474462414251634A67453461696A7145425969684474786D477836477A51794C4A4B47464B614D4A79424F4E2B7763684850756142546D2F414D78362F584963365475694E6237536A4863646357514152326F4D622B4B4148614D415051645A6F6C47626D545335417852756249436568516461697065616B52516D6C6146495779714D63367143664D373752456C7238457155704A5563747A4E474F6C45474E6E7763713041306163494D65334E51484F61324A34426A6749724C32414B632B4742696C4D6A65514C5542755772556F5279334D4B555552656B4F70354E44464F756178446C325167787A7259474535764F4B656A33696A467576777869354D43735A65344D526C414E77544777574B5537504B6853414E4D45704379786F4748357742423267416C32714265746B5069684E79653630464C55516957322F2F754F4B76484357484D4F51686A424969316F587969416438484274435772625570504C51427A3153323561594755437342444572576E3167453634643941426C7851466163584461455A31574F696D5A30434356656C5261584E53383241447350583372555862494D786E356B4D6376685348535A426A33472B765170543479515A503071546131574273725A383877335946673977414D554F674E43467A616F4D6F6C74554664684F566F495676493053496C4B544876625A58716A586F4767346F6D544F6B367667684D664D7844482F6B6F42785756756B37395A6B49743146574C4D672B41304C4C36774164754D4331422F676B44737471347754664971526836594A32634C67496A736E30464C55726D696936684A373370395159356472474F656F4B456F2B556768306E684F57495679694D6639723079666B2B384433306F673257586653363666467857417150682F38597261734242733074674D63533162754343734C78716F655149335262444745614665546D3843393275417A4A562F437335796D4653784D6244475A4355427A4A47366733696C6B4D595A4E594847756836576E55426C4B786E7A62455043494A4448373831726B5147463358745535505A76454952745A694E6B3647566B7478456D5261464473593553306A4663755136735A4765687866786B597A486D5053585764544850744A6E5A37566B5673316A7458474F33564454477869416D64534E4B33656846746377424F30567377456E686D6544455657566C425A54586B637433454E466B4878444639373470534E544F673949736E4D58306E6A734D4E6D52447866445264734262434E42626F6F474972785A3444657767566B626E4771356644634D70314A455370366C694C457473647A6F6E4731656438467534647857797345494269392F655178495172726637502B67346A66674E326C6C37774D5461456244676672326152745074396F4D6145424E462B34443154595834685630525346654C58526F795174524B586D735A48576849317466564E473655496649707837704C2B73534775786F36516E6C7355686C38786463333331327A57316338446633674D335A746A4E4E76747471634450786A7847532B4E673456753748346E6F587330496E6568524E5A5370584F52377952595938544B7A4C4D75735666766A4952356E314D51797767347649705373515755474E55794C634E4F485237546E626D2B31744373356D4E732F36664952797036713763397852717471774C6E5168386850755675516C682B517A394C75506557535A33386C7765544B654236356B71697568627657427764483631724953756547705A69674663516675304176746A36676739327830633951755653354847345A7350515550535754774D68364148377A2F666B56716A6E4B59754E2F37324D63776773796D5655652B356D38316134374E577462736F714868344B726734696A494D632B444F2F71705232455878692B6C683274564A6D6D534A6D7A31356C5350706B4B4D39464C447745346E706D794D78302B62686935697855594E6F4630465233787668514E45426D4862426E47793430335235336B2F457A5431676D47324E5234586C32473446677A4934456A4349486A4A5147776A3951774B4347627938314C3041476136464133364D416C42686C70744D584D593646616E4A6D6F676D4731424268646134486B6C7144694B383065664633336C316D515534594961704175374D485873454179374A586A496F49426542462F4A55442F737341736D6F556769565759764279374E39577A596858625464515A45634161634A515951526C304F4A44754B34336E52707A694D5132757563474662574969304548496856344F4F2F7953443749414D5A4467507A7242434A4C5A555774454F796C56342B694147512B614A4952685770544E575A3955446F745A5A647059666636682F565269497A696337414A67536956676F6A43674D3632434C77694347596368434E6F69414C4F5243544756537539414F6934522B3950426463515655416A52356D57643242356432636455672F45644251684F496E68654973536830466B455274644349776E414D7552694F344267507579554D776B434F596568437577412F7855565A376D426D79745A346E524E6B7061564D6F7768715A33566A626F5A614F4A464850554F462B686430324768786637534E6674434E5968694F43536D477433694F7556686C5535646C3550414E5944525A6A46594F784B6866363564614970685A6F6856744E58566A6144414562375A747A43574E736E457141766C486753676266794130754F4D55464645493372695143696D476A6639595A655667574962466179745866696342502B7A51645A725765327158576A50325843435A6A775133676C46494264354551643355546462594F5055696B7853684344695A693869676B4F466F69794B6E43384D4562787957614575465266475451726D6B443776336955536D6A4D73456B6B31346679554A595673416C5952514E767258664E4D344F31614A6C595777433135706A6C73356463486761347A475956706D62436F3354467A4644734F516B667441684A375965364749675457336757596C58572F57585671674258705A5159705143496F4152666F584741555A486E3677434A637767376C6F504D47414354675A444C74516D2B57675642796D56464A305779444259666379536665546B664F77615848466B584335526E566F664B4E325936556C68784D556C52573053743145434647596B6D627A4549555143567470504B2B4A6B37567054704F566D787A2F56554C33556B58755A6C496E4155592B75463970345779582B567731526C5A4E4B46336335514F6D31443056524A714271415774684A645A755169526F4A30344B5A7668534B4343575A7530674A74534A4A354C31564A48425749745A51374363442F6D51412F4C3957436F31577A676F6D5948774977334D41464E75493968384A7A385351694C4D4A714B34454346414A55566B5A31664B517A47303555774F71507445776D3755467534785A753630564B7A315665384E70356163524C454F41783879446D6647415963655341384E586B3774357A5A356F2F5269614A34524A31505755534563416E4263416B77656779594149356143707643554A753649467361466C3644526B56484A554C664D4673663135694F4F5A535A67424E7870573051396D7765436F4C7A32584D6A3269417143676146344B656679534153775A6F7A436F3763795A327875517552554745582F355A3066325A623563476A55725275786A61704968476B784F67377A5056672F6555446D4F6C6A457942676F2F5A6D4F5247465562674967466F496E7A6C4244514B567771436C5836716C5766717172376F4C4174696F5A59704F585046586B797170566D5357773453707955435A664D68646E4170414E4A61634173465A4E7A5551712F716E716770786756704572556F496D414372744571726C314362735A5767754A7068682F6858316164306166706B746F574A50386C565A3861522F7756556E6771667A4269713948645449306F46304D71667079516F33504D516B58414A31337174727971626D5043644175676C4639616F7272436D536861703162656D363261754B756567576A45507778426A4E6246704A6F6D734275436879376D5A4F4141477A776F474942756F646751526933437476414372574B716F736956687445414974504173474E596C4233745554663947726B706C534F313257306356517556674576507759686C4B703534595A433669526A366D637A7148707A66776D617061537175364C4943684266324B436631716F34753671416B4B6145703269497251745268325964556E675041424C52663163533231636A394A4433466172474941504B69566F632F566F6447477078344C73715A4543434F714168674445594B694171777043597136433474776F774A344B696B6861364233694C524259516C7258724C6C73427032746C535573476B6251735752444D54706958544B4F6168316251676D59475131415A7846454947694258757142596A44747A74447451464B433471516F4C477275426747626D327A5A495177617866575A39374B46617179496561716D2F65436B636D515A352B497363594A7233584C72445731717161454D64433746436F514270477743432F37527A4E4C59586456595738487475436158676E2F326D635952726D5247784B584377377A6B415A75433248416F336276476C71672B71456775434B722B706C626B43782F4378454D464C74796C7849535667744942467577396A6A2F2B336C4F78727464693742496C78755061726B695951363778317751316F6565694B7A783255786E64514E675141576D4241505179377065453457666837323547384249424534554E6E3246634C3168793767495332766F6848306751554C6B524A46706742504747594A4469776167473230333441426E56332F54354D484A55735464735244557548775239327176634D4B3041453635573353494F3332416C726752676E525A6D48465142682F66514B53626872795675576C7046674D4E774B545A4A56424E2B356C47374241796F674C582B45656A575545784F3842664B3345534E734A55334C563354477449687837685A53456A4E42495537462B7042547A4636514D4D51474E4A2F797467316562426646764551635333565A4151555268366364784E46536468335652306F636645654F774B4655664339464A7566587865452B494E3443414D78616D68587778556D775A41484876474261473647474D6C574D4B333168694930326D4E2B68657A5674677A7A3565346954764B715A654654795A4F694D454C6E4E7357794A7568333455475973574D6B7A647130795178566C4C4C6C4A795370456B496365783555666D7976437737304A6645477A504B394A495371594268325A4153362F77536B72444B58357968594278585937653078586364717473516F61495131456C422B48714E33677964465446334B6D69464A59694638764A2F67495A3946364C4D6E4E74733743656E78627070637561686F5172457378784B4363464167554B647172724E4969794E654D6D6969314F43516A4F4E2B3465467A7765417868776D3570434B72527A50725A794D50502F737777345158665648527A69544C4A534D52317167434537627A365A71705138684B424B7866314A6F4E6F58534F46595A693432787A766343447133386958484C68383347682B7848742F4862414E52634D524F54505644356D66304D6C52314E31684A4531684C524945526B6E66736E4F33365143724A78306C69594B6C34434D6A673874465A4E6E4A78546E4A386262547148303646714A51756B4550614C75695272716E6E6B747A5453494E59704732684E30686F5446593154752B456B456D7443716D426368444C74695A7357756B6E72413178394631625346336D3070783174536C4B727230596B74583751494B6261326E2F77505259684E4C4134477939704F544B3079764B633177383230616946744B4256667A585641416E30316335627634457174547A6474307678494B394E31673952524357346A5974724B476643437A5439746E484C726D44387974442F7249466C5256595559464D4A4E396F394862583579394E384F7970615541584C3074727772612B745768462F344E5A6D4132342F7779573273417563766431576264554E527346784264366D5A6C4D316C5365507242663543736D51764E344D5563744B4964396B62556331347470756252464A6A43727873626E417739332B50644E38794D4F654C622B684F6D72586F52304B727271423475445A7339354A4D614B4934397037564E536C55694E483354334D7879584D45394D5A79747678664672784445422B4C57414762754A7970454F30764263594D7A45667A42646163414F59454159306E74684C6F6139455464516149792B6458443632344F47627532724761645855396355626D334D2B2F49466F5442436F6F5158544A457057596A6771774541597730414B68776C6F774C724A5862495255654E6B445A326E556A4C3876637057766473677A7463634356444A2F396B44514E794564735931524B7A547168507058614E514E7441475A2F4467582F5067565237646531354273304D32516D6379685A37583230336F7874765A4F52656649666D4532715A44422F52445835306771354677444942542B4D75367135766159685064327179434A544E4478696E54684E3573687A7A524147586D66333157714A56544E6D484573533759566F4A3544484147642B37673176345864786E64524E524B3374526B61424473654C335A38457A7133313752506C7A6951535A517166587147673071444451784F335A744F4A557A7962494351625461716A305249757A706538625A764133503465376248486E6F416A6536354E317A78636F314D5049694F783370656B48724232574B716F4D73724748765443456F73434F4E3369546D646762754D553263332F356D49593957356236787A446871783065717A5A3464444B3843414441344B4B34366F50396C45477A6B42714843354F763977564C375146594B69476967766A47643179412F70392F2B34596463302B41646B714F7161674F6846396D78416F544438704665566A6141467A5A6741323767315963544E6B58744F717261326C427051544A7436484D61346E7849386945763869525038694D65717657335857493856696A75496936504D396E52544A7A4341417A67426C75677A3961753834476971747A446E38424F36422B7639742F6538644D3138742B4F5930686259774B6C6566794939793679384A6176416C545056763630397A65514D394772326F4B433271333954633157394B514B3930522F396D6E2F5A6D37412B6D5748426D36415947554D6B6A594667702B3149686A34496A472F4856527662644D4441776E6D426D4741763646765248626B514F317452345851385761662B463873386F30502F6350582B71372F3751626E426D376B566E68615A38332F5A4733714D6A306F2F6949375A6D307159414D3042674D4A6C7A366E35492F342B6766347171716D57676963492B776375666A4C6A766252442F733442767346357759413451614E477A63484774686F63434F686A78732B6350544163654F47415159774446794D41514347526741786574693441554D6B44433077776F4142633059536F55557343525571524F6A6C7A4A6946746851536779626E546A5136652B4C5136614F6E554B4A756641676B4D6E446755615545337A4251714C44484459686E4A457173654F436956674D78444D425163534D4D6A7A416A743268427551584D6F6B695346433243473364524962677759634A467738686E5468396969504964326E4F6F774B56763042424A342B614E596A6445444263386D4C44685A495933596A4334654E486931526868656F514A6F2B5873575442714637324E56486452726457746137466D4C556D32704442362F336E2B444577555464486452675553424D353073574B6F435364516E597731713055444230434745515036354E6C43697172546C6275493132725972336D395A72524C4569394D73686C4A59725349746951785A334B694F644F7A7832436D5364306B52757A6D422B50462F517357702B716871323567774B764D594F674D756B564F576D514C363679623636316146486C746B563165712B5643586E61785A5A634E655146785046736B57595352534E4A44517A314A34684E73747A6145456F697078684944377266372B414D776F616B55597141696972714351534C6F776C677751727171777A444A444A6638376B4D506177485251784158736157573945676B4D55564A3447755271614F51476B6767772F6F62726A394D476B684952346B5373754579725377796955676957314B4E753163556559553744446D38304A786477506C7A467A3942424E4757377A71306B6C5531453946726138737A667173767A4D534B63476F672F7A496854716F626A6A754F67514D7145696B474730444C72727461586B6E794777792F32655562567330706878647A5A715631316E4C4D346155635737367073734D4F767874764E6B79617174452F2F68517A3877316C50776B494144733D, 1)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2126, N'SA', N'SA', N'SA', 0x52306C474F446C685A41426B4150634141414141414141414D7741415A6741416D5141417A4141412F774172414141724D7741725A6741726D5141727A4141722F774256414142564D7742565A6742566D5142567A4142562F774341414143414D7743415A6743416D5143417A4143412F774371414143714D7743715A6743716D5143717A4143712F774456414144564D7744565A6744566D5144567A4144562F77442F4141442F4D77442F5A67442F6D51442F7A41442F2F7A4D4141444D414D7A4D415A6A4D416D544D417A444D412F7A4D7241444D724D7A4D725A6A4D726D544D727A444D722F7A4E5641444E564D7A4E565A6A4E566D544E567A444E562F7A4F4141444F414D7A4F415A6A4F416D544F417A444F412F7A4F7141444F714D7A4F715A6A4F716D544F717A444F712F7A5056414450564D7A50565A6A50566D5450567A4450562F7A502F4144502F4D7A502F5A6A502F6D54502F7A44502F2F325941414759414D3259415A6D59416D5759417A4759412F325972414759724D3259725A6D59726D5759727A4759722F325A5641475A564D325A565A6D5A566D575A567A475A562F326141414761414D3261415A6D61416D5761417A4761412F326171414761714D3261715A6D61716D5761717A4761712F326256414762564D3262565A6D62566D5762567A4762562F32622F4147622F4D32622F5A6D622F6D57622F7A47622F2F356B41414A6B414D356B415A706B416D5A6B417A4A6B412F356B72414A6B724D356B725A706B726D5A6B727A4A6B722F356C56414A6C564D356C565A706C566D5A6C567A4A6C562F356D41414A6D414D356D415A706D416D5A6D417A4A6D412F356D71414A6D714D356D715A706D716D5A6D717A4A6D712F356E56414A6E564D356E565A706E566D5A6E567A4A6E562F356E2F414A6E2F4D356E2F5A706E2F6D5A6E2F7A4A6E2F2F387741414D77414D3877415A7377416D6377417A4D77412F387772414D77724D3877725A7377726D6377727A4D77722F387856414D78564D3878565A7378566D6378567A4D78562F387941414D79414D3879415A7379416D6379417A4D79412F387971414D79714D3879715A7379716D6379717A4D79712F387A56414D7A564D387A565A737A566D637A567A4D7A562F387A2F414D7A2F4D387A2F5A737A2F6D637A2F7A4D7A2F2F2F3841415038414D2F38415A7638416D6638417A5038412F2F3872415038724D2F38725A7638726D6638727A5038722F2F3956415039564D2F39565A7639566D6639567A5039562F2F2B4141502B414D2F2B415A762B416D662B417A502B412F2F2B7141502B714D2F2B715A762B716D662B717A502B712F2F2F5641502F564D2F2F565A762F566D662F567A502F562F2F2F2F41502F2F4D2F2F2F5A762F2F6D662F2F7A502F2F2F7741414141414141414141414141414143483542414541415077414C4141414141426B4147514141416A2F41472F6775484544686745414B684B716F4C4A77495A57484550315138554F78596B565572724A39793459746D7A5273324C35394D77634F6E446C7A726C79682B7367793544655435306779436F4D6A6A4D41625967674F7A436D5135733262413448714A4A677A786B474443526C43584271523473534C666A426D713657525930654E4A6375642F4F5A4B326B655148374F5668486E4F31694B634E584F7170556B7A5A317130624D57386C5575544330474442315841534B70514B644F4A543646692F4862316C56654E4C3075612B3461714D556873483058435844797A5A732B646C322B774857675A783561424D51624B7550465A7031454142684871626568337163536E676630516376557132797575306C794678487253334376486B4856334E476D7572433266596D54514C4733583838446D7064327978586C5462634855426C526B373876613463505845734F6A2F34714B6A57704733526B6C6B2F5339456E4C77623755556D2B4F31714B5A3936765933492B3835576B786F6754486B31427842427877467748594B646466616431714552346873723943476A57476F6344545653373131685570774853566D54692B32564B5A6666706952694E392B50474632673148614751414461716F31784E70663463575755573059595A4D6A6869534273354930472B61576A5332544857646667446659355A39314A6B71486D582F3533575255646761757870315333726E3246473231705054626872614E7442356A376D31346D306D386D474F4C47434E75687039624F636B6749482F564352546444516538364F4A423263576F46355A55614B486C647854524A69464767373255356D49724E57596D687566774D704E614A4C5A3548354D6F5A6C595558675945674E5232657A45305935626650555649684C2B7035456F71355A6C6B55692F5A72502F555655714B3973494C4C35593653576C6262313457526E2B5A3459435864746A70355364444D41416136454E5669466449536F686964467438764A77446A6F6149336D624C535A4C7557696B4F316F563736596E3579596D544158796969395142786959494B4B6D4545744B5976504B715773733361665A536A714E53786264744C794A2B477935316444314A3845346C306D534155544234476F43364D6179776C776F78384E5751467642534E4A7366763057563072324C32714B53744B2F55737130746B6A6A4A613848656975766D7743536D6939654C4D525345304D522F4A7656516C6738536B67713966726A4363636E2F3876496C62647143632B756B634F57336C6E3075347744315A55693664653665364C6134346F6F346937725178447444394B4172667A796F4D5A65313348707459784761724C516B6C54584E4B37686F5262335A74386A5A683171424D50442F4855444E4F4D515141326F4B5663786173684556306E5051737146535343306D74384E4C4C59306862664C536442556356786873736A6C317977665439506E5636474B3973475A634A77513278525976314B44695A63766D682B4B513332724C4B30476A41726B745330734339526C695343494A4A72786749677776783750447979364D4C4F4B35743561536935714C664C73494F4767347536747A6F4C5033504648504A6163392B62797632474B2B70476A5146496B6B77664379546A6E73784D2B4F5050504D33343738374A67442B5349425238326B474B5572335A52575A426E42775741764346774E444662676B4330515967742B674B436743454749516979436437654C53766E53566F7555345751523552434A4E374C686A524B57597833746D49634B6B57452F6471776A66696342427950734E6A70304D59774266594E427A6444434E596B6C6B433955534A62692F367041694757396268456D4D38743458494845454B567345597634786769783459334864416763374E44484D2B596E6A325449677833336532482B54734949756B48506A46686A5141775963414D326E71686D4D54444941672B34476B467077594662754F4F79484168464B4C7169676B527248755149387848686741557974556768506651786A324238555235666C4A38357871676D755A6B524C514A306F787031597257614C55794F436C5442466B615A787A7A6538593646324D4969436C47496F466D51455A446A794663495930554F66574D6579744148493963526A2F6D74343457525A4563357970474E536D72756B6D49346B413364534A444C384D53416E2B5261444F3459686931554D775A626D4F596F71376B4943724A79456139346852554A3834316430424962687651474F2B61526A30554B343454724F4159373468454D46395A546D426869524F6A4D6950384436746E41414D33734157633645344E2F477341474462414251634A67453461696A7145425969684474786D477836477A51794C4A4B47464B614D4A79424F4E2B7763684850756142546D2F414D78362F584963365475694E6237536A4863646357514152326F4D622B4B4148614D415051645A6F6C47626D545335417852756249436568516461697065616B52516D6C6146495779714D63367143664D373752456C7238457155704A5563747A4E474F6C45474E6E7763713041306163494D65334E51484F61324A34426A6749724C32414B632B4742696C4D6A65514C5542755772556F5279334D4B555552656B4F70354E44464F756178446C325167787A7259474535764F4B656A33696A467576777869354D43735A65344D526C414E77544777574B5537504B6853414E4D45704379786F4748357742423267416C32714265746B5069684E79653630464C55516957322F2F754F4B76484357484D4F51686A424969316F587969416438484274435772625570504C51427A3153323561594755437342444572576E3167453634643941426C7851466163584461455A31574F696D5A30434356656C5261584E53383241447350583372555862494D786E356B4D6376685348535A426A33472B765170543479515A503071546131574273725A383877335946673977414D554F674E43467A616F4D6F6C74554664684F566F495676493053496C4B544876625A58716A586F4767346F6D544F6B367667684D664D7844482F6B6F42785756756B37395A6B49743146574C4D672B41304C4C36774164754D4331422F676B44737471347754664971526836594A32634C67496A736E30464C55726D696936684A373370395159356472474F656F4B456F2B556768306E684F57495679694D6639723079666B2B384433306F673257586653363666467857417150682F38597261734242733074674D63533162754343734C78716F655149335262444745614665546D3843393275417A4A562F437335796D4653784D6244475A4355427A4A47366733696C6B4D595A4E594847756836576E55426C4B786E7A62455043494A4448373831726B5147463358745535505A76454952745A694E6B3647566B7478456D5261464473593553306A4663755136735A4765687866786B597A486D5053585764544850744A6E5A37566B5673316A7458474F33564454477869416D64534E4B33656846746377424F30567377456E686D6544455657566C425A54586B637433454E466B4878444639373470534E544F673949736E4D58306E6A734D4E6D52447866445264734262434E42626F6F474972785A3444657767566B626E4771356644634D70314A455370366C694C457473647A6F6E4731656438467534647857797345494269392F655178495172726637502B67346A66674E326C6C37774D5461456244676672326152745074396F4D6145424E462B34443154595834685630525346654C58526F795174524B586D735A48576849317466564E473655496649707837704C2B73534775786F36516E6C7355686C38786463333331327A57316338446633674D335A746A4E4E76747471634450786A7847532B4E673456753748346E6F587330496E6568524E5A5370584F52377952595938544B7A4C4D75735666766A4952356E314D51797767347649705373515755474E55794C634E4F485237546E626D2B31744373356D4E732F36664952797036713763397852717471774C6E5168386850755675516C682B517A394C75506557535A33386C7765544B654236356B71697568627657427764483631724953756547705A69674663516675304176746A36676739327830633951755653354847345A7350515550535754774D68364148377A2F666B56716A6E4B59754E2F37324D63776773796D5655652B356D38316134374E577462736F714868344B726734696A494D632B444F2F71705232455878692B6C683274564A6D6D534A6D7A31356C5350706B4B4D39464C447745346E706D794D78302B62686935697855594E6F4630465233787668514E45426D4862426E47793430335235336B2F457A5431676D47324E5234586C32473446677A4934456A4349486A4A5147776A3951774B4347627938314C3041476136464133364D416C42686C70744D584D593646616E4A6D6F676D4731424268646134486B6C7144694B383065664633336C316D515534594961704175374D485873454179374A586A496F49426542462F4A55442F737341736D6F556769565759764279374E39577A596858625464515A45634161634A515951526C304F4A44754B34336E52707A694D5132757563474662574969304548496856344F4F2F7953443749414D5A4467507A7242434A4C5A555774454F796C56342B694147512B614A4952685770544E575A3955446F745A5A647059666636682F565269497A696337414A67536956676F6A43674D3632434C77694347596368434E6F69414C4F5243544756537539414F6934522B3950426463515655416A52356D57643242356432636455672F45644251684F496E68654973536830466B455274644349776E414D7552694F344267507579554D776B434F596568437577412F7855565A376D426D79745A346E524E6B7061564D6F7768715A33566A626F5A614F4A464850554F462B686430324768786637534E6674434E5968694F43536D477433694F7556686C5535646C3550414E5944525A6A46594F784B6866363564614970685A6F6856744E58566A6144414562375A747A43574E736E457141766C486753676266794130754F4D55464645493372695143696D476A6639595A655667574962466179745866696342502B7A51645A725765327158576A50325843435A6A775133676C46494264354551643355546462594F5055696B7853684344695A693869676B4F466F69794B6E43384D4562787957614575465266475451726D6B443776336955536D6A4D73456B6B31346679554A595673416C5952514E767258664E4D344F31614A6C595777433135706A6C73356463486761347A475956706D62436F3354467A4644734F516B667441684A375965364749675457336757596C58572F57585671674258705A5159705143496F4152666F584741555A486E3677434A637767376C6F504D47414354675A444C74516D2B57675642796D56464A305779444259666379536665546B664F77615848466B584335526E566F664B4E325936556C68784D556C52573053743145434647596B6D627A4549555143567470504B2B4A6B37567054704F566D787A2F56554C33556B58755A6C496E4155592B75463970345779582B567731526C5A4E4B46336335514F6D31443056524A714271415774684A645A755169526F4A30344B5A7668534B4343575A7530674A74534A4A354C31564A48425749745A51374363442F6D51412F4C3957436F31577A676F6D5948774977334D41464E75493968384A7A385351694C4D4A714B34454346414A55566B5A31664B517A47303555774F71507445776D3755467534785A753630564B7A315665384E70356163524C454F41783879446D6647415963655341384E586B3774357A5A356F2F5269614A34524A31505755534563416E4263416B77656779594149356143707643554A753649467361466C3644526B56484A554C664D4673663135694F4F5A535A67424E7870573051396D7765436F4C7A32584D6A3269417143676146344B656679534153775A6F7A436F3763795A327875517552554745582F355A3066325A623563476A55725275786A61704968476B784F67377A5056672F6555446D4F6C6A457942676F2F5A6D4F5247465562674967466F496E7A6C4244514B567771436C5836716C5766717172376F4C4174696F5A59704F585046586B797170566D5357773453707955435A664D68646E4170414E4A61634173465A4E7A5551712F716E716770786756704572556F496D414372744571726C314362735A5767754A7068682F6858316164306166706B746F574A50386C565A3861522F7756556E6771667A4269713948645449306F46304D71667079516F33504D516B58414A31337174727971626D5043644175676C4639616F7272436D536861703162656D363261754B756567576A45507778426A4E6246704A6F6D734275436879376D5A4F4141477A776F474942756F646751526933437476414372574B716F736956687445414974504173474E596C4233745554663947726B706C534F313257306356517556674576507759686C4B703534595A433669526A366D637A7148707A66776D617061537175364C4943684266324B436631716F34753671416B4B6145703269497251745268325964556E675041424C52663163533231636A394A4433466172474941504B69566F632F566F6447477078344C73715A4543434F714168674445594B694171777043597136433474776F774A344B696B6861364233694C524259516C7258724C6C73427032746C535573476B6251735752444D54706958544B4F6168316251676D59475131415A7846454947694258757142596A44747A74447451464B433471516F4C477275426747626D327A5A495177617866575A39374B46617179496561716D2F65436B636D515A352B497363594A7233584C72445731717161454D64433746436F514270477743432F37527A4E4C59586456595738487475436158676E2F326D635952726D5247784B584377377A6B415A75433248416F336276476C71672B71456775434B722B706C626B43782F4378454D464C74796C7849535667744942467577396A6A2F2B336C4F78727464693742496C78755061726B695951363778317751316F6565694B7A783255786E64514E675141576D4241505179377065453457666837323547384249424534554E6E3246634C3168793767495332766F6848306751554C6B524A46706742504747594A4469776167473230333441426E56332F54354D484A55735464735244557548775239327176634D4B3041453635573353494F3332416C726752676E525A6D48465142682F66514B53626872795675576C7046674D4E774B545A4A56424E2B356C47374241796F674C582B45656A575545784F3842664B3345534E734A55334C563354477449687837685A53456A4E42495537462B7042547A4636514D4D51474E4A2F797467316562426646764551635333565A4151555268366364784E46536468335652306F636645654F774B4655664339464A7566587865452B494E3443414D78616D68587778556D775A41484876474261473647474D6C574D4B333168694930326D4E2B68657A5674677A7A3565346954764B715A654654795A4F694D454C6E4E7357794A7568333455475973574D6B7A647130795178566C4C4C6C4A795370456B496365783555666D7976437737304A6645477A504B394A495371594268325A4153362F77536B72444B58357968594278585937653078586364717473516F61495131456C422B48714E33677964465446334B6D69464A59694638764A2F67495A3946364C4D6E4E74733743656E78627070637561686F5172457378784B4363464167554B647172724E4969794E654D6D6969314F43516A4F4E2B3465467A7765417868776D3570434B72527A50725A794D50502F737777345158665648527A69544C4A534D52317167434537627A365A71705138684B424B7866314A6F4E6F58534F46595A693432787A766343447133386958484C68383347682B7848742F4862414E52634D524F54505644356D66304D6C52314E31684A4531684C524945526B6E66736E4F33365143724A78306C69594B6C34434D6A673874465A4E6E4A78546E4A386262547148303646714A51756B4550614C75695272716E6E6B747A5453494E59704732684E30686F5446593154752B456B456D7443716D426368444C74695A7357756B6E72413178394631625346336D3070783174536C4B727230596B74583751494B6261326E2F77505259684E4C4134477939704F544B3079764B633177383230616946744B4256667A585641416E30316335627634457174547A6474307678494B394E31673952524357346A5974724B476643437A5439746E484C726D44387974442F7249466C5256595559464D4A4E396F394862583579394E384F7970615541584C3074727772612B745768462F344E5A6D4132342F7779573273417563766431576264554E527346784264366D5A6C4D316C5365507242663543736D51764E344D5563744B4964396B62556331347470756252464A6A43727873626E417739332B50644E38794D4F654C622B684F6D72586F52304B727271423475445A7339354A4D614B4934397037564E536C55694E483354334D7879584D45394D5A79747678664672784445422B4C57414762754A7970454F30764263594D7A45667A42646163414F59454159306E74684C6F6139455464516149792B6458443632344F47627532724761645855396355626D334D2B2F49466F5442436F6F5158544A457057596A6771774541597730414B68776C6F774C724A5862495255654E6B445A326E556A4C3876637057766473677A7463634356444A2F396B44514E794564735931524B7A547168507058614E514E7441475A2F4467582F5067565237646531354273304D32516D6379685A37583230336F7874765A4F52656649666D4532715A44422F52445835306771354677444942542B4D75367135766159685064327179434A544E4478696E54684E3573687A7A524147586D66333157714A56544E6D484573533759566F4A3544484147642B37673176345864786E64524E524B3374526B61424473654C335A38457A7133313752506C7A6951535A517166587147673071444451784F335A744F4A557A7962494351625461716A305249757A706538625A764133503465376248486E6F416A6536354E317A78636F314D5049694F783370656B48724232574B716F4D73724748765443456F73434F4E3369546D646762754D553263332F356D49593957356236787A446871783065717A5A3464444B3843414441344B4B34366F50396C45477A6B42714843354F763977564C375146594B69476967766A47643179412F70392F2B34596463302B41646B714F7161674F6846396D78416F544438704665566A6141467A5A6741323767315963544E6B58744F717261326C427051544A7436484D61346E7849386945763869525038694D65717657335857493856696A75496936504D396E52544A7A4341417A67426C75677A3961753834476971747A446E38424F36422B7639742F6538644D3138742B4F5930686259774B6C6566794939793679384A6176416C545056763630397A65514D394772326F4B433271333954633157394B514B3930522F396D6E2F5A6D37412B6D5748426D36415947554D6B6A594667702B3149686A34496A472F4856527662644D4441776E6D426D4741763646765248626B514F317452345851385761662B463873386F30502F6350582B71372F3751626E426D376B566E68615A38332F5A4733714D6A306F2F6949375A6D307159414D3042674D4A6C7A366E35492F342B6766347171716D57676963492B776375666A4C6A766252442F733442767346357759413451614E477A63484774686F63434F686A78732B6350544163654F47415159774446794D41514347526741786574693441554D6B44433077776F4142633059536F55557343525571524F6A6C7A4A6946746851536779626E546A5136652B4C5136614F6E554B4A756641676B4D6E446755615545337A4251714C44484459686E4A457173654F436956674D78444D425163534D4D6A7A416A743268427551584D6F6B695346433243473364524962677759634A467738686E5468396969504964326E4F6F774B56763042424A342B614E596A6445444263386D4C44685A495933596A4334654E486931526868656F514A6F2B5873575442714637324E56486452726457746137466D4C556D32704442362F336E2B444577555464486452675553424D353073574B6F435364516E597731713055444230434745515036354E6C43697172546C6275493132725972336D395A72524C4569394D73686C4A59725349746951785A334B694F644F7A7832436D5364306B52757A6D422B50462F517357702B716871323567774B764D594F674D756B564F576D514C363679623636316146486C746B563165712B5643586E61785A5A634E655146785046736B57595352534E4A44517A314A34684E73747A6145456F697078684944377266372B414D776F616B55597141696972714351534C6F776C677751727171777A444A444A6638376B4D506177485251784158736157573945676B4D55564A3447755271614F51476B6767772F6F62726A394D476B684952346B5373754579725377796955676957314B4E753163556559553744446D38304A786477506C7A467A3942424E4757377A71306B6C5531453946726138737A667173767A4D534B63476F672F7A496854716F626A6A754F67514D7145696B474730444C72727461586B6E794777792F32655562567330706878647A5A715631316E4C4D346155635737367073734D4F767874764E6B79617174452F2F68517A3877316C50776B494144733D, 1)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2127, N'GVPp', N'GVPp', N'GVPp', 0x52306C474F446C685A41426B4150634141414141414141414D7741415A6741416D5141417A4141412F774172414141724D7741725A6741726D5141727A4141722F774256414142564D7742565A6742566D5142567A4142562F774341414143414D7743415A6743416D5143417A4143412F774371414143714D7743715A6743716D5143717A4143712F774456414144564D7744565A6744566D5144567A4144562F77442F4141442F4D77442F5A67442F6D51442F7A41442F2F7A4D4141444D414D7A4D415A6A4D416D544D417A444D412F7A4D7241444D724D7A4D725A6A4D726D544D727A444D722F7A4E5641444E564D7A4E565A6A4E566D544E567A444E562F7A4F4141444F414D7A4F415A6A4F416D544F417A444F412F7A4F7141444F714D7A4F715A6A4F716D544F717A444F712F7A5056414450564D7A50565A6A50566D5450567A4450562F7A502F4144502F4D7A502F5A6A502F6D54502F7A44502F2F325941414759414D3259415A6D59416D5759417A4759412F325972414759724D3259725A6D59726D5759727A4759722F325A5641475A564D325A565A6D5A566D575A567A475A562F326141414761414D3261415A6D61416D5761417A4761412F326171414761714D3261715A6D61716D5761717A4761712F326256414762564D3262565A6D62566D5762567A4762562F32622F4147622F4D32622F5A6D622F6D57622F7A47622F2F356B41414A6B414D356B415A706B416D5A6B417A4A6B412F356B72414A6B724D356B725A706B726D5A6B727A4A6B722F356C56414A6C564D356C565A706C566D5A6C567A4A6C562F356D41414A6D414D356D415A706D416D5A6D417A4A6D412F356D71414A6D714D356D715A706D716D5A6D717A4A6D712F356E56414A6E564D356E565A706E566D5A6E567A4A6E562F356E2F414A6E2F4D356E2F5A706E2F6D5A6E2F7A4A6E2F2F387741414D77414D3877415A7377416D6377417A4D77412F387772414D77724D3877725A7377726D6377727A4D77722F387856414D78564D3878565A7378566D6378567A4D78562F387941414D79414D3879415A7379416D6379417A4D79412F387971414D79714D3879715A7379716D6379717A4D79712F387A56414D7A564D387A565A737A566D637A567A4D7A562F387A2F414D7A2F4D387A2F5A737A2F6D637A2F7A4D7A2F2F2F3841415038414D2F38415A7638416D6638417A5038412F2F3872415038724D2F38725A7638726D6638727A5038722F2F3956415039564D2F39565A7639566D6639567A5039562F2F2B4141502B414D2F2B415A762B416D662B417A502B412F2F2B7141502B714D2F2B715A762B716D662B717A502B712F2F2F5641502F564D2F2F565A762F566D662F567A502F562F2F2F2F41502F2F4D2F2F2F5A762F2F6D662F2F7A502F2F2F7741414141414141414141414141414143483542414541415077414C4141414141426B4147514141416A2F41414549484569776F4D474443424D71584D69776F634F4845434E4B6E4569786F73574C47444E71334D69786F38655049454F4B48456D795A455A31384E61706937657970636D58437457706A4C634F586A79624F477665684D6B54674D79634E7466646A4464307145313150556E4B764C6D75706C436252496C434A57705061744B507749544B58446B316172783758384E4B765766543239574E7756727146456F55724E7533582B2B427062727A3745564C5735305762527350337A3135392F7A3668667656706C324C575A653239417057634744482B41624C6A517276384D52584D6F4F6C6A4A644D3254783858774644666978346347477936797848704657724A544A6C792F624A3367633463462F537543504C6456745A39634E6133744C4B55305A4D6A4A684D7376574A666B773673765041627133365A6B6A4C5657764F6D67774145494F476D4F7838665573372F33382B666E4C5636517872735359586A39674E41444755375A4F2F5435396333654C4C4F3559614437314357742B3473733439773851417741706F30424F4E62505130316C782B7A3031476C6E384A7166664B674155436341414D4D5869334433696C506169666154663152694642366758497A6A334A5A444C514166514264747434492B49334756456E456B534C4E392F51516F73356667307A4358664579446350555348534F474A30384A6834496F413952716C624D706F517030777966496C476E704B4F7A64576666396A774B43615072486E7A47566A7949494F4D5046374E4B434A2B7573316C44314A6E66544F6D4E336A617153655065744A537A706E52655158616D307043352B565A4F333554546A6E734C4F726F6F2B556F616D637466356F6D6C34782F5151596E6E45782B6D52527241444C4B7A6A7A74794D504F716579593032696B774C4857546A352B79662F6A563139666763616C654E42526871683676414C6F70364B4F666A4F704E2B7035382B4D382B646747477133513357706F5954545A3951716F745668484C5333542B746A72744E5857776736626255613135594D33316F586F744E7869717936767646726272534C5771535155573231427542392F6449346B30304957587475767577447A436B78616154556C4C706535306D5459534C706F35696C443171626237385471376A4B774F6754546932746B595157564C306A42414C4E4C59524B316137496931564C62634D4D594C305555594D74312F4E524977617738344D4D53585A7375747949506E4656696245556E6F384C5269725279794834354F5A4572314C704C5338303157377A4F7748714657355453486657386979344467705652723932754C48584938744C726C563737686D54783273444D696A564637395A79644D38716156593166302B78705062414E70762F7470474652334F646D627A6873675856787831427263766136677A32746B56504834307830417072685464554954577364566135506B3552794C7467504458684C466E7456556F677A5731784D4F7551754A48496B343875303933685475573552574F72453372426364344F6B64534A465779333656484E685872576F2F3963384732545A5554324F6C7754504C76703054484A556345746A7A3736593245684C70456964663963646C64687A555659546E6D6C4C2B39574C4B3376766C72714332556F574C347A4A4833426C4A764E56374F3758563036546B594A49414148794254464E47557845634A525259496E6B367A4D524364742B51762F396B4F2F307256504C61567A796B72516C7347566C4734783872505568436A43514E5A6C7A32786F6B74426F4B6A67554432346D4A544345494177747942576E6241614349516F4C4364636850646C5A55467931517469732F3843797752692B6B4367655845774C2B654F2F3473574A4E784E686D6579774E362F6931656F2B7A586F695A5A716F5242644B7858424944434E6A7269675A6E44566B463677546E2F426D43455237325567734E4D6C6756327A48524B695162792B79596C3562366D635138596B764C33486B5335494B7461796F464C474B4739774C385A696F767A463644534C5332385836687564424A4D31496947637A57464D4F474565327A49754F5266456B556569467866365A5553474B34466F4A5A2B637951544A48507A426A30796564596F784F596C43556F38786C494F5558784C6C67696F384449566735474667316A5631535362514B5A4C31656552383464764B5A6559744C44754D696F564D69424267733636486F666D4C463065416E48764C5970424E765263687156732B6235587257497874697776764E4A4A47434F6D617361484B4D536A4B4C6A4951694A7A507664662F463667467A6179334433764C675762376C32436F654A6C546D792F34536C6B465255314F626D69416352794D5768777773474F54515A7676435A644462734B6C6774474D4D6D78704471304631795559553946497A796D672B59417175687752723332624B743077324A6161656C6D736B6D7351796C304A4B6B49774E7A5355364B386F514E4D49756A65375435637338797441654567364378414F585741357147376334644A6B55374A673143344C4E71665551474A577A352F356B3545364D5A56436859777A4C534B33596C71474E4D6F756C394249664A666C484B7549794B6D753942772B424274625A48624752784E7370512B556144326445614968384F6435434E41633865615646706D33714B55315579554F2F356E53526765564C5649534330734567566F48323031316D74726C527446707972314D6B7265557779316F6B6B7364516D49724B6E42716969327A2F317657514D37566159783234515357476C4C567A57636B72563068543043704563616B3959425770527A592F6A7536475032797431653568324354526C4C44654F306A506175625642713744474462386263694757646D6D704953546958776859434D7272716F36636E2F5373562F4468746E4F76437A58644E6E30626D4C4F796853727256657A6B635569573476796B4E5546314C737377534242556576637A4877776B45485A49765863424E6441426B7068447A6C61527263354F6A6B326B6D755572647346342B68424D50363365484264316A714F5553372B41464D674941375A2F58374353552F4F6448584A6138702B395A4933656F4553774A59306E6D597676444348514733444D4B587867785857334F5453424C664B6A4C427032516F576F52796A7543354F445554734162576A3171306C7764686F4D592B367A594B42743270654E4E7364432B64423877485A2F31775A686C7273484D6A624A354F594B4C75566E627732552B496F3030757370344F6A6C3179734E346B6F44714D7A646B70346234677879753733736561316E423358533735476B764A30576A6230646D2B62735569586A72745A455234727A31724671537834697A5942713035324D79756D4B465969577773473438724B6B765061476E6F7A4E724F695A7868684877637777506435546868316B74324841474F5975777531666E56735A364749374B746C342B416E763668557874436F66367339373058737756685136376D76373551586D64733574567354545A64515959745933784A6347734B35496C453771687133416C492B6578584A4E4F59676E34634378737A533549457057516B774E6849344F6338596F646E4C44475646427A516C303676483774344C49692F6F6C493673726D455A7A57614F5A7764756E2B6B5A486D4747637039446D653477716F4F59344D434E78384139776A5944352F6D324B6B486A6752393479444465734E637864474441327A653176636C616451664F57454470427530596E6857454D4A7835514C394D6B6C68722B4E422B314F627136457A7864783439782F666A613831654D6A426B503175564273375978615A47332B4239563450694472707A76547177704543436259634F5863766C5462434D4E2F6C69775769756A504865614C4C70346A415A762F69684E3779366A476255343350627531665859666834793578436A6A39716C37302B586B52484574654C45316E42633654647457552B317036766D64594B7A6A4C4F6D2F373071452B39366C66502B7461372F7657776A373145416749414F773D3D, 1)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2128, N'XXX', N'XXX', N'XXX', 0x52306C474F446C685A41426B4150634141414141414141414D7741415A6741416D5141417A4141412F774172414141724D7741725A6741726D5141727A4141722F774256414142564D7742565A6742566D5142567A4142562F774341414143414D7743415A6743416D5143417A4143412F774371414143714D7743715A6743716D5143717A4143712F774456414144564D7744565A6744566D5144567A4144562F77442F4141442F4D77442F5A67442F6D51442F7A41442F2F7A4D4141444D414D7A4D415A6A4D416D544D417A444D412F7A4D7241444D724D7A4D725A6A4D726D544D727A444D722F7A4E5641444E564D7A4E565A6A4E566D544E567A444E562F7A4F4141444F414D7A4F415A6A4F416D544F417A444F412F7A4F7141444F714D7A4F715A6A4F716D544F717A444F712F7A5056414450564D7A50565A6A50566D5450567A4450562F7A502F4144502F4D7A502F5A6A502F6D54502F7A44502F2F325941414759414D3259415A6D59416D5759417A4759412F325972414759724D3259725A6D59726D5759727A4759722F325A5641475A564D325A565A6D5A566D575A567A475A562F326141414761414D3261415A6D61416D5761417A4761412F326171414761714D3261715A6D61716D5761717A4761712F326256414762564D3262565A6D62566D5762567A4762562F32622F4147622F4D32622F5A6D622F6D57622F7A47622F2F356B41414A6B414D356B415A706B416D5A6B417A4A6B412F356B72414A6B724D356B725A706B726D5A6B727A4A6B722F356C56414A6C564D356C565A706C566D5A6C567A4A6C562F356D41414A6D414D356D415A706D416D5A6D417A4A6D412F356D71414A6D714D356D715A706D716D5A6D717A4A6D712F356E56414A6E564D356E565A706E566D5A6E567A4A6E562F356E2F414A6E2F4D356E2F5A706E2F6D5A6E2F7A4A6E2F2F387741414D77414D3877415A7377416D6377417A4D77412F387772414D77724D3877725A7377726D6377727A4D77722F387856414D78564D3878565A7378566D6378567A4D78562F387941414D79414D3879415A7379416D6379417A4D79412F387971414D79714D3879715A7379716D6379717A4D79712F387A56414D7A564D387A565A737A566D637A567A4D7A562F387A2F414D7A2F4D387A2F5A737A2F6D637A2F7A4D7A2F2F2F3841415038414D2F38415A7638416D6638417A5038412F2F3872415038724D2F38725A7638726D6638727A5038722F2F3956415039564D2F39565A7639566D6639567A5039562F2F2B4141502B414D2F2B415A762B416D662B417A502B412F2F2B7141502B714D2F2B715A762B716D662B717A502B712F2F2F5641502F564D2F2F565A762F566D662F567A502F562F2F2F2F41502F2F4D2F2F2F5A762F2F6D662F2F7A502F2F2F7741414141414141414141414141414143483542414541415077414C4141414141426B4147514141416A2F41472F6775484544686745414B684B716F4C4A77495A57484550315138554F78596B565572724A39793459746D7A5273324C35394D77634F6E446C7A726C79682B7367793544655435306779436F4D6A6A4D41625967674F7A436D5135733262413448714A4A677A786B474443526C43584271523473534C666A426D713657525930654E4A6375642F4F5A4B326B655148374F5668486E4F31694B634E584F7170556B7A5A317130624D57386C5575544330474442315841534B70514B644F4A543646692F4862316C56654E4C3075612B3461714D556873483058435844797A5A732B646C322B774857675A783561424D51624B7550465A7031454142684871626568337163536E676630516376557132797575306C794678487253334376486B4856334E476D7572433266596D54514C4733583838446D7064327978586C5462634855426C526B373876613463505845734F6A2F34714B6A57704733526B6C6B2F5339456E4C77623755556D2B4F31714B5A3936765933492B3835576B786F6754486B31427842427877467748594B646466616431714552346873723943476A57476F6344545653373131685570774853566D54692B32564B5A6666706952694E392B50474632673148614751414461716F31784E70663463575755573059595A4D6A6869534273354930472B61576A5332544857646667446659355A39314A6B71486D582F3533575255646761757870315333726E3246473231705054626872614E7442356A376D31346D306D386D474F4C47434E75687039624F636B6749482F564352546444516538364F4A423263576F46355A55614B486C647854524A69464767373255356D49724E57596D687566774D704E614A4C5A3548354D6F5A6C595558675945674E5232657A45305935626650555649684C2B7035456F71355A6C6B55692F5A72502F555655714B3973494C4C35593653576C6262313457526E2B5A3459435864746A70355364444D41416136454E5669466449536F686964467438764A77446A6F6149336D624C535A4C7557696B4F316F563736596E3579596D544158796969395142786959494B4B6D4545744B5976504B715773733361665A536A714E53786264744C794A2B477935316444314A3845346C306D534155544234476F43364D6179776C776F78384E5751467642534E4A7366763057563072324C32714B53744B2F55737130746B6A6A4A613848656975766D7743536D6939654C4D525345304D522F4A7656516C6738536B67713966726A4363636E2F3876496C62647143632B756B634F57336C6E3075347744315A55693664653665364C6134346F6F346937725178447444394B4172667A796F4D5A65313348707459784761724C516B6C54584E4B37686F5262335A74386A5A683171424D50442F4855444E4F4D515141326F4B5663786173684556306E5051737146535343306D74384E4C4C59306862664C536442556356786873736A6C317977665439506E5636474B3973475A634A77513278525976314B44695A63766D682B4B513332724C4B30476A41726B745330734339526C695343494A4A72786749677776783750447979364D4C4F4B35743561536935714C664C73494F4767347536747A6F4C5033504648504A6163392B62797632474B2B70476A5146496B6B77664379546A6E73784D2B4F5050504D33343738374A67442B5349425238326B474B5572335A52575A426E42775741764346774E444662676B4330515967742B674B436743454749516979436437654C53766E53566F7555345751523552434A4E374C686A524B57597833746D49634B6B57452F6471776A66696342427950734E6A70304D59774266594E427A6444434E596B6C6B433955534A62692F367041694757396268456D4D38743458494845454B567345597634786769783459334864416763374E44484D2B596E6A325449677833336532482B54734949756B48506A46686A5141775963414D326E71686D4D54444941672B34476B467077594662754F4F79484168464B4C7169676B527248755149387848686741557974556768506651786A324238555235666C4A38357871676D755A6B524C514A306F787031597257614C55794F436C5442466B615A787A7A6538593646324D4969436C47496F466D51455A446A794663495930554F66574D6579744148493963526A2F6D74343457525A4563357970474E536D72756B6D49346B413364534A444C384D53416E2B5261444F3459686931554D775A626D4F596F71376B4943724A79456139346852554A3834316430424962687651474F2B61526A30554B343454724F4159373468454D46395A546D426869524F6A4D6950384436746E41414D33734157633645344E2F477341474462414251634A67453461696A7145425969684474786D477836477A51794C4A4B47464B614D4A79424F4E2B7763684850756142546D2F414D78362F584963365475694E6237536A4863646357514152326F4D622B4B4148614D415051645A6F6C47626D545335417852756249436568516461697065616B52516D6C6146495779714D63367143664D373752456C7238457155704A5563747A4E474F6C45474E6E7763713041306163494D65334E51484F61324A34426A6749724C32414B632B4742696C4D6A65514C5542755772556F5279334D4B555552656B4F70354E44464F756178446C325167787A7259474535764F4B656A33696A467576777869354D43735A65344D526C414E77544777574B5537504B6853414E4D45704379786F4748357742423267416C32714265746B5069684E79653630464C55516957322F2F754F4B76484357484D4F51686A424969316F587969416438484274435772625570504C51427A3153323561594755437342444572576E3167453634643941426C7851466163584461455A31574F696D5A30434356656C5261584E53383241447350583372555862494D786E356B4D6376685348535A426A33472B765170543479515A503071546131574273725A383877335946673977414D554F674E43467A616F4D6F6C74554664684F566F495676493053496C4B544876625A58716A586F4767346F6D544F6B367667684D664D7844482F6B6F42785756756B37395A6B49743146574C4D672B41304C4C36774164754D4331422F676B44737471347754664971526836594A32634C67496A736E30464C55726D696936684A373370395159356472474F656F4B456F2B556768306E684F57495679694D6639723079666B2B384433306F673257586653363666467857417150682F38597261734242733074674D63533162754343734C78716F655149335262444745614665546D3843393275417A4A562F437335796D4653784D6244475A4355427A4A47366733696C6B4D595A4E594847756836576E55426C4B786E7A62455043494A4448373831726B5147463358745535505A76454952745A694E6B3647566B7478456D5261464473593553306A4663755136735A4765687866786B597A486D5053585764544850744A6E5A37566B5673316A7458474F33564454477869416D64534E4B33656846746377424F30567377456E686D6544455657566C425A54586B637433454E466B4878444639373470534E544F673949736E4D58306E6A734D4E6D52447866445264734262434E42626F6F474972785A3444657767566B626E4771356644634D70314A455370366C694C457473647A6F6E4731656438467534647857797345494269392F655178495172726637502B67346A66674E326C6C37774D5461456244676672326152745074396F4D6145424E462B34443154595834685630525346654C58526F795174524B586D735A48576849317466564E473655496649707837704C2B73534775786F36516E6C7355686C38786463333331327A57316338446633674D335A746A4E4E76747471634450786A7847532B4E673456753748346E6F587330496E6568524E5A5370584F52377952595938544B7A4C4D75735666766A4952356E314D51797767347649705373515755474E55794C634E4F485237546E626D2B31744373356D4E732F36664952797036713763397852717471774C6E5168386850755675516C682B517A394C75506557535A33386C7765544B654236356B71697568627657427764483631724953756547705A69674663516675304176746A36676739327830633951755653354847345A7350515550535754774D68364148377A2F666B56716A6E4B59754E2F37324D63776773796D5655652B356D38316134374E577462736F714868344B726734696A494D632B444F2F71705232455878692B6C683274564A6D6D534A6D7A31356C5350706B4B4D39464C447745346E706D794D78302B62686935697855594E6F4630465233787668514E45426D4862426E47793430335235336B2F457A5431676D47324E5234586C32473446677A4934456A4349486A4A5147776A3951774B4347627938314C3041476136464133364D416C42686C70744D584D593646616E4A6D6F676D4731424268646134486B6C7144694B383065664633336C316D515534594961704175374D485873454179374A586A496F49426542462F4A55442F737341736D6F556769565759764279374E39577A596858625464515A45634161634A515951526C304F4A44754B34336E52707A694D5132757563474662574969304548496856344F4F2F7953443749414D5A4467507A7242434A4C5A555774454F796C56342B694147512B614A4952685770544E575A3955446F745A5A647059666636682F565269497A696337414A67536956676F6A43674D3632434C77694347596368434E6F69414C4F5243544756537539414F6934522B3950426463515655416A52356D57643242356432636455672F45644251684F496E68654973536830466B455274644349776E414D7552694F344267507579554D776B434F596568437577412F7855565A376D426D79745A346E524E6B7061564D6F7768715A33566A626F5A614F4A464850554F462B686430324768786637534E6674434E5968694F43536D477433694F7556686C5535646C3550414E5944525A6A46594F784B6866363564614970685A6F6856744E58566A6144414562375A747A43574E736E457141766C486753676266794130754F4D55464645493372695143696D476A6639595A655667574962466179745866696342502B7A51645A725765327158576A50325843435A6A775133676C46494264354551643355546462594F5055696B7853684344695A693869676B4F466F69794B6E43384D4562787957614575465266475451726D6B443776336955536D6A4D73456B6B31346679554A595673416C5952514E767258664E4D344F31614A6C595777433135706A6C73356463486761347A475956706D62436F3354467A4644734F516B667441684A375965364749675457336757596C58572F57585671674258705A5159705143496F4152666F584741555A486E3677434A637767376C6F504D47414354675A444C74516D2B57675642796D56464A305779444259666379536665546B664F77615848466B584335526E566F664B4E325936556C68784D556C52573053743145434647596B6D627A4549555143567470504B2B4A6B37567054704F566D787A2F56554C33556B58755A6C496E4155592B75463970345779582B567731526C5A4E4B46336335514F6D31443056524A714271415774684A645A755169526F4A30344B5A7668534B4343575A7530674A74534A4A354C31564A48425749745A51374363442F6D51412F4C3957436F31577A676F6D5948774977334D41464E75493968384A7A385351694C4D4A714B34454346414A55566B5A31664B517A47303555774F71507445776D3755467534785A753630564B7A315665384E70356163524C454F41783879446D6647415963655341384E586B3774357A5A356F2F5269614A34524A31505755534563416E4263416B77656779594149356143707643554A753649467361466C3644526B56484A554C664D4673663135694F4F5A535A67424E7870573051396D7765436F4C7A32584D6A3269417143676146344B656679534153775A6F7A436F3763795A327875517552554745582F355A3066325A623563476A55725275786A61704968476B784F67377A5056672F6555446D4F6C6A457942676F2F5A6D4F5247465562674967466F496E7A6C4244514B567771436C5836716C5766717172376F4C4174696F5A59704F585046586B797170566D5357773453707955435A664D68646E4170414E4A61634173465A4E7A5551712F716E716770786756704572556F496D414372744571726C314362735A5767754A7068682F6858316164306166706B746F574A50386C565A3861522F7756556E6771667A4269713948645449306F46304D71667079516F33504D516B58414A31337174727971626D5043644175676C4639616F7272436D536861703162656D363261754B756567576A45507778426A4E6246704A6F6D734275436879376D5A4F4141477A776F474942756F646751526933437476414372574B716F736956687445414974504173474E596C4233745554663947726B706C534F313257306356517556674576507759686C4B703534595A433669526A366D637A7148707A66776D617061537175364C4943684266324B436631716F34753671416B4B6145703269497251745268325964556E675041424C52663163533231636A394A4433466172474941504B69566F632F566F6447477078344C73715A4543434F714168674445594B694171777043597136433474776F774A344B696B6861364233694C524259516C7258724C6C73427032746C535573476B6251735752444D54706958544B4F6168316251676D59475131415A7846454947694258757142596A44747A74447451464B433471516F4C477275426747626D327A5A495177617866575A39374B46617179496561716D2F65436B636D515A352B497363594A7233584C72445731717161454D64433746436F514270477743432F37527A4E4C59586456595738487475436158676E2F326D635952726D5247784B584377377A6B415A75433248416F336276476C71672B71456775434B722B706C626B43782F4378454D464C74796C7849535667744942467577396A6A2F2B336C4F78727464693742496C78755061726B695951363778317751316F6565694B7A783255786E64514E675141576D4241505179377065453457666837323547384249424534554E6E3246634C3168793767495332766F6848306751554C6B524A46706742504747594A4469776167473230333441426E56332F54354D484A55735464735244557548775239327176634D4B3041453635573353494F3332416C726752676E525A6D48465142682F66514B53626872795675576C7046674D4E774B545A4A56424E2B356C47374241796F674C582B45656A575545784F3842664B3345534E734A55334C563354477449687837685A53456A4E42495537462B7042547A4636514D4D51474E4A2F797467316562426646764551635333565A4151555268366364784E46536468335652306F636645654F774B4655664339464A7566587865452B494E3443414D78616D68587778556D775A41484876474261473647474D6C574D4B333168694930326D4E2B68657A5674677A7A3565346954764B715A654654795A4F694D454C6E4E7357794A7568333455475973574D6B7A647130795178566C4C4C6C4A795370456B496365783555666D7976437737304A6645477A504B394A495371594268325A4153362F77536B72444B58357968594278585937653078586364717473516F61495131456C422B48714E33677964465446334B6D69464A59694638764A2F67495A3946364C4D6E4E74733743656E78627070637561686F5172457378784B4363464167554B647172724E4969794E654D6D6969314F43516A4F4E2B3465467A7765417868776D3570434B72527A50725A794D50502F737777345158665648527A69544C4A534D52317167434537627A365A71705138684B424B7866314A6F4E6F58534F46595A693432787A766343447133386958484C68383347682B7848742F4862414E52634D524F54505644356D66304D6C52314E31684A4531684C524945526B6E66736E4F33365143724A78306C69594B6C34434D6A673874465A4E6E4A78546E4A386262547148303646714A51756B4550614C75695272716E6E6B747A5453494E59704732684E30686F5446593154752B456B456D7443716D426368444C74695A7357756B6E72413178394631625346336D3070783174536C4B727230596B74583751494B6261326E2F77505259684E4C4134477939704F544B3079764B633177383230616946744B4256667A585641416E30316335627634457174547A6474307678494B394E31673952524357346A5974724B476643437A5439746E484C726D44387974442F7249466C5256595559464D4A4E396F394862583579394E384F7970615541584C3074727772612B745768462F344E5A6D4132342F7779573273417563766431576264554E527346784264366D5A6C4D316C5365507242663543736D51764E344D5563744B4964396B62556331347470756252464A6A43727873626E417739332B50644E38794D4F654C622B684F6D72586F52304B727271423475445A7339354A4D614B4934397037564E536C55694E483354334D7879584D45394D5A79747678664672784445422B4C57414762754A7970454F30764263594D7A45667A42646163414F59454159306E74684C6F6139455464516149792B6458443632344F47627532724761645855396355626D334D2B2F49466F5442436F6F5158544A457057596A6771774541597730414B68776C6F774C724A5862495255654E6B445A326E556A4C3876637057766473677A7463634356444A2F396B44514E794564735931524B7A547168507058614E514E7441475A2F4467582F5067565237646531354273304D32516D6379685A37583230336F7874765A4F52656649666D4532715A44422F52445835306771354677444942542B4D75367135766159685064327179434A544E4478696E54684E3573687A7A524147586D66333157714A56544E6D484573533759566F4A3544484147642B37673176345864786E64524E524B3374526B61424473654C335A38457A7133313752506C7A6951535A517166587147673071444451784F335A744F4A557A7962494351625461716A305249757A706538625A764133503465376248486E6F416A6536354E317A78636F314D5049694F783370656B48724232574B716F4D73724748765443456F73434F4E3369546D646762754D553263332F356D49593957356236787A446871783065717A5A3464444B3843414441344B4B34366F50396C45477A6B42714843354F763977564C375146594B69476967766A47643179412F70392F2B34596463302B41646B714F7161674F6846396D78416F544438704665566A6141467A5A6741323767315963544E6B58744F717261326C427051544A7436484D61346E7849386945763869525038694D65717657335857493856696A75496936504D396E52544A7A4341417A67426C75677A3961753834476971747A446E38424F36422B7639742F6538644D3138742B4F5930686259774B6C6566794939793679384A6176416C545056763630397A65514D394772326F4B433271333954633157394B514B3930522F396D6E2F5A6D37412B6D5748426D36415947554D6B6A594667702B3149686A34496A472F4856527662644D4441776E6D426D4741763646765248626B514F317452345851385761662B463873386F30502F6350582B71372F3751626E426D376B566E68615A38332F5A4733714D6A306F2F6949375A6D307159414D3042674D4A6C7A366E35492F342B6766347171716D57676963492B776375666A4C6A766252442F733442767346357759413451614E477A63484774686F63434F686A78732B6350544163654F47415159774446794D41514347526741786574693441554D6B44433077776F4142633059536F55557343525571524F6A6C7A4A6946746851536779626E546A5136652B4C5136614F6E554B4A756641676B4D6E446755615545337A4251714C44484459686E4A457173654F436956674D78444D425163534D4D6A7A416A743268427551584D6F6B695346433243473364524962677759634A467738686E5468396969504964326E4F6F774B56763042424A342B614E596A6445444263386D4C44685A495933596A4334654E486931526868656F514A6F2B5873575442714637324E56486452726457746137466D4C556D32704442362F336E2B444577555464486452675553424D353073574B6F435364516E597731713055444230434745515036354E6C43697172546C6275493132725972336D395A72524C4569394D73686C4A59725349746951785A334B694F644F7A7832436D5364306B52757A6D422B50462F517357702B716871323567774B764D594F674D756B564F576D514C363679623636316146486C746B563165712B5643586E61785A5A634E655146785046736B57595352534E4A44517A314A34684E73747A6145456F697078684944377266372B414D776F616B55597141696972714351534C6F776C677751727171777A444A444A6638376B4D506177485251784158736157573945676B4D55564A3447755271614F51476B6767772F6F62726A394D476B684952346B5373754579725377796955676957314B4E753163556559553744446D38304A786477506C7A467A3942424E4757377A71306B6C5531453946726138737A667173767A4D534B63476F672F7A496854716F626A6A754F67514D7145696B474730444C72727461586B6E794777792F32655562567330706878647A5A715631316E4C4D346155635737367073734D4F767874764E6B79617174452F2F68517A3877316C50776B494144733D, 1)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2129, N'YYY', N'YYY', N'YYY', 0x52306C474F446C685A41426B4150634141414141414141414D7741415A6741416D5141417A4141412F774172414141724D7741725A6741726D5141727A4141722F774256414142564D7742565A6742566D5142567A4142562F774341414143414D7743415A6743416D5143417A4143412F774371414143714D7743715A6743716D5143717A4143712F774456414144564D7744565A6744566D5144567A4144562F77442F4141442F4D77442F5A67442F6D51442F7A41442F2F7A4D4141444D414D7A4D415A6A4D416D544D417A444D412F7A4D7241444D724D7A4D725A6A4D726D544D727A444D722F7A4E5641444E564D7A4E565A6A4E566D544E567A444E562F7A4F4141444F414D7A4F415A6A4F416D544F417A444F412F7A4F7141444F714D7A4F715A6A4F716D544F717A444F712F7A5056414450564D7A50565A6A50566D5450567A4450562F7A502F4144502F4D7A502F5A6A502F6D54502F7A44502F2F325941414759414D3259415A6D59416D5759417A4759412F325972414759724D3259725A6D59726D5759727A4759722F325A5641475A564D325A565A6D5A566D575A567A475A562F326141414761414D3261415A6D61416D5761417A4761412F326171414761714D3261715A6D61716D5761717A4761712F326256414762564D3262565A6D62566D5762567A4762562F32622F4147622F4D32622F5A6D622F6D57622F7A47622F2F356B41414A6B414D356B415A706B416D5A6B417A4A6B412F356B72414A6B724D356B725A706B726D5A6B727A4A6B722F356C56414A6C564D356C565A706C566D5A6C567A4A6C562F356D41414A6D414D356D415A706D416D5A6D417A4A6D412F356D71414A6D714D356D715A706D716D5A6D717A4A6D712F356E56414A6E564D356E565A706E566D5A6E567A4A6E562F356E2F414A6E2F4D356E2F5A706E2F6D5A6E2F7A4A6E2F2F387741414D77414D3877415A7377416D6377417A4D77412F387772414D77724D3877725A7377726D6377727A4D77722F387856414D78564D3878565A7378566D6378567A4D78562F387941414D79414D3879415A7379416D6379417A4D79412F387971414D79714D3879715A7379716D6379717A4D79712F387A56414D7A564D387A565A737A566D637A567A4D7A562F387A2F414D7A2F4D387A2F5A737A2F6D637A2F7A4D7A2F2F2F3841415038414D2F38415A7638416D6638417A5038412F2F3872415038724D2F38725A7638726D6638727A5038722F2F3956415039564D2F39565A7639566D6639567A5039562F2F2B4141502B414D2F2B415A762B416D662B417A502B412F2F2B7141502B714D2F2B715A762B716D662B717A502B712F2F2F5641502F564D2F2F565A762F566D662F567A502F562F2F2F2F41502F2F4D2F2F2F5A762F2F6D662F2F7A502F2F2F7741414141414141414141414141414143483542414541415077414C4141414141426B4147514141416A2F41472F6775484544686745414B684B716F4C4A77495A57484550315138554F78596B565572724A39793459746D7A5273324C35394D77634F6E446C7A726C79682B7367793544655435306779436F4D6A6A4D41625967674F7A436D5135733262413448714A4A677A786B474443526C43584271523473534C666A426D713657525930654E4A6375642F4F5A4B326B655148374F5668486E4F31694B634E584F7170556B7A5A317130624D57386C5575544330474442315841534B70514B644F4A543646692F4862316C56654E4C3075612B3461714D556873483058435844797A5A732B646C322B774857675A783561424D51624B7550465A7031454142684871626568337163536E676630516376557132797575306C794678487253334376486B4856334E476D7572433266596D54514C4733583838446D7064327978586C5462634855426C526B373876613463505845734F6A2F34714B6A57704733526B6C6B2F5339456E4C77623755556D2B4F31714B5A3936765933492B3835576B786F6754486B31427842427877467748594B646466616431714552346873723943476A57476F6344545653373131685570774853566D54692B32564B5A6666706952694E392B50474632673148614751414461716F31784E70663463575755573059595A4D6A6869534273354930472B61576A5332544857646667446659355A39314A6B71486D582F3533575255646761757870315333726E3246473231705054626872614E7442356A376D31346D306D386D474F4C47434E75687039624F636B6749482F564352546444516538364F4A423263576F46355A55614B486C647854524A69464767373255356D49724E57596D687566774D704E614A4C5A3548354D6F5A6C595558675945674E5232657A45305935626650555649684C2B7035456F71355A6C6B55692F5A72502F555655714B3973494C4C35593653576C6262313457526E2B5A3459435864746A70355364444D41416136454E5669466449536F686964467438764A77446A6F6149336D624C535A4C7557696B4F316F563736596E3579596D544158796969395142786959494B4B6D4545744B5976504B715773733361665A536A714E53786264744C794A2B477935316444314A3845346C306D534155544234476F43364D6179776C776F78384E5751467642534E4A7366763057563072324C32714B53744B2F55737130746B6A6A4A613848656975766D7743536D6939654C4D525345304D522F4A7656516C6738536B67713966726A4363636E2F3876496C62647143632B756B634F57336C6E3075347744315A55693664653665364C6134346F6F346937725178447444394B4172667A796F4D5A65313348707459784761724C516B6C54584E4B37686F5262335A74386A5A683171424D50442F4855444E4F4D515141326F4B5663786173684556306E5051737146535343306D74384E4C4C59306862664C536442556356786873736A6C317977665439506E5636474B3973475A634A77513278525976314B44695A63766D682B4B513332724C4B30476A41726B745330734339526C695343494A4A72786749677776783750447979364D4C4F4B35743561536935714C664C73494F4767347536747A6F4C5033504648504A6163392B62797632474B2B70476A5146496B6B77664379546A6E73784D2B4F5050504D33343738374A67442B5349425238326B474B5572335A52575A426E42775741764346774E444662676B4330515967742B674B436743454749516979436437654C53766E53566F7555345751523552434A4E374C686A524B57597833746D49634B6B57452F6471776A66696342427950734E6A70304D59774266594E427A6444434E596B6C6B433955534A62692F367041694757396268456D4D38743458494845454B567345597634786769783459334864416763374E44484D2B596E6A325449677833336532482B54734949756B48506A46686A5141775963414D326E71686D4D54444941672B34476B467077594662754F4F79484168464B4C7169676B527248755149387848686741557974556768506651786A324238555235666C4A38357871676D755A6B524C514A306F787031597257614C55794F436C5442466B615A787A7A6538593646324D4969436C47496F466D51455A446A794663495930554F66574D6579744148493963526A2F6D74343457525A4563357970474E536D72756B6D49346B413364534A444C384D53416E2B5261444F3459686931554D775A626D4F596F71376B4943724A79456139346852554A3834316430424962687651474F2B61526A30554B343454724F4159373468454D46395A546D426869524F6A4D6950384436746E41414D33734157633645344E2F477341474462414251634A67453461696A7145425969684474786D477836477A51794C4A4B47464B614D4A79424F4E2B7763684850756142546D2F414D78362F584963365475694E6237536A4863646357514152326F4D622B4B4148614D415051645A6F6C47626D545335417852756249436568516461697065616B52516D6C6146495779714D63367143664D373752456C7238457155704A5563747A4E474F6C45474E6E7763713041306163494D65334E51484F61324A34426A6749724C32414B632B4742696C4D6A65514C5542755772556F5279334D4B555552656B4F70354E44464F756178446C325167787A7259474535764F4B656A33696A467576777869354D43735A65344D526C414E77544777574B5537504B6853414E4D45704379786F4748357742423267416C32714265746B5069684E79653630464C55516957322F2F754F4B76484357484D4F51686A424969316F587969416438484274435772625570504C51427A3153323561594755437342444572576E3167453634643941426C7851466163584461455A31574F696D5A30434356656C5261584E53383241447350583372555862494D786E356B4D6376685348535A426A33472B765170543479515A503071546131574273725A383877335946673977414D554F674E43467A616F4D6F6C74554664684F566F495676493053496C4B544876625A58716A586F4767346F6D544F6B367667684D664D7844482F6B6F42785756756B37395A6B49743146574C4D672B41304C4C36774164754D4331422F676B44737471347754664971526836594A32634C67496A736E30464C55726D696936684A373370395159356472474F656F4B456F2B556768306E684F57495679694D6639723079666B2B384433306F673257586653363666467857417150682F38597261734242733074674D63533162754343734C78716F655149335262444745614665546D3843393275417A4A562F437335796D4653784D6244475A4355427A4A47366733696C6B4D595A4E594847756836576E55426C4B786E7A62455043494A4448373831726B5147463358745535505A76454952745A694E6B3647566B7478456D5261464473593553306A4663755136735A4765687866786B597A486D5053585764544850744A6E5A37566B5673316A7458474F33564454477869416D64534E4B33656846746377424F30567377456E686D6544455657566C425A54586B637433454E466B4878444639373470534E544F673949736E4D58306E6A734D4E6D52447866445264734262434E42626F6F474972785A3444657767566B626E4771356644634D70314A455370366C694C457473647A6F6E4731656438467534647857797345494269392F655178495172726637502B67346A66674E326C6C37774D5461456244676672326152745074396F4D6145424E462B34443154595834685630525346654C58526F795174524B586D735A48576849317466564E473655496649707837704C2B73534775786F36516E6C7355686C38786463333331327A57316338446633674D335A746A4E4E76747471634450786A7847532B4E673456753748346E6F587330496E6568524E5A5370584F52377952595938544B7A4C4D75735666766A4952356E314D51797767347649705373515755474E55794C634E4F485237546E626D2B31744373356D4E732F36664952797036713763397852717471774C6E5168386850755675516C682B517A394C75506557535A33386C7765544B654236356B71697568627657427764483631724953756547705A69674663516675304176746A36676739327830633951755653354847345A7350515550535754774D68364148377A2F666B56716A6E4B59754E2F37324D63776773796D5655652B356D38316134374E577462736F714868344B726734696A494D632B444F2F71705232455878692B6C683274564A6D6D534A6D7A31356C5350706B4B4D39464C447745346E706D794D78302B62686935697855594E6F4630465233787668514E45426D4862426E47793430335235336B2F457A5431676D47324E5234586C32473446677A4934456A4349486A4A5147776A3951774B4347627938314C3041476136464133364D416C42686C70744D584D593646616E4A6D6F676D4731424268646134486B6C7144694B383065664633336C316D515534594961704175374D485873454179374A586A496F49426542462F4A55442F737341736D6F556769565759764279374E39577A596858625464515A45634161634A515951526C304F4A44754B34336E52707A694D5132757563474662574969304548496856344F4F2F7953443749414D5A4467507A7242434A4C5A555774454F796C56342B694147512B614A4952685770544E575A3955446F745A5A647059666636682F565269497A696337414A67536956676F6A43674D3632434C77694347596368434E6F69414C4F5243544756537539414F6934522B3950426463515655416A52356D57643242356432636455672F45644251684F496E68654973536830466B455274644349776E414D7552694F344267507579554D776B434F596568437577412F7855565A376D426D79745A346E524E6B7061564D6F7768715A33566A626F5A614F4A464850554F462B686430324768786637534E6674434E5968694F43536D477433694F7556686C5535646C3550414E5944525A6A46594F784B6866363564614970685A6F6856744E58566A6144414562375A747A43574E736E457141766C486753676266794130754F4D55464645493372695143696D476A6639595A655667574962466179745866696342502B7A51645A725765327158576A50325843435A6A775133676C46494264354551643355546462594F5055696B7853684344695A693869676B4F466F69794B6E43384D4562787957614575465266475451726D6B443776336955536D6A4D73456B6B31346679554A595673416C5952514E767258664E4D344F31614A6C595777433135706A6C73356463486761347A475956706D62436F3354467A4644734F516B667441684A375965364749675457336757596C58572F57585671674258705A5159705143496F4152666F584741555A486E3677434A637767376C6F504D47414354675A444C74516D2B57675642796D56464A305779444259666379536665546B664F77615848466B584335526E566F664B4E325936556C68784D556C52573053743145434647596B6D627A4549555143567470504B2B4A6B37567054704F566D787A2F56554C33556B58755A6C496E4155592B75463970345779582B567731526C5A4E4B46336335514F6D31443056524A714271415774684A645A755169526F4A30344B5A7668534B4343575A7530674A74534A4A354C31564A48425749745A51374363442F6D51412F4C3957436F31577A676F6D5948774977334D41464E75493968384A7A385351694C4D4A714B34454346414A55566B5A31664B517A47303555774F71507445776D3755467534785A753630564B7A315665384E70356163524C454F41783879446D6647415963655341384E586B3774357A5A356F2F5269614A34524A31505755534563416E4263416B77656779594149356143707643554A753649467361466C3644526B56484A554C664D4673663135694F4F5A535A67424E7870573051396D7765436F4C7A32584D6A3269417143676146344B656679534153775A6F7A436F3763795A327875517552554745582F355A3066325A623563476A55725275786A61704968476B784F67377A5056672F6555446D4F6C6A457942676F2F5A6D4F5247465562674967466F496E7A6C4244514B567771436C5836716C5766717172376F4C4174696F5A59704F585046586B797170566D5357773453707955435A664D68646E4170414E4A61634173465A4E7A5551712F716E716770786756704572556F496D414372744571726C314362735A5767754A7068682F6858316164306166706B746F574A50386C565A3861522F7756556E6771667A4269713948645449306F46304D71667079516F33504D516B58414A31337174727971626D5043644175676C4639616F7272436D536861703162656D363261754B756567576A45507778426A4E6246704A6F6D734275436879376D5A4F4141477A776F474942756F646751526933437476414372574B716F736956687445414974504173474E596C4233745554663947726B706C534F313257306356517556674576507759686C4B703534595A433669526A366D637A7148707A66776D617061537175364C4943684266324B436631716F34753671416B4B6145703269497251745268325964556E675041424C52663163533231636A394A4433466172474941504B69566F632F566F6447477078344C73715A4543434F714168674445594B694171777043597136433474776F774A344B696B6861364233694C524259516C7258724C6C73427032746C535573476B6251735752444D54706958544B4F6168316251676D59475131415A7846454947694258757142596A44747A74447451464B433471516F4C477275426747626D327A5A495177617866575A39374B46617179496561716D2F65436B636D515A352B497363594A7233584C72445731717161454D64433746436F514270477743432F37527A4E4C59586456595738487475436158676E2F326D635952726D5247784B584377377A6B415A75433248416F336276476C71672B71456775434B722B706C626B43782F4378454D464C74796C7849535667744942467577396A6A2F2B336C4F78727464693742496C78755061726B695951363778317751316F6565694B7A783255786E64514E675141576D4241505179377065453457666837323547384249424534554E6E3246634C3168793767495332766F6848306751554C6B524A46706742504747594A4469776167473230333441426E56332F54354D484A55735464735244557548775239327176634D4B3041453635573353494F3332416C726752676E525A6D48465142682F66514B53626872795675576C7046674D4E774B545A4A56424E2B356C47374241796F674C582B45656A575545784F3842664B3345534E734A55334C563354477449687837685A53456A4E42495537462B7042547A4636514D4D51474E4A2F797467316562426646764551635333565A4151555268366364784E46536468335652306F636645654F774B4655664339464A7566587865452B494E3443414D78616D68587778556D775A41484876474261473647474D6C574D4B333168694930326D4E2B68657A5674677A7A3565346954764B715A654654795A4F694D454C6E4E7357794A7568333455475973574D6B7A647130795178566C4C4C6C4A795370456B496365783555666D7976437737304A6645477A504B394A495371594268325A4153362F77536B72444B58357968594278585937653078586364717473516F61495131456C422B48714E33677964465446334B6D69464A59694638764A2F67495A3946364C4D6E4E74733743656E78627070637561686F5172457378784B4363464167554B647172724E4969794E654D6D6969314F43516A4F4E2B3465467A7765417868776D3570434B72527A50725A794D50502F737777345158665648527A69544C4A534D52317167434537627A365A71705138684B424B7866314A6F4E6F58534F46595A693432787A766343447133386958484C68383347682B7848742F4862414E52634D524F54505644356D66304D6C52314E31684A4531684C524945526B6E66736E4F33365143724A78306C69594B6C34434D6A673874465A4E6E4A78546E4A386262547148303646714A51756B4550614C75695272716E6E6B747A5453494E59704732684E30686F5446593154752B456B456D7443716D426368444C74695A7357756B6E72413178394631625346336D3070783174536C4B727230596B74583751494B6261326E2F77505259684E4C4134477939704F544B3079764B633177383230616946744B4256667A585641416E30316335627634457174547A6474307678494B394E31673952524357346A5974724B476643437A5439746E484C726D44387974442F7249466C5256595559464D4A4E396F394862583579394E384F7970615541584C3074727772612B745768462F344E5A6D4132342F7779573273417563766431576264554E527346784264366D5A6C4D316C5365507242663543736D51764E344D5563744B4964396B62556331347470756252464A6A43727873626E417739332B50644E38794D4F654C622B684F6D72586F52304B727271423475445A7339354A4D614B4934397037564E536C55694E483354334D7879584D45394D5A79747678664672784445422B4C57414762754A7970454F30764263594D7A45667A42646163414F59454159306E74684C6F6139455464516149792B6458443632344F47627532724761645855396355626D334D2B2F49466F5442436F6F5158544A457057596A6771774541597730414B68776C6F774C724A5862495255654E6B445A326E556A4C3876637057766473677A7463634356444A2F396B44514E794564735931524B7A547168507058614E514E7441475A2F4467582F5067565237646531354273304D32516D6379685A37583230336F7874765A4F52656649666D4532715A44422F52445835306771354677444942542B4D75367135766159685064327179434A544E4478696E54684E3573687A7A524147586D66333157714A56544E6D484573533759566F4A3544484147642B37673176345864786E64524E524B3374526B61424473654C335A38457A7133313752506C7A6951535A517166587147673071444451784F335A744F4A557A7962494351625461716A305249757A706538625A764133503465376248486E6F416A6536354E317A78636F314D5049694F783370656B48724232574B716F4D73724748765443456F73434F4E3369546D646762754D553263332F356D49593957356236787A446871783065717A5A3464444B3843414441344B4B34366F50396C45477A6B42714843354F763977564C375146594B69476967766A47643179412F70392F2B34596463302B41646B714F7161674F6846396D78416F544438704665566A6141467A5A6741323767315963544E6B58744F717261326C427051544A7436484D61346E7849386945763869525038694D65717657335857493856696A75496936504D396E52544A7A4341417A67426C75677A3961753834476971747A446E38424F36422B7639742F6538644D3138742B4F5930686259774B6C6566794939793679384A6176416C545056763630397A65514D394772326F4B433271333954633157394B514B3930522F396D6E2F5A6D37412B6D5748426D36415947554D6B6A594667702B3149686A34496A472F4856527662644D4441776E6D426D4741763646765248626B514F317452345851385761662B463873386F30502F6350582B71372F3751626E426D376B566E68615A38332F5A4733714D6A306F2F6949375A6D307159414D3042674D4A6C7A366E35492F342B6766347171716D57676963492B776375666A4C6A766252442F733442767346357759413451614E477A63484774686F63434F686A78732B6350544163654F47415159774446794D41514347526741786574693441554D6B44433077776F4142633059536F55557343525571524F6A6C7A4A6946746851536779626E546A5136652B4C5136614F6E554B4A756641676B4D6E446755615545337A4251714C44484459686E4A457173654F436956674D78444D425163534D4D6A7A416A743268427551584D6F6B695346433243473364524962677759634A467738686E5468396969504964326E4F6F774B56763042424A342B614E596A6445444263386D4C44685A495933596A4334654E486931526868656F514A6F2B5873575442714637324E56486452726457746137466D4C556D32704442362F336E2B444577555464486452675553424D353073574B6F435364516E597731713055444230434745515036354E6C43697172546C6275493132725972336D395A72524C4569394D73686C4A59725349746951785A334B694F644F7A7832436D5364306B52757A6D422B50462F517357702B716871323567774B764D594F674D756B564F576D514C363679623636316146486C746B563165712B5643586E61785A5A634E655146785046736B57595352534E4A44517A314A34684E73747A6145456F697078684944377266372B414D776F616B55597141696972714351534C6F776C677751727171777A444A444A6638376B4D506177485251784158736157573945676B4D55564A3447755271614F51476B6767772F6F62726A394D476B684952346B5373754579725377796955676957314B4E753163556559553744446D38304A786477506C7A467A3942424E4757377A71306B6C5531453946726138737A667173767A4D534B63476F672F7A496854716F626A6A754F67514D7145696B474730444C72727461586B6E794777792F32655562567330706878647A5A715631316E4C4D346155635737367073734D4F767874764E6B79617174452F2F68517A3877316C50776B494144733D, 1)
INSERT [dbo].[Site] ([Id], [Name], [url], [Title], [Logo], [IsActive]) VALUES (2130, N'Test Site 103', N'http://localhost:49792/Site103', N'Site 103 title', 0x0000000000000065, 1)
SET IDENTITY_INSERT [dbo].[Site] OFF
SET IDENTITY_INSERT [dbo].[SiteDB] ON 

INSERT [dbo].[SiteDB] ([Id], [Name], [Server], [Database], [UserID], [Password], [Description], [SiteId]) VALUES (4, N'New DB Structure', N'192.168.35.124', N'WRC-CMS', N'sa', N'mail_123', N'Descrption.', 2077)
INSERT [dbo].[SiteDB] ([Id], [Name], [Server], [Database], [UserID], [Password], [Description], [SiteId]) VALUES (5, N'Test', N'192.168.35.124', N'WRC-CMS', N'sa', N'mail_123', N'site db desc1', 2111)
SET IDENTITY_INSERT [dbo].[SiteDB] OFF
SET IDENTITY_INSERT [dbo].[SiteMisc] ON 

INSERT [dbo].[SiteMisc] ([Id], [Key], [Value], [SiteId]) VALUES (3, N'Mobile No.', N'zh', 2078)
INSERT [dbo].[SiteMisc] ([Id], [Key], [Value], [SiteId]) VALUES (4, N'Mobile No.', N'9619147929', 2077)
INSERT [dbo].[SiteMisc] ([Id], [Key], [Value], [SiteId]) VALUES (5, N'Mobile No.', N'1548484', 2111)
INSERT [dbo].[SiteMisc] ([Id], [Key], [Value], [SiteId]) VALUES (9, N'Mobile No.', N'78', 2078)
SET IDENTITY_INSERT [dbo].[SiteMisc] OFF
SET IDENTITY_INSERT [dbo].[View] ON 

INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (63, N'About Us1', N'About Us', N'ö', NULL, 1, 1, 1, 2077)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (64, N'Home', N'Home4', N'ö', N'1,2', 1, 0, 0, 2078)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (65, N'Home', N'Home', N'ö', NULL, 1, 1, 1, 2079)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (66, N'About Us V2', N'About Us ', N'ö', NULL, 1, 0, 0, 2079)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (67, N'Contact Us V2', N'Contact Us', N'ö', NULL, 1, 0, 0, 2079)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (70, N'Home', N'Home', N'ö', NULL, 1, 1, 1, 2082)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (71, N'Home', N'Home', N'ö', NULL, 1, 1, 1, 2083)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (72, N'Home', N'Home', N'ö', NULL, 1, 1, 1, 2084)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (73, N'Home', N'Home', N'ö', NULL, 1, 1, 1, 2085)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (74, N'Home', N'Home', N'ö', NULL, 1, 1, 1, 2086)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (75, N'Home', N'Home', N'ö', NULL, 1, 1, 1, 2087)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (105, N'Test One', N'Test One', N'ö', N'1,2', 1, 1, 0, 2078)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (106, N'1,2,3', N'Test Two1567', N'ö', N'1,2,3', 1, 1, 0, 2078)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (109, N'Home', N'Home', N'ö', NULL, 1, 1, 0, 2077)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (111, N'Home', N'Home', N'ö', NULL, 1, 1, 1, 2077)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (115, N'Home', N'Home', N'ö', NULL, 1, 1, 1, 2077)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (116, N'Home', N'Home', N'ö', NULL, 1, 1, 1, 2077)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (117, N'Home', N'Home', N'ö', NULL, 1, 1, 1, 2077)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (118, N'Home', N'Home', N'ö', NULL, 1, 1, 1, 2086)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (121, N'Home', N'Home', N'ö', NULL, 1, 1, 1, 2084)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (122, N'Home', N'Home', N'ö', NULL, 1, 1, 1, 2086)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (127, N'Home', N'Home', N'ö', NULL, 1, 1, 1, 2083)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (129, N'Home', N'Home', N'ö', N'0', 1, 1, 0, 2103)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (130, N'Home', N'Home', N'ö', N'0', 1, 1, 0, 2103)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (133, N'Home', N'Home', N'ö', N'0', 1, 1, 1, 2105)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (135, N'Home', N'Home', N'ö', N'0', 1, 1, 0, 2110)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (136, N'Home', N'Home', N'ö', N'0', 1, 1, 0, 2111)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (137, N'About Us ', N'About Us Title', N'ö', N'3', 1, 1, 1, 2111)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (142, N'Home', N'Home', N'ö', N'0', 1, 1, 1, 2116)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (148, N'Home', N'Home', N'ö', N'0', 1, 1, 1, 2122)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (152, N'ABC', N'ABC Title', N'ö', N'1', 1, 0, 0, 2111)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (153, N'Home', N'Home', N'ö', N'0', 1, 1, 1, 2123)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (154, N'Home', N'Home', N'ö', N'0', 1, 1, 1, 2124)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (155, N'Home', N'Home', N'ö', N'0', 1, 1, 1, 2125)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (160, N'Home', N'Home', N'ö', N'0', 1, 1, 1, 2126)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (161, N'Home', N'Home', N'ö', N'0', 1, 1, 1, 2127)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (162, N'Home', N'Home', N'ö', N'0', 1, 1, 1, 2129)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (163, N'ZZZ', N'ZZZ', N'ö', N'ZZZ', 1, 0, 0, 2129)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (164, N'Contact Us', N'Contact Us Title', N'ö', N'1', 1, 0, 0, 2111)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (165, N'AAAA', N'AAAA', N'ö', N'AAAA', 1, 0, 0, 2129)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (166, N'BBB', N'BBB', N'ö', N'BBB', 1, 0, 0, 2129)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (168, N'Home', N'Home', N'ö', N'0', 1, 1, 1, 2130)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (177, N'SA', N'SA', N'ö', N'SASAS', 0, 0, 0, 2078)
INSERT [dbo].[View] ([Id], [Name], [Title], [Logo], [Orientation], [IsActive], [Authorized], [IsDefault], [SiteId]) VALUES (179, N'Home', N'Home1', N'ö', N'1,2', 1, 0, 1, 2078)
SET IDENTITY_INSERT [dbo].[View] OFF
ALTER TABLE [dbo].[Content] ADD  CONSTRAINT [DF__StaticCont__Name__45BE5BA9]  DEFAULT ('') FOR [Name]
GO
ALTER TABLE [dbo].[Content] ADD  CONSTRAINT [DF__StaticCon__IsAct__46B27FE2]  DEFAULT ((0)) FOR [IsActive]
GO
ALTER TABLE [dbo].[ContentOfView] ADD  CONSTRAINT [DF__ContentsO__Conte__0B5CAFEA]  DEFAULT ((0)) FOR [ContentId]
GO
ALTER TABLE [dbo].[ContentOfView] ADD  CONSTRAINT [DF__ContentsO__RefVi__0C50D423]  DEFAULT ((0)) FOR [ViewId]
GO
ALTER TABLE [dbo].[ContentOfView] ADD  DEFAULT ((0)) FOR [flag]
GO
ALTER TABLE [dbo].[ContentOfView] ADD  DEFAULT ((0)) FOR [OldOrder]
GO
ALTER TABLE [dbo].[Menu] ADD  DEFAULT ((0)) FOR [OldOrder]
GO
ALTER TABLE [dbo].[Menu] ADD  DEFAULT ((0)) FOR [Flag]
GO
ALTER TABLE [dbo].[Site] ADD  CONSTRAINT [DF__Sites__Name__3A4CA8FD]  DEFAULT ('') FOR [Name]
GO
ALTER TABLE [dbo].[Site] ADD  CONSTRAINT [DF__Sites__url__3B40CD36]  DEFAULT ('') FOR [url]
GO
ALTER TABLE [dbo].[Site] ADD  CONSTRAINT [DF__Sites__IsActive__3C34F16F]  DEFAULT ((0)) FOR [IsActive]
GO
ALTER TABLE [dbo].[View] ADD  CONSTRAINT [DF__Views__Name__3F115E1A]  DEFAULT ('') FOR [Name]
GO
ALTER TABLE [dbo].[View] ADD  CONSTRAINT [DF__Views__IsActive__40F9A68C]  DEFAULT ((0)) FOR [IsActive]
GO
ALTER TABLE [dbo].[View] ADD  CONSTRAINT [DF__Views__IsAuth__42E1EEFE]  DEFAULT ((0)) FOR [Authorized]
GO
ALTER TABLE [dbo].[View] ADD  CONSTRAINT [DF__Views__IsDem__41EDCAC5]  DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[Content]  WITH CHECK ADD  CONSTRAINT [FK_Contents_Site] FOREIGN KEY([SiteId])
REFERENCES [dbo].[Site] ([Id])
GO
ALTER TABLE [dbo].[Content] CHECK CONSTRAINT [FK_Contents_Site]
GO
ALTER TABLE [dbo].[ContentOfView]  WITH CHECK ADD  CONSTRAINT [FK_ContentOfView_Content] FOREIGN KEY([ContentId])
REFERENCES [dbo].[Content] ([Id])
GO
ALTER TABLE [dbo].[ContentOfView] CHECK CONSTRAINT [FK_ContentOfView_Content]
GO
ALTER TABLE [dbo].[ContentOfView]  WITH CHECK ADD  CONSTRAINT [FK_ContentOfView_Site] FOREIGN KEY([SiteId])
REFERENCES [dbo].[Site] ([Id])
GO
ALTER TABLE [dbo].[ContentOfView] CHECK CONSTRAINT [FK_ContentOfView_Site]
GO
ALTER TABLE [dbo].[ContentOfView]  WITH CHECK ADD  CONSTRAINT [FK_ContentOfView_View] FOREIGN KEY([ViewId])
REFERENCES [dbo].[View] ([Id])
GO
ALTER TABLE [dbo].[ContentOfView] CHECK CONSTRAINT [FK_ContentOfView_View]
GO
ALTER TABLE [dbo].[Menu]  WITH CHECK ADD  CONSTRAINT [FK_Menu_Sites] FOREIGN KEY([SiteId])
REFERENCES [dbo].[Site] ([Id])
GO
ALTER TABLE [dbo].[Menu] CHECK CONSTRAINT [FK_Menu_Sites]
GO
ALTER TABLE [dbo].[Menu]  WITH CHECK ADD  CONSTRAINT [FK_Menu_Views] FOREIGN KEY([ViewId])
REFERENCES [dbo].[View] ([Id])
GO
ALTER TABLE [dbo].[Menu] CHECK CONSTRAINT [FK_Menu_Views]
GO
ALTER TABLE [dbo].[SiteDB]  WITH CHECK ADD  CONSTRAINT [FK_SiteDB_Site] FOREIGN KEY([SiteId])
REFERENCES [dbo].[Site] ([Id])
GO
ALTER TABLE [dbo].[SiteDB] CHECK CONSTRAINT [FK_SiteDB_Site]
GO
ALTER TABLE [dbo].[SiteMisc]  WITH CHECK ADD  CONSTRAINT [FK_SiteMisc_Site] FOREIGN KEY([SiteId])
REFERENCES [dbo].[Site] ([Id])
GO
ALTER TABLE [dbo].[SiteMisc] CHECK CONSTRAINT [FK_SiteMisc_Site]
GO
ALTER TABLE [dbo].[Tracker]  WITH CHECK ADD  CONSTRAINT [FK_Tracker_Site] FOREIGN KEY([SiteId])
REFERENCES [dbo].[Site] ([Id])
GO
ALTER TABLE [dbo].[Tracker] CHECK CONSTRAINT [FK_Tracker_Site]
GO
ALTER TABLE [dbo].[TrackerTransaction]  WITH CHECK ADD  CONSTRAINT [FK_TrackerTransaction_Tracker] FOREIGN KEY([TrackerId])
REFERENCES [dbo].[Tracker] ([Id])
GO
ALTER TABLE [dbo].[TrackerTransaction] CHECK CONSTRAINT [FK_TrackerTransaction_Tracker]
GO
ALTER TABLE [dbo].[View]  WITH CHECK ADD  CONSTRAINT [FK_Views_Sites] FOREIGN KEY([SiteId])
REFERENCES [dbo].[Site] ([Id])
GO
ALTER TABLE [dbo].[View] CHECK CONSTRAINT [FK_Views_Sites]
GO
USE [master]
GO
ALTER DATABASE [WRC-CMS] SET  READ_WRITE 
GO
