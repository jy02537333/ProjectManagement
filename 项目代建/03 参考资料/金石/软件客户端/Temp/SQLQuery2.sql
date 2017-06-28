CREATE PROCEDURE [dbo].[GetNewDJBM2]
@DJName varchar(20) ,
@QJM varchar(10) output,
@BM varchar(20) output,
@ResultOK Int output

 AS
Set @ResultOK=0

declare @Sql_Str varchar(500)
declare @TableName varchar(50)
declare @SCFS  varchar(20)
declare @BM_L Int
declare @QZ_L Int
declare @L Int
declare @K Int
declare @FDef Int
declare @BM_Max Int

Set @Sql_Str='Declare cur1 Cursor Global  For Select 生成方式,表名,前缀码+年码, 编码长度 From 单据表 where  单据名称='''+@DJName+''''
Exec(@Sql_Str)
Open cur1

Fetch Next From cur1 Into @SCFS,@TableName,@QJM,@BM_L
close cur1
deallocate cur1

Set @QZ_L=Len(@QJM)
Set @L=@QZ_L+@BM_L


IF @SCFS='最大已用单号+1' 
Begin

  IF (@TableName='材料计划总账表' ) or  (@TableName='材料加工计划总账表' ) 
  Begin
    Set @Sql_Str='Declare cur2 Cursor Global For Select Max(Cast(SubString(计划单号,'+Str(@QZ_L+1)+','+Str(@BM_L)+') As Int)) As MaxBH From '+@TableName+' where 冲销=0 And Len(RTrim(LTrim(计划单号)))='+Str(@L)+' And Left(计划单号,'+Str(@QZ_L)+')='''+@QJM+''' '
  End
  IF (@TableName='员工请款单') or (@TableName='员工请假单')
  Begin
    Set @Sql_Str='Declare cur2 Cursor Global For Select Max(Cast(SubString(申请单号,'+Str(@QZ_L+1)+','+Str(@BM_L)+') As Int)) As MaxBH From '+@TableName+' where 冲销=0 And Len(RTrim(LTrim(申请单号)))='+Str(@L)+' And Left(申请单号,'+Str(@QZ_L)+')='''+@QJM+''' '
  End
  IF  @TableName<>'材料计划总账表' 
  Begin
     IF  @TableName<>'材料加工计划总账表' 
     Begin
         IF  (@TableName<>'员工请款单') And (@TableName<>'员工请假单')
         Begin
            Set @Sql_Str='Declare cur2 Cursor Global For Select Max(Cast(SubString(对应单据,'+Str(@QZ_L+1)+','+Str(@BM_L)+') As Int)) As MaxBH From '+@TableName+' where 冲销=0 And Len(RTrim(LTrim(对应单据)))='+Str(@L)+' And Left(对应单据,'+Str(@QZ_L)+')='''+@QJM+''' '
        End
     End
   End

  Exec(@Sql_Str)
  Open cur2
  Set @BM_Max=1
  Set @ResultOK=1

  Fetch Next From cur2  Into @BM_Max
  IF  (@@Fetch_Status=0) 
  Begin
     Set @BM_Max=@BM_Max+1
  End

  close cur2
  deallocate cur2

  Set @BM=LTrim(Str(@BM_Max))
  Set @L=Len(@BM)
  Set @BM=replicate('0',@BM_L-@L)+@BM

End

IF @SCFS='最小未用单号'
Begin

  IF (@TableName='材料计划总账表' ) or  (@TableName='材料加工计划总账表' ) 
  Begin
     Set @Sql_Str='Declare cur2 Cursor Global For Select Cast(SubString(计划单号,'+Str(@QZ_L+1)+','+Str(@BM_L)+') As Int) As MaxBH From '+@TableName+' where 冲销=0 And Len(RTrim(LTrim(计划单号)))='+Str(@L)+' And Left(计划单号,'+Str(@QZ_L)+')='''+@QJM+''' order by 计划单号'
  End

  IF (@TableName='员工请款单') or (@TableName='员工请假单')
  Begin
     Set @Sql_Str='Declare cur2 Cursor Global For Select Cast(SubString(申请单号,'+Str(@QZ_L+1)+','+Str(@BM_L)+') As Int) As MaxBH From '+@TableName+' where 冲销=0 And Len(RTrim(LTrim(申请单号)))='+Str(@L)+' And Left(申请单号,'+Str(@QZ_L)+')='''+@QJM+''' order by 申请单号'
  End
  IF  @TableName<>'材料计划总账表' 
  Begin
     IF  @TableName<>'材料加工计划总账表' 
     Begin
        IF  (@TableName<>'员工请款单') And (@TableName<>'员工请假单')
        Begin
            Set @Sql_Str='Declare cur2 Cursor Global For Select Cast(SubString(对应单据,'+Str(@QZ_L+1)+','+Str(@BM_L)+') As Int) As MaxBH From '+@TableName+' where 冲销=0 And Len(RTrim(LTrim(对应单据)))='+Str(@L)+' And Left(对应单据,'+Str(@QZ_L)+')='''+@QJM+''' order by 对应单据'
        End
    End
  End
 Exec(@Sql_Str)
Open cur2

Set @FDef=1
IF @BM<>'' 
Begin
Set @BM=Right(@BM,@BM_L)
  IF ISNUMERIC(@BM)=1
  Begin
    Set @FDef=cast(@BM as int) +1
  End
End


Set @BM=LTrim(Str(@FDef))
Set @L=Len(@BM)
Set @BM=replicate('0',@BM_L-@L)+@BM
Set @ResultOK=1

Fetch Next From cur2  Into @BM_Max
While (@@Fetch_Status=0) 
Begin
  IF @FDef>@BM_Max 
  Begin
    Fetch Next From cur2 Into @BM_Max
  End 
  Else IF @FDef=@BM_Max 
  Begin
    Set @FDef=@FDef+1
    Fetch Next From cur2 Into @BM_Max
  End
  Else IF @FDef<@BM_Max 
  Begin 
     break
  End
End

close cur2
deallocate cur2

Set @BM=LTrim(Str(@FDef))
Set @L=Len(@BM)
Set @BM=replicate('0',@BM_L-@L)+@BM
End