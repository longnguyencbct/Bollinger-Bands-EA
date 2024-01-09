//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
// Bollinger Bands variables
int BB_handle;
double BB_upperBuffer[];
double BB_baseBuffer[];
double BB_lowerBuffer[];

MqlTick currentTick;
CTrade trade;

datetime openTimeBuy=0;
datetime openTimeSell=0;
double PreviousTickAsk;
double PreviousTickBid;
int cntBuy, cntSell;