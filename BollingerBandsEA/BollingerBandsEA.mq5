//+------------------------------------------------------------------+
//|                                             BollingerBandsEA.mq5 |
//|           clongnguynvn@gmail.com or long.nguyencbct@hcmut.edu.vn |
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include "InpConfig.mqh"
#include "GlobalVar.mqh"
#include "Helper.mqh"
#include "CondTrigger.mqh"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   if(!CheckInputs()){return INIT_PARAMETERS_INCORRECT;}
   trade.SetExpertMagicNumber(InpMagicnumber);
   
   BB_handle=iBands(_Symbol,InpTimeframe,InpBBPeriod,1,InpDeviation,PRICE_CLOSE);
   if(BB_handle==INVALID_HANDLE){
      Alert("Failed to create Bollinger Bands indicatior handle");
      return INIT_FAILED;
   }
   
   ArraySetAsSeries(BB_upperBuffer,true);
   ArraySetAsSeries(BB_baseBuffer,true);
   ArraySetAsSeries(BB_lowerBuffer,true);
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //releae Bollinger Bands indicator handle
  if(BB_handle!=INVALID_HANDLE){IndicatorRelease(BB_handle);}
  
   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   //check if current tick is a bar open tick
   if(!IsNewBar()){return;}
   PreviousTickAsk=currentTick.ask;
   PreviousTickBid=currentTick.bid;
   //Get current tick
   if(!SymbolInfoTick(_Symbol,currentTick)){Print("Failed to get tick"); return;}
   //get indicator values
   Print("ask:"+string(currentTick.ask)+", bid:"+string(currentTick.bid)+", Prev_ask:"+string(PreviousTickAsk)+", Prev_bid:"+string(PreviousTickBid));////////
   int values=CopyBuffer(BB_handle,0,0,1,BB_baseBuffer)
             +CopyBuffer(BB_handle,1,0,1,BB_upperBuffer)
             +CopyBuffer(BB_handle,2,0,1,BB_lowerBuffer);
             
   if(values!=3){
      Print("Failed to get indicator values");
      return;
   }
   
   Comment("up[0]:",BB_upperBuffer[0],
           "\nbase[0]:",BB_baseBuffer[0],
           "\nlow[0]:",BB_lowerBuffer[0]);
           
   //count open positions
   if(!CountOpenPositions(cntBuy,cntSell)){return;}
   //check for lower band cross to open a buy position
   if(Trigger(true)){
      openTimeBuy=iTime(_Symbol,InpTimeframe,0);
      double sl = currentTick.bid-InpStopLoss*_Point;
      double tp = InpTakeProfit==0?0:currentTick.bid+InpTakeProfit*_Point;
      if(!NormalizePrice(sl,sl)){return;}
      if(!NormalizePrice(tp,tp)){return;}
      
      //calculate lots
      double lots;
      if(!CalculateLots(currentTick.bid-sl,lots)){return;}
      
      trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,lots,currentTick.ask,sl,tp,"Bollinger bands EA");  
   }
   //check for upper band cross to open a sell position
   if(Trigger(false)){
      openTimeSell=iTime(_Symbol,InpTimeframe,0);
      double sl = currentTick.ask+InpStopLoss*_Point;
      double tp = InpTakeProfit==0?0:currentTick.ask-InpTakeProfit*_Point;
      if(!NormalizePrice(sl,sl)){return;}
      if(!NormalizePrice(tp,tp)){return;}
      
      //calculate lots
      double lots;
      if(!CalculateLots(currentTick.bid-sl,lots)){return;}
      
      trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,lots,currentTick.bid,sl,tp,"Bollinger bands EA");  
   }
   
   //check for close at cross with base band
   if(!CountOpenPositions(cntBuy,cntSell)){return;}
   if(InpCloseAtBase&&cntBuy>0&&currentTick.bid>=BB_baseBuffer[0]){
      ClosePositions(1);
   }
   if(InpCloseAtBase&&cntBuy>0&&currentTick.ask<=BB_baseBuffer[0]){
      ClosePositions(2);
   }
   
   
}
//+------------------------------------------------------------------+
