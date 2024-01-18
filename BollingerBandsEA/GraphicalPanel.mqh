//+------------------------------------------------------------------+
//| Graphical Panel                                                  |
//+------------------------------------------------------------------+

#include <Controls\Dialog.mqh>
#include <Controls\Label.mqh>
#include <Controls\Button.mqh>
#include <Controls\Defines.mqh>

#undef CONTROLS_FONT_NAME
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#define CONTROLS_FONT_NAME                "Console"
#define CONTROLS_DIALOG_COLOR_CLIENT_BG   C'0x20,0x20,0x20'

#include "GlobalVar.mqh"
#include "InpConfig.mqh"


class CGraphicalPanel : public CAppDialog{

   private:
      
      // private variables
      
      // labels
      CLabel m_lInput;
      CLabel m_lMagic;
      CLabel m_lSymbols;
      CLabel m_lVolume;
      
      // buttons
      CButton m_bChangeColor;
   
      // private methods
      bool CreatePanel();
   
   public:
   
      void CGraphicalPanel();
      void ~CGraphicalPanel();
      bool Oninit();
      
      //chart event handler
      void PanelChartEvent(const int id,const long &lparam, const double &dparam, const string &sparam);

};

// constructor
void CGraphicalPanel::CGraphicalPanel(void){}

// deconstructor
void CGraphicalPanel::~CGraphicalPanel(void){}

bool CGraphicalPanel::Oninit(void){

   // create panel
   if(!this.CreatePanel()){return false;}

   return true;
}

bool CGraphicalPanel::CreatePanel(void){

   // create dialog panel
   this.Create(NULL,"Bollinger Bands EA",0,0,0,PanelWidth,PanelHeight);
   
   m_lInput.Create(NULL,"lInputs",0,20,10,1,1);
   m_lInput.Text("Inputs");
   m_lInput.Color(clrLime);
   m_lInput.FontSize(PanelFontsize);
   this.Add(m_lInput);
   
   m_lMagic.Create(NULL,"lMagic",0,20,30,1,1);
   m_lMagic.Text("Magicnumber: "+(string)InpMagicnumber);
   m_lMagic.Color(clrRed);
   m_lMagic.FontSize(PanelFontsize);
   this.Add(m_lMagic);
   
   string TradeSymbolsString="";
   for(int i=0;i<NumberOfTradeableSymbols;i++){
      TradeSymbolsString+=" "+SymbolArray[i].Substr(0,6);
   }
   m_lSymbols.Create(NULL,"lSymbols",0,20,50,1,1);
   m_lSymbols.Text("Symbols: "+TradeSymbolsString);
   m_lSymbols.Color(clrRed);
   m_lSymbols.FontSize(PanelFontsize);
   this.Add(m_lSymbols);
   
   string LotModeString;
   switch(InpLotMode){
      case LOT_MODE_FIXED:
         LotModeString=" lot";
         break;
      case LOT_MODE_MONEY:
         LotModeString=" USD";
         break;
      case LOT_MODE_PCT_ACCOUNT:
         LotModeString=" %";
         break;
   }
   
   m_lVolume.Create(NULL,"lVolume",0,20,70,1,1);
   m_lVolume.Text("Volume: "+(string)InpVolume+LotModeString);
   m_lVolume.Color(clrRed);
   m_lVolume.FontSize(PanelFontsize);
   this.Add(m_lVolume);
   
   m_bChangeColor.Create(NULL,"bChangeColor",0,20,150,230,180);
   m_bChangeColor.Text("Change color");
   m_bChangeColor.Color(clrWhite);
   m_bChangeColor.ColorBackground(clrDarkRed);
   m_bChangeColor.FontSize(PanelFontsize);
   this.Add(m_bChangeColor);
   
   // run panel
   if(!Run()){Print("Failed to run panel"); return false;}

   // refresh chart
   ChartRedraw();

   return true;
}

void CGraphicalPanel::PanelChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam){

   // call chart event method of case class
   ChartEvent(id,lparam,dparam,sparam);
   

}