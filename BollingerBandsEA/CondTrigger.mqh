#include "InpConfig.mqh"
#include "GlobalVar.mqh"
//+------------------------------------------------------------------+
//| Trigger functions                                                |
//+------------------------------------------------------------------+

bool Trigger(bool buy_sell){
   if(buy_sell){// buy
      return   PreviousTickAsk<=BB_lowerBuffer[0]
               &&cntBuy==0
               &&currentTick.ask>=BB_lowerBuffer[0]
               &&openTimeBuy!=iTime(_Symbol,InpTimeframe,0);
   }else{// sell
      return   PreviousTickBid>=BB_upperBuffer[0]
               &&cntSell==0
               &&currentTick.bid<=BB_upperBuffer[0]
               &&openTimeSell!=iTime(_Symbol,InpTimeframe,0);
   }
}