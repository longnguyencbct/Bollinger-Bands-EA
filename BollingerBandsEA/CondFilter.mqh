#include "InpConfig.mqh"
#include "GlobalVar.mqh"
//+------------------------------------------------------------------+
//| Filter functions                                                 |
//+------------------------------------------------------------------+

bool Filter(bool buy_sell){
   if(buy_sell){// buy
      return   RSI_Buffer[0]>=InpRSIUpperBand;
   }else{// sell
      return   RSI_Buffer[0]<=InpRSILowerBand;
   }
}