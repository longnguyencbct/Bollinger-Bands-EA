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
#include "TriggerFilterClose.mqh"
#include "TrendObservation.mqh"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   if(!CheckInputs()){return INIT_PARAMETERS_INCORRECT;}
   trade.SetExpertMagicNumber(InpMagicnumber);
   
   // Init Bollinger Bands
   BB_handle=iBands(_Symbol,InpTimeframe,InpBBPeriod,1,InpDeviation,PRICE_CLOSE);
   if(BB_handle==INVALID_HANDLE){
      Alert("Failed to create Bollinger Bands indicatior handle");
      return INIT_FAILED;
   }
   
   ArraySetAsSeries(BB_upperBuffer,true);
   ArraySetAsSeries(BB_baseBuffer,true);
   ArraySetAsSeries(BB_lowerBuffer,true);
   
   // Init RSI
   if(InpRSIPeriod>0){
      RSI_handle=iRSI(_Symbol,InpTimeframe,InpRSIPeriod,PRICE_CLOSE);
      if(RSI_handle==INVALID_HANDLE){
         Alert("Failed to create RSI indicatior handle");
         return INIT_FAILED;
      }
      
      ArraySetAsSeries(RSI_Buffer,true);
   }
   
   // Init AROON
   if(InpAROONPeriod>0){
      AROON_handle=iCustom(_Symbol,InpAROONTimeframe,"Custom\\aroon",InpAROONPeriod,InpAROONShift);
      
      if(AROON_handle==INVALID_HANDLE){
         Alert("Failed to create AROON indicatior handle");
         return INIT_FAILED;
      }
      
      ArraySetAsSeries(AROON_Up,true);
      ArraySetAsSeries(AROON_Down,true);
   }
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // release Bollinger Bands indicator handle
   if(BB_handle!=INVALID_HANDLE){IndicatorRelease(BB_handle);}
   
   // release RSI indicator handle
   if(InpRSIPeriod>0){
      if(RSI_handle!=INVALID_HANDLE){IndicatorRelease(RSI_handle);}
   }
   
   //release AROON indicator handle
   if(InpAROONPeriod>0){
      if(AROON_handle!=INVALID_HANDLE){IndicatorRelease(AROON_handle);}
   }
   
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
      switch(curr_state){
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
   if(!CountOpenPositions(cntBuy,cntSell)){return;}
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
   // conditions to open a sell position
   if(Trigger(false)&&Filter(false)){
      Print("Open sell");
      openTimeSell=iTime(_Symbol,InpTimeframe,0);
      double sl = currentTick.ask+InpStopLoss*_Point;
      double tp = InpTakeProfit==0?0:currentTick.ask-InpTakeProfit*_Point;
      if(!NormalizePrice(sl,sl)){return;}
      if(!NormalizePrice(tp,tp)){return;}
      
      //calculate lots
      double lots;
      if(!CalculateLots(sl-currentTick.ask,lots)){return;}
      
      trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,lots,currentTick.bid,sl,tp,"Bollinger bands EA");  
   }
   
   if(!CountOpenPositions(cntBuy,cntSell)){return;}
   //Close condition
   CondClose();
   
   
}
//+------------------------------------------------------------------+
