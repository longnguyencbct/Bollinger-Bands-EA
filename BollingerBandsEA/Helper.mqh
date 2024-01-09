#include "InpConfig.mqh"
//+------------------------------------------------------------------+
//| Helper functions                                                 |
//+------------------------------------------------------------------+

//check if we hace a bar open tick
bool IsNewBar(){
   static datetime previousTime=0;
   datetime currentTime=iTime(_Symbol,InpTimeframe,0);
   if(previousTime!=currentTime){
      previousTime=currentTime;
      return true;
   }
   return false;
}

bool CountOpenPositions(int &countBuy,int &countSell){
   countBuy = 0;
   countSell =0;
   int total= PositionsTotal();
   for(int i=total-1;i>=0;i--){
      ulong positionTicket=PositionGetTicket(i);
      if(positionTicket<=0){Print("Failed to get ticket"); return false;}
      if(!PositionSelectByTicket(positionTicket)){Print("Failed to select position"); return false;}
      long magic;
      if(!PositionGetInteger(POSITION_MAGIC,magic)){Print("Failed to get magic"); return false;}
      if(magic==InpMagicnumber){
         long type;
         if(!PositionGetInteger(POSITION_TYPE,type)){Print("Failed to get type"); return false;}
         if(type==POSITION_TYPE_BUY){countBuy++;}
         if(type==POSITION_TYPE_SELL){countSell++;}
      }
   }
   return true;
}

bool NormalizePrice(double price,double &normalizedPrice){
   double tickSize=0;
   if(!SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE,tickSize)){
      Print("Failed to get tick size");
      return false;
   }
   normalizedPrice=NormalizeDouble(MathRound(price/tickSize)*tickSize,_Digits);
   return true;
}

bool ClosePositions(int all_buy_sell){
   int total= PositionsTotal();
   for(int i=total-1;i>=0;i--){
      ulong positionTicket=PositionGetTicket(i);
      if(positionTicket<=0){Print("Failed to get ticket"); return false;}
      if(!PositionSelectByTicket(positionTicket)){Print("Failed to select position"); return false;}
      long magic;
      if(!PositionGetInteger(POSITION_MAGIC,magic)){Print("Failed to get magic"); return false;}
      if(magic==InpMagicnumber){
         long type;
         if(!PositionGetInteger(POSITION_TYPE,type)){Print("Failed to get type"); return false;}
         if(all_buy_sell==1&&type==POSITION_TYPE_SELL){continue;}
         if(all_buy_sell==2&&type==POSITION_TYPE_BUY){continue;}
         trade.PositionClose(positionTicket);
         if(trade.ResultRetcode()!=TRADE_RETCODE_DONE){
            Print("Failed to close position ticket:",(string)positionTicket,
                  "result:",(string)trade.ResultRetcode()+":",trade.ResultRetcodeDescription());
            return false;
         }
      }
   }
   return true;
}