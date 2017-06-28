Create Procedure [dbo].[CalcYSQ_YFK2]
  @StartDate datetime,
  @EndDate datetime,
  @XMPathKey VarChar(1000)
As   
Begin
  Declare @DateSql VarChar(1000)
  Declare @sql Varchar(5000)
 
  Set @DateSql=''
  IF IsNULL(@StartDate,'')<>'' 
  Begin
    Set @DateSql=@DateSql+' And 发生日期 >='''+cast(@StartDate as varchar(80))+''''
  End
  IF IsNULL(@EndDate,'')<>'' 
  Begin
    Set @DateSql=@DateSql+' And 发生日期  <='''+cast(@EndDate as varchar(80))+''''
  End

  IF IsNULL(@XMPathKey,'')<>'' 
  Begin
    Set @DateSql=@DateSql+' And CharIndex('''+@XMPathKey+''',XMPathKey)=1'
  End


  Set @sql='update 外包人工总账表 Set YSQ=ISNULL((select sum(金额) from 付款申请明细表 where 付款对应单据=外包人工总账表.对应单据 And 冲销=0 And 付款单据类型=''外包人工单'' '+@DateSql+'),0),YFK=ISNULL((select sum(金额) from 收付款明细表 where 付款对应单据=外包人工总账表.对应单据 And 冲销=0 And 付款单据类型=''外包人工单'' '+@DateSql+'),0) where 冲销=0 '
  Exec(@sql)
  Set @sql='update 外包机械总账表 Set YSQ=ISNULL((select sum(金额) from 付款申请明细表 where 付款对应单据=外包机械总账表.对应单据 And 冲销=0 And 付款单据类型=''外包机械单'' '+@DateSql+'),0),YFK=ISNULL((select sum(金额) from 收付款明细表 where 付款对应单据=外包机械总账表.对应单据 And 冲销=0 And 付款单据类型=''外包机械单'' '+@DateSql+'),0) where 冲销=0 '
  Exec(@sql)
  Set @sql='update 材料总账表 Set YSQ=ISNULL((select sum(金额) from 付款申请明细表 where 付款对应单据=材料总账表.对应单据 And 冲销=0 And 付款单据类型=''材料采购单'' '+@DateSql+'),0),YFK=ISNULL((select sum(金额) from 收付款明细表 where 付款对应单据=材料总账表.对应单据 And 冲销=0 And 付款单据类型=''材料采购单'' '+@DateSql+'),0) where 冲销=0 And 单据类型=''材料采购单'' ' 
  Exec(@sql)
  Set @sql='update 租赁结算总账表 Set YSQ=ISNULL((select sum(金额) from 付款申请明细表 where 付款对应单据=租赁结算总账表.对应单据 And 冲销=0 And 付款单据类型=''租赁结算单'' '+@DateSql+'),0),YFK=ISNULL((select sum(金额) from 收付款明细表 where 付款对应单据=租赁结算总账表.对应单据 And 冲销=0 And 付款单据类型=''租赁结算单'' '+@DateSql+'),0) where 冲销=0 ' 
  Exec(@sql)
  Set @sql='update 其它费用总账表 Set YSQ=ISNULL((select sum(金额) from 付款申请明细表 where 付款对应单据=其它费用总账表.对应单据 And 冲销=0 And 付款单据类型=''其它费用单'' '+@DateSql+'),0),YFK=ISNULL((select sum(金额) from 收付款明细表 where 付款对应单据=其它费用总账表.对应单据 And 冲销=0 And 付款单据类型=''其它费用单'' '+@DateSql+'),0) where 冲销=0 '
  Exec(@sql)
  Set @sql='update 运输车辆总账表 Set YSQ=ISNULL((select sum(金额) from 付款申请明细表 where 付款对应单据=运输车辆总账表.对应单据 And 冲销=0 And 付款单据类型=''运输车辆单'' '+@DateSql+'),0),YFK=ISNULL((select sum(金额) from 收付款明细表 where 付款对应单据=运输车辆总账表.对应单据 And 冲销=0 And 付款单据类型=''运输车辆单'' '+@DateSql+'),0) where 冲销=0 '
  Exec(@sql)
  Set @sql='update 固定设备维修总账表 Set YSQ=ISNULL((select sum(金额) from 付款申请明细表 where 付款对应单据=固定设备维修总账表.对应单据 And 冲销=0 And 付款单据类型=''设备维修单'' '+@DateSql+'),0),YFK=ISNULL((select sum(金额) from 收付款明细表 where 付款对应单据=固定设备维修总账表.对应单据 And 冲销=0 And 付款单据类型=''设备维修单'' '+@DateSql+'),0) where 冲销=0 '
  Exec(@sql)

  --下面是明细表的赋值
  Set @sql='update 外包人工明细表 Set YSQ=(Case when ((Select 金额 from 外包人工总账表 where AutoID=外包人工明细表.MainID)=0) then 0 Else ISNULL((select YSQ from 外包人工总账表 where AutoID=外包人工明细表.MainID)*金额/(select 金额 from 外包人工总账表 where AutoID=外包人工明细表.MainID),0) End) where 冲销=0'
  Exec(@sql)
  Set @sql='update 外包人工明细表 Set YFK=(Case when ((Select 金额 from 外包人工总账表 where AutoID=外包人工明细表.MainID)=0) then 0 Else ISNULL((select YFK from 外包人工总账表 where AutoID=外包人工明细表.MainID)*金额/(select 金额 from 外包人工总账表 where AutoID=外包人工明细表.MainID),0) End) where 冲销=0' 
  Exec(@sql)
  Set @sql='update 外包机械明细表 Set YSQ=(Case when ((Select 金额 from 外包机械总账表 where AutoID=外包机械明细表.MainID)=0) then 0 Else ISNULL((select YSQ from 外包机械总账表 where AutoID=外包机械明细表.MainID)*金额/(select 金额 from 外包机械总账表 where AutoID=外包机械明细表.MainID),0) End) where 冲销=0'
  Exec(@sql)
  Set @sql='update 外包机械明细表 Set YFK=(Case when ((Select 金额 from 外包机械总账表 where AutoID=外包机械明细表.MainID)=0) then 0 Else ISNULL((select YFK from 外包机械总账表 where AutoID=外包机械明细表.MainID)*金额/(select 金额 from 外包机械总账表 where AutoID=外包机械明细表.MainID),0) End) where 冲销=0' 
  Exec(@sql)
   
  Set @sql='update 材料明细表 Set YSQ=(Case when ((Select 金额 from 材料总账表 where AutoID=材料明细表.MainID)=0) then 0 Else ISNULL((select YSQ from 材料总账表 where AutoID=材料明细表.MainID)*金额/(select 金额 from 材料总账表 where AutoID=材料明细表.MainID),0) End) where 冲销=0 And 单据类型=''材料采购单'''
  Exec(@sql)
  Set @sql='update 材料明细表 Set YFK=(Case when ((Select 金额 from 材料总账表 where AutoID=材料明细表.MainID)=0) then 0 Else ISNULL((select YFK from 材料总账表 where AutoID=材料明细表.MainID)*金额/(select 金额 from 材料总账表 where AutoID=材料明细表.MainID),0) End) where 冲销=0 And 单据类型=''材料采购单'''
  Exec(@sql)
   
  Set @sql='update 租赁结算明细表 Set YSQ=(Case when ((Select 金额 from 租赁结算总账表 where AutoID=租赁结算明细表.MainID)=0) then 0 Else ISNULL((select YSQ from 租赁结算总账表 where AutoID=租赁结算明细表.MainID)*金额/(select 金额 from 租赁结算总账表 where AutoID=租赁结算明细表.MainID),0) End) where 冲销=0'
  Exec(@sql)
  Set @sql='update 租赁结算明细表 Set YFK=(Case when ((Select 金额 from 租赁结算总账表 where AutoID=租赁结算明细表.MainID)=0) then 0 Else ISNULL((select YFK from 租赁结算总账表 where AutoID=租赁结算明细表.MainID)*金额/(select 金额 from 租赁结算总账表 where AutoID=租赁结算明细表.MainID),0) End) where 冲销=0' 
  Exec(@sql)
   
  Set @sql='update 其它费用明细表 Set YSQ=(Case when ((Select 金额 from 其它费用总账表 where AutoID=其它费用明细表.MainID)=0) then 0 Else ISNULL((select YSQ from 其它费用总账表 where AutoID=其它费用明细表.MainID)*金额/(select 金额 from 其它费用总账表 where AutoID=其它费用明细表.MainID),0) End) where 冲销=0'
  Exec(@sql)
  Set @sql='update 其它费用明细表 Set YFK=(Case when ((Select 金额 from 其它费用总账表 where AutoID=其它费用明细表.MainID)=0) then 0 Else ISNULL((select YFK from 其它费用总账表 where AutoID=其它费用明细表.MainID)*金额/(select 金额 from 其它费用总账表 where AutoID=其它费用明细表.MainID),0) End) where 冲销=0' 
  Exec(@sql)
   
  Set @sql='update 运输车辆明细表 Set YSQ=(Case when ((Select 金额 from 运输车辆总账表 where AutoID=运输车辆明细表.MainID)=0) then 0 Else ISNULL((select YSQ from 运输车辆总账表 where AutoID=运输车辆明细表.MainID)*金额/(select 金额 from 运输车辆总账表 where AutoID=运输车辆明细表.MainID),0) End) where 冲销=0'
  Exec(@sql)
  Set @sql='update 运输车辆明细表 Set YFK=(Case when ((Select 金额 from 运输车辆总账表 where AutoID=运输车辆明细表.MainID)=0) then 0 Else ISNULL((select YFK from 运输车辆总账表 where AutoID=运输车辆明细表.MainID)*金额/(select 金额 from 运输车辆总账表 where AutoID=运输车辆明细表.MainID),0) End) where 冲销=0' 
  Exec(@sql)
   
  Set @sql='update 固定设备维修明细表 Set YSQ=(Case when ((Select 金额 from 固定设备维修总账表 where AutoID=固定设备维修明细表.MainID)=0) then 0 Else ISNULL((select YSQ from 固定设备维修总账表 where AutoID=固定设备维修明细表.MainID)*金额/(select 金额 from 固定设备维修总账表 where AutoID=固定设备维修明细表.MainID),0) End) where 冲销=0'
  Exec(@sql)
  Set @sql='update 固定设备维修明细表 Set YFK=(Case when ((Select 金额 from 固定设备维修总账表 where AutoID=固定设备维修明细表.MainID)=0) then 0 Else ISNULL((select YFK from 固定设备维修总账表 where AutoID=固定设备维修明细表.MainID)*金额/(select 金额 from 固定设备维修总账表 where AutoID=固定设备维修明细表.MainID),0) End) where 冲销=0' 
  Exec(@sql)
    
End
