Create PROCEDURE [dbo].[CalcCaiGouHTJE4]
@htbh Varchar(100),
@zxfssj1 datetime,
@zxfssj2 datetime,
@zxtxsj1 datetime,
@zxtxsj2 datetime,
@fkfssj1 datetime,
@fkfssj2 datetime,
@fktxsj1 datetime,
@fktxsj2 datetime,
@fpje Float output,
@zxje Float output,
@fkje Float output,
@FaKuanje Float output
 
As
BEGIN
  Declare @sql Varchar(1000)
  Declare @ZXDateSql Varchar(1000)
  Declare @FKDateSql Varchar(1000)    
  Set @ZXDateSql=''
  Set @FKDateSql=''
  IF IsNULL(@zxfssj1,'')<>'' 
  Begin
    Set @ZXDateSql=@ZXDateSql+' And 发生日期 >='''+cast(@zxfssj1 as varchar(80))+''''
  End
  IF IsNULL(@zxfssj2,'')<>'' 
  Begin
    Set @ZXDateSql=@ZXDateSql+' And 发生日期 <='''+cast(@zxfssj2 as varchar(80))+''''
  End
  IF IsNULL(@zxtxsj1,'')<>'' 
  Begin
    Set @ZXDateSql=@ZXDateSql+' And 填写日期 >='''+cast(@zxtxsj1 as varchar(80))+'''' 
  End
  IF IsNULL(@zxtxsj2,'')<>'' 
  Begin
    Set @ZXDateSql=@ZXDateSql+' And 填写日期 <='''+cast(@zxtxsj2 as varchar(80))+''''
  End

  IF IsNULL(@fkfssj1,'')<>'' 
  Begin
    Set @FKDateSql=@FKDateSql+' And 发生日期 >='''+cast(@fkfssj1 as varchar(80))+'''' 
  End
  IF IsNULL(@fkfssj2,'')<>'' 
  Begin
    Set @FKDateSql=@FKDateSql+' And 发生日期 <='''+cast(@fkfssj2 as varchar(80))+'''' 
  End
  IF IsNULL(@fktxsj1,'')<>'' 
  Begin
    Set @FKDateSql=@FKDateSql+' And 填写日期 >='''+cast(@fktxsj1 as varchar(80))+''''   
  End
  IF IsNULL(@fktxsj2,'')<>'' 
  Begin
    Set @FKDateSql=@FKDateSql+' And 填写日期 <='''+cast(@fktxsj2 as varchar(80))+'''' 
  End  


  Set @sql='Declare cur1 Cursor Global For Select Sum(对应金额) As FPJE From 发票子表 where 冲销=0 And (1=2 '
  Set @sql=@sql+' or (对应单据类型=''材料采购单'' And Exists (Select 对应单据 From 材料总账表 where 材料总账表.对应单据=发票子表.发票对应单据 And 冲销=0 And 单据类型=''材料采购单'' And 合同编号='''+@htbh+''' ) )'
  Set @sql=@sql+' or (对应单据类型=''设备采购单'' And Exists (Select 对应单据 From 固定设备总账表 where 固定设备总账表.对应单据=发票子表.发票对应单据 And 冲销=0 And 单据类型=''设备采购单'' And 合同编号='''+@htbh+''' ) )'
  Set @Sql=@Sql+' ) '
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @fpje
  Close cur1
  deallocate cur1 
  Set @fpje=ISNULL(@fpje ,0)

  Declare @kcissh bit
  Set @kcissh=0                                          
  select @kcissh=启用 From 系统全局设置表 where 设置名称='材料的所有单据只有审核后才可产生库存和用量'

  Set @Sql='Declare cur1 Cursor Global For Select Sum(金额*(库房基数+项目基数)) As LjJE From 材料明细表 where 合同编号='''+@HTBH+''' And 冲销=0 And (单据类型=''材料采购单'' or 单据类型=''材料退货单'' )'
  IF @kcissh=1 Begin Set @Sql=@Sql+' And 审核否=1 ' End
  Set @Sql=@Sql+@ZXDateSql
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @zxje
  Close cur1
  deallocate cur1 
  Set @zxje=ISNULL(@zxje ,0) 

  Declare @gdzcje Float
  Set @Sql='Declare cur1 Cursor Global For Select Sum(金额) As LjJE From 固定设备明细表 where 合同编号='''+@HTBH+''' And 冲销=0 And 单据类型=''设备采购单''' 
  Set @Sql=@Sql+@ZXDateSql
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @gdzcje
  Close cur1
  deallocate cur1 
  Set @gdzcje=ISNULL(@gdzcje ,0)  
  Set @zxje=@zxje+@gdzcje

  Set @Sql='Declare cur1 Cursor Global For Select Sum( Case When 单据类型=''付款单'' then 金额 Else -金额 End ) As LjJE From 收付款总账表 where 合同编号='''+@HTBH+''' And 冲销=0 And  执行合同=''采购合同'' ' 
  Set @Sql=@Sql+@FKDateSql 
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @fkje
  Close cur1
  deallocate cur1 
  Set @fkje=ISNULL(@fkje ,0)  
  
  
  Set @Sql='Declare cur1 Cursor Global For Select Sum(罚款金额) As LjJE From 外包罚款单 where 合同编号='''+@HTBH+''' And 冲销=0 ' 
  Set @Sql=@Sql+@ZXDateSql
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @FaKuanje
  Close cur1
  deallocate cur1 
  Set @FaKuanje=ISNULL(@FaKuanje ,0)   
  
END   
