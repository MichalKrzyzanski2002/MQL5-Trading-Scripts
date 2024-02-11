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
input short TENKANSEN ;
input short KIJUNSEN ;
input short SENKOUSPANB ;
string marketOpen="01:00";
string marketClose="23:00";
CTrade trade ;
bool failed_short=false;
bool failed_long=false;
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
   
   double balance=AccountInfoDouble(ACCOUNT_BALANCE);
   MqlRates PriceInfo15[] ;
   MqlRates PriceInfo30[] ;
   ArraySetAsSeries(PriceInfo15,true) ;
   ArraySetAsSeries(PriceInfo30,true) ;
   int PData15=CopyRates(Symbol(),PERIOD_M15,0,27,PriceInfo15);
   int PData30=CopyRates(Symbol(),PERIOD_M30,0,27,PriceInfo30);
   double Ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits) ;
   double Bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits) ;
   double h15_1[4];
   double h15_2[4];
   double h30[4];
   HEIKEN_ASHI(PriceInfo15[0].open,PriceInfo15[0].close,PriceInfo15[0].high,PriceInfo15[0].low,PriceInfo15[1].open,PriceInfo15[1].close,h15_1);
   HEIKEN_ASHI(PriceInfo15[1].open,PriceInfo15[1].close,PriceInfo15[1].high,PriceInfo15[1].low,PriceInfo15[2].open,PriceInfo15[2].close,h15_2);
   HEIKEN_ASHI(PriceInfo30[0].open,PriceInfo30[0].close,PriceInfo30[0].high,PriceInfo30[0].low,PriceInfo30[1].open,PriceInfo30[1].close,h30);
   
   int Ichimoku= iIchimoku(_Symbol,PERIOD_CURRENT,TENKANSEN,KIJUNSEN, 2 *KIJUNSEN)
                 ;
   
   double TenkasenArray[] ;
   double KijunsenArray[] ;
   double SenkouspanBArray[] ;
   double Chikouspan[] ;
   double SenkouspanAArray[] ;
   double MAArray[];
   CopyBuffer(Ichimoku, 0, 0, 3,TenkasenArray) ;
   CopyBuffer(Ichimoku, 1, 0, 3,KijunsenArray) ;
   CopyBuffer(Ichimoku, 3,-KIJUNSEN, 2 *KIJUNSEN+ 1, SenkouspanBArray) ;
   CopyBuffer(Ichimoku, 2,-KIJUNSEN, 2 *KIJUNSEN+ 1, SenkouspanAArray) ;
   CopyBuffer(Ichimoku, 4, 0, 3, Chikouspan) ;
   
   MqlRates PriceInfo[] ;
   ArraySetAsSeries(PriceInfo,true) ;
   int PData=CopyRates(Symbol(),Period(),0,27,PriceInfo);
   
   bool bCrossedAvg = false ;
   bool bOutCloud = false ;
   bool bLag = false ;
   bool bFutureCloud = false ;
   bool bOutCloudAvg= false ;
   bool bTenkasenNotCrossed= false ;
   bool sCrossedAvg = false ;
   bool sOutCloud = false ;
   bool sLag = false ;
   bool sFutureCloud = false ;
   bool sOutCloudAvg= false ;
   bool sTenkasenNotCrossed= false ;
  
   
   
    if(TenkasenArray[ 1 ]>KijunsenArray[ 1 ])
     {
      bCrossedAvg= true ;
     }
   if(PriceInfo[ 1 ].close>SenkouspanAArray[KIJUNSEN] &&
      PriceInfo[ 1 ].close>SenkouspanBArray[KIJUNSEN])
     {
      bOutCloud= true ;
     }
   if(PriceInfo[ 1 ].close>SenkouspanAArray[ 1 ] &&
      PriceInfo[ 1 ].close>SenkouspanBArray[ 1 ])
     {
      bLag= true ;
     }
   if(SenkouspanAArray[SENKOUSPANB]>SenkouspanBArray[SENKOUSPANB])
     {
      bFutureCloud= true ;
     }
   if(TenkasenArray[ 1 ]>SenkouspanAArray[KIJUNSEN] &&
      KijunsenArray[ 1 ]>SenkouspanAArray[KIJUNSEN] &&
      TenkasenArray[ 1 ]>SenkouspanBArray[KIJUNSEN] &&
      KijunsenArray[ 1 ]>SenkouspanBArray[KIJUNSEN])
     {
      bOutCloudAvg= true ;
     }
   if(TenkasenArray[ 1 ]<PriceInfo[ 1 ].close)
     {
      bTenkasenNotCrossed= true ;
     }
//sell signal requirements
   if(TenkasenArray[ 1 ]<=KijunsenArray[ 1 ])
     {
      sCrossedAvg= true ;
     }
   if(PriceInfo[ 1 ].close<SenkouspanAArray[KIJUNSEN] &&
      PriceInfo[ 1 ].close<SenkouspanBArray[KIJUNSEN])
     {
      sOutCloud= true ;
     }
   if(PriceInfo[ 1 ].close<SenkouspanAArray[ 1 ] &&
      PriceInfo[ 1 ].close<SenkouspanBArray[ 1 ])
     {
      sLag= true ;
     }
   if(SenkouspanAArray[SENKOUSPANB]<SenkouspanBArray[SENKOUSPANB])
     {
      sFutureCloud= true ;
     }
   if(TenkasenArray[ 1 ]<SenkouspanAArray[KIJUNSEN] &&
      KijunsenArray[ 1 ]<SenkouspanAArray[KIJUNSEN] &&
      TenkasenArray[ 1 ]<SenkouspanBArray[KIJUNSEN] &&
      KijunsenArray[ 1 ]<SenkouspanBArray[KIJUNSEN])
     {
      sOutCloudAvg= true ;
     }
   if(TenkasenArray[ 1 ]>PriceInfo[ 1 ].close)
     {
      sTenkasenNotCrossed= true ;
      }
   

//---
  
   
   if(h15_1[0]>h15_1[1]  && h15_2[0]>h15_2[1] && !(h30[0]<h30[1]) && PositionsTotal()==0 && bOutCloud){
   trade.Buy(NormalizeDouble((balance/10000)*volume,2),NULL,Ask,Ask-(sl*Ask),Ask+(tp*Ask),NULL);
   }
   if(h15_1[0]<h15_1[1]  && h15_2[0]<h15_2[1] && !(h30[0]>h30[1]) && PositionsTotal()==0 && sOutCloud){
   trade.Sell(NormalizeDouble((balance/10000)*volume,2),NULL,Bid,Bid+(sl*Bid),Bid-(tp*Bid),NULL);
   
   }
   if(h30[0]<h30[1] && PositionsTotal()>0){
   CloseBuyPositions();
   }
   if(h30[0]>h30[1] && PositionsTotal()>0){
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

void HEIKEN_ASHI (double open,double close,double high,double low, double open_prev, double close_prev, double& candle[]){
candle[0]=(open+close+high+low)/4;
candle[1]=(open_prev+close_prev)/2;
candle[2]=MathMax(MathMax(open,close),high);
candle[3]=MathMin(MathMin(open,close),low);

}

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
