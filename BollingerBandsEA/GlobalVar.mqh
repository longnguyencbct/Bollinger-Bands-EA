//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+

enum MARKET_STATE{
   UP_TREND,
   DOWN_TREND,
   NOT_TRENDING_FROM_UP,
   NOT_TRENDING_FROM_DOWN
};
// Trend Observation variables
MARKET_STATE curr_state[];
bool new_state[];

// Bollinger Bands variables
int BB_handle[];
double BB_upperBuffer[];
double BB_baseBuffer[];
double BB_lowerBuffer[];

// RSI variables
int RSI_handle[];          
double RSI_Buffer[]; 


//AROON Indicator variables
int AROON_handle[];
double AROON_Up[];
double AROON_Down[];

// Multi-Symbol Variables
string   AllSymbolsString           = "AUDCAD|AUDJPY|AUDNZD|AUDUSD|CADJPY|EURAUD|EURCAD|EURGBP|EURJPY|EURNZD|EURUSD|GBPAUD|GBPCAD|GBPJPY|GBPNZD|GBPUSD|NZDCAD|NZDJPY|NZDUSD|USDCAD|USDCHF|USDJPY";
int      NumberOfTradeableSymbols;              
string   SymbolArray[];   
int      TicksReceivedCount         = 0;
   
MqlTick currentTick[];
CTrade trade;

datetime openTimeBuy=0;
datetime openTimeSell=0;
double PreviousTickAsk[];
double PreviousTickBid[];
int cntBuy[], cntSell[];

int SymbolLoopIndex;