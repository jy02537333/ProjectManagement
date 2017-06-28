Create PROCEDURE [dbo].[ReadPowerSet]  
@SetName varchar(100),
@DefaultValue bit ,
@ResultValue bit out 
AS 
BEGIN
  Declare @Sql Varchar(1000)
  
  Set @Sql='Declare cur1 Cursor Global For Select 启用 From 系统全局设置表 where 设置名称='''+@SetName+''''
  
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @ResultValue 
  if (@@Fetch_Status<>0)-- 没有找到记录
    set @ResultValue=@DefaultValue

  Close cur1
  deallocate cur1 
  
END