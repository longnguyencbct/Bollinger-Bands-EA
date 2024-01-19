#include "InpConfig.mqh"
#include "GlobalVar.mqh"
//+------------------------------------------------------------------+
//| Trigger function                                                 |
//+------------------------------------------------------------------+
bool Trigger(bool buy_sell){
   if(buy_sell){// buy
      return   cntBuy[SymbolLoopIndex]==0
               &&currentTick[SymbolLoopIndex].ask<BB_lowerBuffer[0];
   }else{// sell
      return   cntSell[SymbolLoopIndex]==0
               &&currentTick[SymbolLoopIndex].bid>BB_upperBuffer[0];
   }
}
//+------------------------------------------------------------------+
//| Filter function                                                  |
//+------------------------------------------------------------------+
bool Filter(bool buy_sell){
   return RSI_filter(buy_sell)&&AROON_filter(buy_sell);
}

bool RSI_filter(bool buy_sell){
   if(buy_sell){// buy
      return   InpRSIPeriod>0?RSI_Buffer[0]<=100-InpRSIUpperBand:true;
   }else{// sell
      return   InpRSIPeriod>0?RSI_Buffer[0]>=InpRSIUpperBand:true;
   }
}

bool AROON_filter(bool buy_sell){
   if(buy_sell){// buy
      return InpAROONPeriod!=0?curr_state[SymbolLoopIndex]==UP_TREND:true;
   }else{// sell
      return InpAROONPeriod!=0?curr_state[SymbolLoopIndex]==DOWN_TREND:true;
   }
}
//+------------------------------------------------------------------+
//| Close function                                                   |
//+------------------------------------------------------------------+
void CondClose(){
   //check for close when there is a new state or new direction
   if(new_state[SymbolLoopIndex]){
      if(InpCloseCond!=NO_CLOSING){
         ClosePositions(0);
      }
      new_state[SymbolLoopIndex]=false;
   }
   
   //check for close at cross with base band
   if(InpCloseAtBase&&cntBuy[SymbolLoopIndex]>0&&currentTick[SymbolLoopIndex].bid>=BB_baseBuffer[0]){
      ClosePositions(1);
   }
   if(InpCloseAtBase&&cntBuy[SymbolLoopIndex]>0&&currentTick[SymbolLoopIndex].ask<=BB_baseBuffer[0]){
      ClosePositions(2);
   }
}