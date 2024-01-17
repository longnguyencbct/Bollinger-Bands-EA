//+------------------------------------------------------------------+
//| Multi-Symbols functions                                          |
//+------------------------------------------------------------------+
#include "GlobalVar.mqh"
#include "InpConfig.mqh"

void ResizeIndicatorArrays(){
   ArrayResize(curr_state, NumberOfTradeableSymbols);
   ArrayResize(new_state, NumberOfTradeableSymbols);
   
   ArrayResize(cntBuy, NumberOfTradeableSymbols);
   ArrayResize(cntSell, NumberOfTradeableSymbols);
   
   ArrayResize(currentTick, NumberOfTradeableSymbols);
   ArrayResize(PreviousTickAsk, NumberOfTradeableSymbols);
   ArrayResize(PreviousTickBid, NumberOfTradeableSymbols);
}

bool InitIndicators(){
   // Init Bollinger Bands
   BB_handle=iBands(SymbolArray[SymbolLoopIndex],InpTimeframe,InpBBPeriod,1,InpDeviation,PRICE_CLOSE);
   if(BB_handle==INVALID_HANDLE){
      Alert("Failed to create Bollinger Bands indicatior handle");
      return false;
   }
   
   ArraySetAsSeries(BB_upperBuffer,true);
   ArraySetAsSeries(BB_baseBuffer,true);
   ArraySetAsSeries(BB_lowerBuffer,true);
   
   // Init RSI
   if(InpRSIPeriod>0){
      RSI_handle=iRSI(SymbolArray[SymbolLoopIndex],InpTimeframe,InpRSIPeriod,PRICE_CLOSE);
      if(RSI_handle==INVALID_HANDLE){
         Alert("Failed to create RSI indicatior handle");
         return false;
      }
      
      ArraySetAsSeries(RSI_Buffer,true);
   }
   
   // Init AROON
   if(InpAROONPeriod>0){
      AROON_handle=iCustom(SymbolArray[SymbolLoopIndex],InpAROONTimeframe,"Custom\\aroon",InpAROONPeriod,InpAROONShift);
      
      if(AROON_handle==INVALID_HANDLE){
         Alert("Failed to create AROON indicatior handle");
         return false;
      }
      
      ArraySetAsSeries(AROON_Up,true);
      ArraySetAsSeries(AROON_Down,true);
   }
   return true;
}

void OnTickHelper(){
   PreviousTickAsk[SymbolLoopIndex]=currentTick[SymbolLoopIndex].ask;
   PreviousTickBid[SymbolLoopIndex]=currentTick[SymbolLoopIndex].bid;
   //Get current tick
   if(!SymbolInfoTick(SymbolArray[SymbolLoopIndex],currentTick[SymbolLoopIndex])){Print("Failed to get tick"); return;}
   
   //Get Bollinger Bands Indicator values
   //Print("ask:"+string(currentTick.ask)+", bid:"+string(currentTick.bid)+", Prev_ask:"+string(PreviousTickAsk)+", Prev_bid:"+string(PreviousTickBid));////////
   int values=CopyBuffer(BB_handle,0,0,1,BB_baseBuffer)
             +CopyBuffer(BB_handle,1,0,1,BB_upperBuffer)
             +CopyBuffer(BB_handle,2,0,1,BB_lowerBuffer);
             
   if(values!=3){
      Print("Failed to get Bollinger Bands indicator values, value:",values);
      Print(GetLastError());
      return;
   }
   
   //Get RSI Indicator values
   if(InpRSIPeriod>0){
      int values=CopyBuffer(RSI_handle,0,0,1,RSI_Buffer);
          
      if(values!=1){
         Print("Failed to get RSI indicator value, value:",values);
         Print(GetLastError());
         return;
      }
   }
   
   //Get AROON Indicator values
   string AROON_string="\nAROON: Deactivated";
   if(InpAROONPeriod!=0){
      int values=CopyBuffer(AROON_handle,0,0,1,AROON_Up)
                +CopyBuffer(AROON_handle,1,0,1,AROON_Down);
                
      if(values!=2){
         Print("Failed to get AROON  indicator values, value:",values);
         Print(GetLastError());
         return;
      }
      string curr_state_str;
      switch(curr_state[SymbolLoopIndex]){
         case UP_TREND:
            curr_state_str="Up Trend";
            break;
         case DOWN_TREND:
            curr_state_str="Down Trend";
            break;
         case NOT_TRENDING_FROM_UP:
            curr_state_str="Not Trending from Up";
            break;
         case NOT_TRENDING_FROM_DOWN:
            curr_state_str="Not Trending from Down";
            break;
      }
      AROON_string=("\nAROON:"+
              "\n Up[0]: "+string(AROON_Up[0])+
              "\n Down[0]: "+string(AROON_Down[0])+
              "\n Market State: "+curr_state_str);
   }
   //count open positions
   if(!CountOpenPositions(cntBuy[SymbolLoopIndex],cntSell[SymbolLoopIndex])){return;}
   Comment("Bollinger Bands:",
           "\n up[0]: ",BB_upperBuffer[0],
           "\n base[0]: ",BB_baseBuffer[0],
           "\n low[0]: ",BB_lowerBuffer[0],
           "\nRSI:",
           "\n RSI[0]: ",InpRSIPeriod>0?string(RSI_Buffer[0]):"Deactivated",
           AROON_string);
           
   // Trend Observation
   TrendObservation();
   
   // conditions to open a buy position
   if(Trigger(true)&&Filter(true)){
      Print("Open buy");
      openTimeBuy=iTime(SymbolArray[SymbolLoopIndex],InpTimeframe,0);
      double sl = currentTick[SymbolLoopIndex].bid-InpStopLoss*SymbolInfoDouble(SymbolArray[SymbolLoopIndex],SYMBOL_POINT);
      double tp = InpTakeProfit==0?0:currentTick[SymbolLoopIndex].bid+InpTakeProfit*SymbolInfoDouble(SymbolArray[SymbolLoopIndex],SYMBOL_POINT);
      if(!NormalizePrice(sl,sl)){return;}
      if(!NormalizePrice(tp,tp)){return;}
      
      //calculate lots
      double lots;
      if(!CalculateLots(currentTick[SymbolLoopIndex].bid-sl,lots)){return;}
      
      trade.PositionOpen(SymbolArray[SymbolLoopIndex],ORDER_TYPE_BUY,lots,currentTick[SymbolLoopIndex].ask,sl,tp,"Bollinger bands EA");  
   }
   // conditions to open a sell position
   if(Trigger(false)&&Filter(false)){
      Print("Open sell");
      openTimeSell=iTime(SymbolArray[SymbolLoopIndex],InpTimeframe,0);
      double sl = currentTick[SymbolLoopIndex].ask+InpStopLoss*SymbolInfoDouble(SymbolArray[SymbolLoopIndex],SYMBOL_POINT);
      double tp = InpTakeProfit==0?0:currentTick[SymbolLoopIndex].ask-InpTakeProfit*SymbolInfoDouble(SymbolArray[SymbolLoopIndex],SYMBOL_POINT);
      if(!NormalizePrice(sl,sl)){return;}
      if(!NormalizePrice(tp,tp)){return;}
      
      //calculate lots
      double lots;
      if(!CalculateLots(sl-currentTick[SymbolLoopIndex].ask,lots)){return;}
      
      trade.PositionOpen(SymbolArray[SymbolLoopIndex],ORDER_TYPE_SELL,lots,currentTick[SymbolLoopIndex].bid,sl,tp,"Bollinger bands EA");  
   }
   
   if(!CountOpenPositions(cntBuy[SymbolLoopIndex],cntSell[SymbolLoopIndex])){return;}
   //Close condition
   CondClose();
   
}