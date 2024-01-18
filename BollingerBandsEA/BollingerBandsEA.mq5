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
#include "GraphicalPanel.mqh"
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
   
   // create panel
   if(InpDisplayPanel){
      panel.Oninit();
   }
   
   return(INIT_SUCCEEDED);
}


//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // release Bollinger Bands indicator handle
   for(int i=0;i<NumberOfTradeableSymbols;i++){
      if(BB_handle[i]!=INVALID_HANDLE){IndicatorRelease(BB_handle[i]);}
      
      // release RSI indicator handle
      if(InpRSIPeriod>0){
         if(RSI_handle[i]!=INVALID_HANDLE){IndicatorRelease(RSI_handle[i]);}
      }
      
      //release AROON indicator handle
      if(InpAROONPeriod>0){
         if(AROON_handle[i]!=INVALID_HANDLE){IndicatorRelease(AROON_handle[i]);}
      }
   }
   // destroy panel
   if(InpDisplayPanel){
      panel.Destroy(reason);
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
//| Chart event handler                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam, const double &dparam, const string &sparam){
   if(!InpDisplayPanel){return;}
   panel.PanelChartEvent(id,lparam,dparam,sparam);
   

}
//+------------------------------------------------------------------+
