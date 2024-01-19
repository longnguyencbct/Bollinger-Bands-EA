//+------------------------------------------------------------------+
//| Withdrawal Configuration functions                               |
//+------------------------------------------------------------------+
#include "InpConfig.mqh"
#include "GlobalVar.mqh"

//check if we have a new withdrawal bar open tick
bool IsNewWithdrawalBar(){
   static datetime previousTime=0;
   datetime currentTime=iTime(_Symbol,InpWithdrawalTimeframe,0);
   if(previousTime!=currentTime){
      previousTime=currentTime;
      return true;
   }
   return false;
}

bool CheckWithdrawal(){
   if(!IsNewWithdrawalBar()){return false;}
   currWithdrawBarsCounter++;
   if(currWithdrawBarsCounter>=InpWithdrawalPeriod){
      currWithdrawBarsCounter=0;
      return true;
   }
   return false;
   
}
void WithdrawalFunction(){
   if(!CheckWithdrawal()){return;}
   Print("It's money shower time baby!!!!!!");
}