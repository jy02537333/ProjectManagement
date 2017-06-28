Create PROCEDURE [dbo].[GetZLJE] 
@AKCL Float ,
@ABDSL Float,
@ARQ DateTime,
@BRQ DateTime,
@ZLDJ_Def Float,
@DWTS_Def Float output,
@ZLJE  Float output
AS
Begin
  
   declare @TS Float
   declare @StartDate DateTime
   declare @EndDate DateTime
   declare @AZLDJ Float
   declare @I Int
   declare @CalcedDays Float
   declare @FoundBof Bit
   declare @FoundEof Bit
   declare @Sql Varchar(1000)   
   
   Set @ZLJE=0
 
    Set @FoundBof=0
    Set @FoundEof=0
    Set @CalcedDays=0 
    
    --应该先判断  临时表在不在

    Set @Sql='Declare cur_ZLDJ_Temp Cursor Global For Select 开始日期,终止日期,租赁单价 From #固定设备租赁单价临时表' 
    Exec(@Sql)
    Open cur_ZLDJ_Temp
    Fetch Next From cur_ZLDJ_Temp into @StartDate,@EndDate,@AZLDJ  
    Set @AZLDJ=ISNULL(@AZLDJ,0) 
 
    While (@@Fetch_Status=0) 
    Begin 

      IF (@ARQ=-1 or (@ARQ Is NULL) ) And (@ABDSL>0)  
      Begin
        IF ( DateDiff(DD,@StartDate,@BRQ)>=0) And (DateDiff(DD,@EndDate,@BRQ) <=0 )    
        Begin
          Set @ZLJE=@ZLJE+ @ABDSL*@AZLDJ
          Set @DWTS_Def=@DWTS_Def+@ABDSL
          Close cur_ZLDJ_Temp
          deallocate cur_ZLDJ_Temp  
          Return  
        End
      End 
       
      IF Not (  (@ARQ=-1 or (@ARQ Is NULL) ) And (@ABDSL>0)  )
      Begin
		  IF ( DateDiff(DD,@StartDate,@ARQ)>=0) And (DateDiff(DD,@EndDate,@ARQ) <=0 )    
		  Begin
			Set @FoundBof=1
			IF (DateDiff(DD,@StartDate,@BRQ)>=0  ) And (DateDiff(DD,@EndDate,@BRQ)<=0)  
			Begin
			  Set @TS=DateDiff(DD,@ARQ,@BRQ)+1    
			  Set @DWTS_Def=@DWTS_Def+@TS
			  Set @ZLJE=@ZLJE+@TS*@AZLDJ*@AKCL
			  Set @FoundEof=1
			  IF @ABDSL>0 
			  Begin
				 Set @ZLJE=@ZLJE+@ABDSL*@AZLDJ
				 Set @DWTS_Def=@DWTS_Def+@ABDSL
			  End
			  Close cur_ZLDJ_Temp
			  deallocate cur_ZLDJ_Temp 
			  Return
			End
	        
			IF Not ( ( DateDiff(DD,@StartDate,@BRQ)>=0 ) And ( DateDiff(DD,@EndDate,@BRQ)<=0 )  ) 
			Begin
			  Set @TS=DateDiff(DD,@ARQ,@EndDate)+1  
			  Set @CalcedDays=@CalcedDays+@TS
			  Set @DWTS_Def=@DWTS_Def+@TS 
			  Set @ZLJE=@ZLJE+@TS*@AZLDJ*@AKCL
			End 
		  End 
	      
		  IF (DateDiff(DD,@StartDate,@ARQ)<0 ) And ( DateDiff(DD,@EndDate,@BRQ)>0  )   
		  Begin
			--Set @FoundEof=1
			Set @TS=DateDiff(DD,@StartDate,@EndDate)+1 
			Set @CalcedDays=@CalcedDays+@TS
			Set @DWTS_Def=@DWTS_Def+@TS
			Set @ZLJE=@ZLJE+@TS*@AZLDJ*@AKCL
		  End 
		  IF (DateDiff(DD,@StartDate,@BRQ) >=0) And (DateDiff(DD,@EndDate,@BRQ)<=0)  
		  Begin
			Set @FoundEof=1
			Set @TS=DateDiff(DD,@StartDate,@BRQ)+1 
			Set @CalcedDays=@CalcedDays+@TS
			Set @DWTS_DEF=@DWTS_DEF+@TS
			Set @ZLJE=@ZLJE+@TS*@AZLDJ*@AKCL
			IF @ABDSL>0 
			Begin
			   Set @ZLJE=@ZLJE+ @ABDSL*@AZLDJ 
			   Set @DWTS_Def=@DWTS_Def+@ABDSL
			End
		  End
	  End
	  
      Fetch Next From cur_ZLDJ_Temp into @StartDate,@EndDate,@AZLDJ  
    End 

    Close cur_ZLDJ_Temp
    deallocate cur_ZLDJ_Temp       

    IF (@ARQ=-1 or @ARQ Is NULL) And (@ABDSL>0)  
    Begin 
      Set @ZLJE=@ZLJE+ @ABDSL*@ZLDJ_Def
      Set @DWTS_Def=@DWTS_Def+@ABDSL
      Return  
    End 
       
      
    Set @TS=DateDiff(DD,@ARQ,@BRQ)+1 
    Set @TS=@TS-@CalcedDays
    Set @DWTS_Def=@DWTS_Def+@TS*@AKCL
    Set @ZLJE=@ZLJE+@TS*@ZLDJ_Def*@AKCL
    IF ( @FoundEof=0) And (@ABDSL>0) 
    Begin
       Set @ZLJE=@ZLJE+@ABDSL*@ZLDJ_Def
       Set @DWTS_Def=@DWTS_Def+@ABDSL
    End
 


END
