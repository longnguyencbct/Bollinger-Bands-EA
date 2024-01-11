//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
// Bollinger Bands variables
int BB_handle;
double BB_upperBuffer[];
double BB_baseBuffer[];
double BB_lowerBuffer[];

// RSI variables
int RSI_handle;          
double RSI_Buffer[]; 

MqlTick currentTick;
CTrade trade;

datetime openTimeBuy=0;
datetime openTimeSell=0;
double PreviousTickAsk;
double PreviousTickBid;
int cntBuy, cntSell;