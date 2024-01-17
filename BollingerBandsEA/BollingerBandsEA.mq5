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
#include "MultiSymbols.mqh"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   if(!CheckInputs()){return INIT_PARAMETERS_INCORRECT;}
   trade.SetExpertMagicNumber(InpMagicnumber);
   
   // Multi-Symbol
   if(InpTradeSymbols == "CURRENT")  //Override TradeSymbols input variable and use the current chart symbol only
      {
         NumberOfTradeableSymbols = 1;
         
         ArrayResize(SymbolArray, 1);
         SymbolArray[0] = Symbol(); 

         Print("EA will process ", SymbolArray[0], " only");
      }
      else
      {  
         string TradeSymbolsToUse = "";
         
         if(InpTradeSymbols == "ALL")
            TradeSymbolsToUse = AllSymbolsString;
         else
            TradeSymbolsToUse = InpTradeSymbols;
         
         //CONVERT TradeSymbolsToUse TO THE STRING ARRAY SymbolArray
         NumberOfTradeableSymbols = StringSplit(TradeSymbolsToUse, '|', SymbolArray);
         
         Print("EA will process: ", TradeSymbolsToUse);
      }
   
   // Resize indicator arrays to match the number of symbols
   ResizeIndicatorArrays();
   
   Print("All arrays sized to accomodate ", NumberOfTradeableSymbols, " symbols");
   
   for(SymbolLoopIndex=0; SymbolLoopIndex < NumberOfTradeableSymbols; SymbolLoopIndex++){
      if(!InitIndicators()){return INIT_FAILED;}
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
   
   for(SymbolLoopIndex=0; SymbolLoopIndex < NumberOfTradeableSymbols; SymbolLoopIndex++){
      OnTickHelper();
   }
   
}
//+------------------------------------------------------------------+
