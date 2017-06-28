Create Proc [dbo].[CalcWangLaiDuiZhang]
  @Wldw Varchar(50),
  @fsrq1 datetime,
  @fsrq2 datetime,

  @LjCLCGD Float output,
  @LjCLXSD Float output,
  @LjCLTHD Float output,
  @LjSBCGD Float output,
  @LjSBTHD Float output,
  @LjZLJSD Float output,
  @LjWBRGD Float output,
  @LjWBFKD Float output,
  @LjWBJXD Float output,
  @LjYSCLD Float output,
  @LjSBWXD Float output,
  @LjQTFYD Float output,
  @LjQTSRD Float output,
  @LjShouKuanDan Float output,
  @LjFuKuanDan Float output,
  @LjGlf Float output,
  @LjSj Float output,  
  @ShouRuFPHJ Float output 
  
As
Begin
  Declare @sql Varchar(1000)
  Declare @sqldate Varchar(1000) 
  Set @sqldate=''
  IF IsNULL(@fsrq1,'')<>'' 
  Begin
    Set @sqldate=@sqldate+' And 发生日期 >='''+cast(@fsrq1 as varchar(80))+''''
  End
  IF IsNULL(@fsrq2,'')<>'' 
  Begin
    Set @sqldate=@sqldate+' And 发生日期 <='''+cast(@fsrq2 as varchar(80))+''''
  End


  Set @Sql='Declare cur1 Cursor Global  For Select Sum(金额) As Ljje From 材料总账表 where 冲销=0 And 单据类型=''材料采购单'' And 往来单位='''+@Wldw+''''
  Set @sql=@sql+@sqldate
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @LjCLCGD
  Close cur1
  deallocate cur1 
  Set @LjCLCGD=ISNULL(@LjCLCGD,0)  

  Set @Sql='Declare cur1 Cursor Global  For Select Sum(金额) As Ljje From 材料总账表 where 冲销=0 And 单据类型=''材料销售单'' And 往来单位='''+@Wldw+'''' 
  Set @sql=@sql+@sqldate  
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @LjCLXSD
  Close cur1
  deallocate cur1 
  Set @LjCLXSD=ISNULL(@LjCLXSD,0)   

  Set @Sql='Declare cur1 Cursor Global  For Select Sum(金额) As Ljje From 材料总账表 where 冲销=0 And 单据类型=''材料退货单'' And 往来单位='''+@Wldw+''''
  Set @sql=@sql+@sqldate  
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @LjCLTHD
  Close cur1
  deallocate cur1 
  Set @LjCLTHD=ISNULL(@LjCLTHD,0)   
 

  Set @Sql='Declare cur1 Cursor Global  For Select Sum(金额) As Ljje From 固定设备总账表 where 冲销=0 And 单据类型=''设备采购单'' And 往来单位='''+@Wldw+''''
  Set @sql=@sql+@sqldate  
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @LjSBCGD
  Close cur1
  deallocate cur1 
  Set @LjSBCGD=ISNULL(@LjSBCGD,0) 



  Set @Sql='Declare cur1 Cursor Global  For Select Sum(金额) As Ljje From 固定设备总账表 where 冲销=0 And 单据类型=''设备退货单'' And 往来单位='''+@Wldw+''''
  Set @sql=@sql+@sqldate  
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @LjSBTHD
  Close cur1
  deallocate cur1 
  Set @LjSBTHD=ISNULL(@LjSBTHD,0)  

 
  Set @Sql='Declare cur1 Cursor Global  For Select Sum(金额) As Ljje From 租赁结算总账表 where 冲销=0 And 往来单位='''+@Wldw+''''
  Set @sql=@sql+@sqldate  
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @LjZLJSD
  Close cur1
  deallocate cur1 
  Set @LjZLJSD=ISNULL(@LjZLJSD,0)   

  Set @Sql='Declare cur1 Cursor Global  For Select Sum(金额) As Ljje From 外包人工总账表 where 冲销=0 And 往来单位='''+@Wldw+''''
  Set @sql=@sql+@sqldate  
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @LjWBRGD
  Close cur1
  deallocate cur1 
  Set @LjWBRGD=ISNULL(@LjWBRGD,0)   

  Set @Sql='Declare cur1 Cursor Global  For Select Sum(罚款金额) As Ljje From 外包罚款单 where 冲销=0 And 被罚款人='''+@Wldw+'''' 
  Set @sql=@sql+@sqldate  
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @LjWBFKD
  Close cur1
  deallocate cur1 
  Set @LjWBFKD=ISNULL(@LjWBFKD,0)   


  Set @Sql='Declare cur1 Cursor Global  For Select Sum(金额) As Ljje From 外包机械总账表 where 冲销=0 And 往来单位='''+@Wldw+''''
  Set @sql=@sql+@sqldate  
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @LjWBJXD
  Close cur1
  deallocate cur1 
  Set @LjWBJXD=ISNULL(@LjWBJXD,0)

  Set @Sql='Declare cur1 Cursor Global  For Select Sum(金额) As Ljje From 运输车辆总账表 where 冲销=0 And 往来单位='''+@Wldw+''''
  Set @sql=@sql+@sqldate  
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @LjYSCLD
  Close cur1
  deallocate cur1 
  Set @LjYSCLD=ISNULL(@LjYSCLD,0) 

  Set @Sql='Declare cur1 Cursor Global  For Select Sum(金额) As Ljje From 固定设备维修总账表 where 冲销=0 And 往来单位='''+@Wldw+'''' 
  Set @sql=@sql+@sqldate  
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @LjSBWXD
  Close cur1
  deallocate cur1 
  Set @LjSBWXD=ISNULL(@LjSBWXD,0) 

  Set @Sql='Declare cur1 Cursor Global  For Select Sum(金额) As Ljje From 其它费用总账表 where 冲销=0 And 往来单位='''+@Wldw+''''
  Set @sql=@sql+@sqldate  
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @LjQTFYD
  Close cur1
  deallocate cur1 
  Set @LjQTFYD=ISNULL(@LjQTFYD,0) 

  Set @Sql='Declare cur1 Cursor Global  For Select Sum(金额) As Ljje From 其它收入总账表 where 冲销=0 And 往来单位='''+@WLDW+''''
  Set @sql=@sql+@sqldate  
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @LjQTSRD
  Close cur1
  deallocate cur1 
  Set @LjQTSRD=ISNULL(@LjQTSRD,0)  

  Set @Sql='Declare cur1 Cursor Global  For Select Sum(金额) As Ljje From 收付款总账表 where 冲销=0 And 单据类型=''收款单'' And 执行合同<>''承包合同'' And 往来单位='''+@WLDW+'''' 
  Set @sql=@sql+@sqldate  
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @LjShouKuanDan
  Close cur1
  deallocate cur1 
  Set @LjShouKuanDan=ISNULL(@LjShouKuanDan,0)  

  Set @Sql='Declare cur1 Cursor Global  For Select Sum(金额) As Ljje From 收付款总账表 where 冲销=0 And 单据类型=''付款单'' And 执行合同<>''承包合同'' And 往来单位='''+@WLDW+'''' 
  Set @sql=@sql+@sqldate  
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @LjFuKuanDan
  Close cur1
  deallocate cur1 
  Set @LjFuKuanDan=ISNULL(@LjFuKuanDan,0)  

  Set @Sql='Declare cur1 Cursor Global  For Select Sum(管理费) As Glf ,Sum(税金) As SJ From 分包合同代扣管理费税金表,分包合同表 where 分包合同代扣管理费税金表.MainID=分包合同表.AutoID  ' 
  Set @Sql=@Sql+' And 乙方='''+@WLDW+''''  
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @LjGlf,@LjSj
  Close cur1
  deallocate cur1 
  Set @LjGlf=ISNULL(@LjGlf,0)   
  Set @LjSj=ISNULL(@LjSj,0)  

  Set @Sql='Declare cur1 Cursor Global  For Select Sum(发票金额) As Ljje From 发票主表 where 冲销=0 And 发票编号<>'''' And 对方单位='''+@WLDW+''' And 业务类型=''收进发票'' ' 
  Set @sql=@sql+@sqldate  
  Exec(@Sql)
  Open cur1
  Fetch Next From cur1 into @ShouRuFPHJ
  Close cur1
  deallocate cur1 
  Set @ShouRuFPHJ=ISNULL(@ShouRuFPHJ,0)  


End


