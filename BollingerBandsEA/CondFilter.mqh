#include "InpConfig.mqh"
#include "GlobalVar.mqh"
//+------------------------------------------------------------------+
//| Filter functions                                                 |
//+------------------------------------------------------------------+

bool Filter(bool buy_sell){
   if(buy_sell){// buy
      return   InpRSIPeriod>0?RSI_Buffer[0]>=InpRSIUpperBand:true;
   }else{// sell
      return   InpRSIPeriod>0?RSI_Buffer[0]<=100-InpRSIUpperBand:true;
   }
}