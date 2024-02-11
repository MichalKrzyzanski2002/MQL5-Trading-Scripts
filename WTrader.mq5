//+------------------------------------------------------------------+
//|                                                 WiktorTrader.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\Trade.mqh>
input double volume=0.1;
input double sl=0.004;
input double tp=0.012;
input bool shorts=false;
input int boundary=25;
string marketOpen="05:00";
string marketClose="16:00";
CTrade trade ;
bool allowTrading=false;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(100000000);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
 string currentTime=TimeToString(TimeLocal(),TIME_MINUTES);
 if(StringSubstr(currentTime,0,5)==marketOpen){
    allowTrading=true;
 }
 if(StringSubstr(currentTime,0,5)==marketClose){
   allowTrading=false;
   //CloseBuyPositions();
   //CloseSellPositions();
 }
 //allowTrading=true;
//---
   int M=iMACD(_Symbol,PERIOD_M15,12,26,9,PRICE_OPEN) ;
   double MACD[];
   double Signal[];
   double balance=AccountInfoDouble(ACCOUNT_BALANCE);
   CopyBuffer(M,0,0,4,MACD) ;
   CopyBuffer(M,1,0,4,Signal) ;
   MqlRates PriceInfo[] ;
   ArraySetAsSeries(PriceInfo,true) ;
   int PData=CopyRates(Symbol(),Period(),0,27,PriceInfo);
   double Ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits) ;
   double Bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits) ;
   int E=iMA(_Symbol,PERIOD_CURRENT,200,0,MODE_EMA,PRICE_OPEN);
   double EMA[];
   CopyBuffer(E,0,0,4,EMA);
   Comment(MACD[0],Signal[0]);
   if(MACD[0]<Signal[0] && MACD[1]>Signal[1] && MACD[0]>MACD[1] && PriceInfo[0].open>EMA[0]&& PositionsTotal()==0 && allowTrading){
   trade.Buy(NormalizeDouble((balance/10000)*volume,2),NULL,Ask,Ask-(sl*Ask),Ask+(tp*Ask),NULL);
   }
   if(MACD[0]>Signal[0] && MACD[1]<Signal[1] && PriceInfo[0].open<EMA[0] && MACD[0]<MACD[1] && PositionsTotal()==0 && shorts && allowTrading){
   trade.Sell(NormalizeDouble((balance/10000)*volume,2),NULL,Bid,Bid+(sl*Bid),Bid-(tp*Bid),NULL);
   
   }
   if(PositionsTotal()==1 && (MACD[0]-Signal[0]<MACD[1]-Signal[1]) && MACD[1]-Signal[1]<MACD[2]-Signal[2] && MACD[2]-Signal[2]<MACD[3]-Signal[3]){
   CloseBuyPositions();
   }
   if(PositionsTotal()==1 && MACD[0]-Signal[0]>MACD[1]-Signal[1] && MACD[1]-Signal[1]>MACD[2]-Signal[2] && MACD[2]-Signal[2]>MACD[3]-Signal[3]){
   CloseSellPositions();
   }
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//--- 

  }
//+------------------------------------------------------------------+
void CloseBuyPositions() {
for(int i=0 ; i<PositionsTotal() ; i++) {
ulong ticket=PositionGetTicket(i);
ulong PositionType=PositionGetInteger(POSITION_TYPE);
if(PositionType==POSITION_TYPE_BUY) {
trade.PositionClose(ticket) ;
}
}
}
void CloseSellPositions() {
for(int i=0 ; i<PositionsTotal() ; i++) {
ulong ticket=PositionGetTicket(i);
ulong PositionType=PositionGetInteger(POSITION_TYPE);
if(PositionType==POSITION_TYPE_SELL) {
trade.PositionClose(ticket) ;
}
}
}