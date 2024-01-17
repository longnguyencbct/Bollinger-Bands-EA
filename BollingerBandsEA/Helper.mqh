#include "InpConfig.mqh"
#include "GlobalVar.mqh"
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

bool CountOpenPositions(int &countBuy,int &countSell,int SymbolLoopIndex){
   countBuy = 0;
   countSell =0;
   int total= PositionsTotal();
   for(int i=total-1;i>=0;i--){
      ulong positionTicket=PositionGetTicket(i);
      if(positionTicket<=0){Print("Failed to get ticket"); return false;}
      if(!PositionSelectByTicket(positionTicket)){Print("Failed to select position"); return false;}
      long magic;
      string symbol;
      if(!PositionGetInteger(POSITION_MAGIC,magic)){Print("Failed to get magic"); return false;}
      if(!PositionGetString(POSITION_SYMBOL,symbol)){Print("Failed to get symbol"); return false;}
      if(magic==InpMagicnumber&&symbol==SymbolArray[SymbolLoopIndex]){
         long type;
         if(!PositionGetInteger(POSITION_TYPE,type)){Print("Failed to get type"); return false;}
         if(type==POSITION_TYPE_BUY){countBuy++;}
         if(type==POSITION_TYPE_SELL){countSell++;}
      }
   }
   return true;
}

bool NormalizePrice(double price,double &normalizedPrice, int SymbolLoopIndex){
   double tickSize=0;
   if(!SymbolInfoDouble(SymbolArray[SymbolLoopIndex],SYMBOL_TRADE_TICK_SIZE,tickSize)){
      Print("Failed to get tick size");
      return false;
   }
   normalizedPrice=NormalizeDouble(MathRound(price/tickSize)*tickSize,int(SymbolInfoInteger(SymbolArray[SymbolLoopIndex],SYMBOL_DIGITS)));
   return true;
}

bool ClosePositions(int all_buy_sell, int SymbolLoopIndex){
   int total= PositionsTotal();
   for(int i=total-1;i>=0;i--){
      ulong positionTicket=PositionGetTicket(i);
      if(positionTicket<=0){Print("Failed to get ticket"); return false;}
      if(!PositionSelectByTicket(positionTicket)){Print("Failed to select position"); return false;}
      long magic;
      string symbol;
      if(!PositionGetInteger(POSITION_MAGIC,magic)){Print("Failed to get magic"); return false;}
      if(!PositionGetString(POSITION_SYMBOL,symbol)){Print("Failed to get symbol"); return false;}
      if(magic==InpMagicnumber&&symbol==SymbolArray[SymbolLoopIndex]){
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

//Calculate lots
bool CalculateLots(double slDistance, double &lots, int SymbolLoopIndex){
   lots=0.0;
   if(InpLotMode==LOT_MODE_FIXED){
      lots=InpVolume;
   }
   else{
      double tickSize=SymbolInfoDouble(SymbolArray[SymbolLoopIndex],SYMBOL_TRADE_TICK_SIZE);
      double tickValue=SymbolInfoDouble(SymbolArray[SymbolLoopIndex],SYMBOL_TRADE_TICK_VALUE);
      double volumeStep=SymbolInfoDouble(SymbolArray[SymbolLoopIndex],SYMBOL_VOLUME_STEP);
      
      double riskMoney = InpLotMode==LOT_MODE_MONEY?InpVolume:AccountInfoDouble(ACCOUNT_EQUITY)*InpVolume*0.01;
      double moneyVolumeStep=(slDistance/tickSize)*tickValue*volumeStep;
      
      lots=MathFloor(riskMoney/moneyVolumeStep)*volumeStep;
   }
   //check calculated lots
   if(!CheckLots(lots,SymbolLoopIndex)){return false;}
   
   return true;
}

//check lots for min, max and step
bool CheckLots(double &lots, int SymbolLoopIndex){
   
   double min = SymbolInfoDouble(SymbolArray[SymbolLoopIndex],SYMBOL_VOLUME_MIN);
   double max = SymbolInfoDouble(SymbolArray[SymbolLoopIndex],SYMBOL_VOLUME_MAX);
   double step = SymbolInfoDouble(SymbolArray[SymbolLoopIndex],SYMBOL_VOLUME_STEP);
   
   if(lots<min){
      Print("Lot size will be set to the minimum allowable volume");
      lots=min;
      return true;
   }
   if(lots>max){
      Print("Lot size greater than and will be set to the maximum allowable volume. lots:",lots,", max:",max);
      lots=max;
      return true;
   }
   lots=(int)MathFloor(lots/step)*step;
   return  true;
}