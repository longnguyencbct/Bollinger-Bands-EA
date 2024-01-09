//+------------------------------------------------------------------+
//| Input Configuration functions                                    |
//+------------------------------------------------------------------+
enum LOT_MODE_ENUM{
   LOT_MODE_FIXED,// fixed lots
   LOT_MODE_MONEY,// lots based on money
   LOT_MODE_PCT_ACCOUNT// lots based on % account
};
input group "==== General ====";
static input long InpMagicnumber= 1336;         // magic number
input double InpVolume = 0.01;                  //lots / money / percent size
input LOT_MODE_ENUM InpLotMode=LOT_MODE_FIXED;// lot mode
input int InpStopLoss = 100;                    //stop loss
input int InpTakeProfit = 200;                  //take profit
input ENUM_TIMEFRAMES InpTimeframe = PERIOD_H1; //Timeframe
input group "==== Bollinger Bands ====";
input int InpBBPeriod = 20;                     //period
input double InpDeviation = 2.0;                //deviation
input bool InpCloseAtBase = false;              //close trades at base?

bool CheckInputs(){
   if(InpMagicnumber<=0){
      Alert("Wrong input: Magicnumber <= 0");
      return(false);
   }
   if(InpVolume<=0){
      Alert("Wrong input: Lots size <= 0");
      return(false);
   }
   if(InpStopLoss<0){
      Alert("Wrong input: Stop loss < 0");
      return(false);
   }
   if(InpTakeProfit<0){
      Alert("Wrong input: Take profit < 0");
      return(false);
   }
   if(InpBBPeriod<=0){
      Alert("Wrong input: Period <= 0");
      return(false);
   }
   if(InpDeviation<=0){
      Alert("Wrong input: Deviation <= 0");
      return(false);
   }
   if(InpTakeProfit<=0&&!InpCloseAtBase){
      Alert("Warning: no take profit and no close at base");
   }
   return true;
}