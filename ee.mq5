//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property description "Ichimoku Kinko Hyo"
#property description "Signal on breakout"
#property description "Single position"
#define STOPLOSS 1000
#include<Trade/Trade.mqh>
#include <Trade/AccountInfo.mqh>
CTrade trade ;
CAccountInfo info ;
input double PositionSize;
input short TENKANSEN ;
input short KIJUNSEN ;
input short SENKOUSPANB ;
input bool PercentSizing;
input double Percent;
input double RiskInPoints;
input double SL ;
input bool Pyramid ;
input double LayerWidth ;
input int LayerNumber ;
input int PyramidBack ;
input bool PyramidSl ;
input ENUM_MA_METHOD method;
input ENUM_APPLIED_PRICE price;
input int SLPeriod;
input int SLShift;
input int FalsePeriod;
input long SleepTime;
input bool SPyramid;
input bool LPyramid;
input int ConsolidationValue;
input int ConsolidationPeriod;
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
//---
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function |
//+------------------------------------------------------------------+
void OnTick()
  {
//Creating indicators
   int Ichimoku= iIchimoku(_Symbol,PERIOD_CURRENT,TENKANSEN,KIJUNSEN, 2 *KIJUNSEN)
                 ;
   int MA= iMA(_Symbol,PERIOD_CURRENT,SLPeriod,SLShift,method,price);
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
   CopyBuffer(MA, 0, 0,FalsePeriod+ 2,MAArray);
//Extracting price data
   double Ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits) ;
   double Bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits) ;
   MqlRates PriceInfo[] ;
   ArraySetAsSeries(PriceInfo, true) ;
   int PData=CopyRates(Symbol(),Period(), 0, 27,PriceInfo);
//Lot sizing
   double AutoLot ;
   if(PercentSizing== true)
     {
      if(LotSize(Percent,RiskInPoints)>= 0.1)
        {
         AutoLot=NormalizeDouble(LotSize(Percent,RiskInPoints), 1);
        }
      else
         AutoLot=NormalizeDouble(LotSize(Percent,RiskInPoints), 2);
     }
   else
     {
      AutoLot=PositionSize ;
     }
   bool consolidation
      =IsInConsolidation(ConsolidationPeriod,ConsolidationValue*_Point);
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
//buy signal requirements
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
//Opening buy position
   if(PositionsTotal()== 0 && bCrossedAvg== true && bOutCloud== true &&
      bFutureCloud== true && bTenkasenNotCrossed== true && PriceInfo[ 1 ].close>MAArray[ 1 ]
     )   //|| !(TenkasenArray[2]>KijunsenArray[2])))
     {
      trade.Buy(AutoLot, NULL,Ask,Ask-SL*Ask, NULL, NULL) ;
    
     }
//Closing buy position
   if(bTenkasenNotCrossed== false && sOutCloud== true && PositionsTotal()> 0)
     {
      CloseBuyPositions();
        Sleep(SleepTime);
     }
   if(MAArray[FalsePeriod+ 1 ]>PriceInfo[FalsePeriod+ 1 ].close &&
      MAArray[ 1 ]>PriceInfo[ 1 ].close && PositionsTotal()> 0)
     {
      CloseBuyPositions();
        Sleep(SleepTime);
     }
//Opening sell postion
   if(PositionsTotal()== 0 && sCrossedAvg== true && sOutCloud== true &&
      sFutureCloud== true && sTenkasenNotCrossed== true &&
      PriceInfo[ 1 ].close<MAArray[ 1 ])   //|| !(TenkasenArray[2]<KijunsenArray[2])))
     {
      trade.Sell(AutoLot, NULL,Bid,Bid+SL*Bid, NULL, NULL) ;
      
     }
//Closing sell position
   if(sTenkasenNotCrossed== false && bOutCloud== true && PositionsTotal()> 0)
     {
      CloseSellPositions();
      Sleep(SleepTime);
     }
   if(MAArray[FalsePeriod+ 1 ]<PriceInfo[FalsePeriod+ 1 ].close &&
      MAArray[ 1 ]<PriceInfo[ 1 ].close && PositionsTotal()> 0)
     {
      CloseSellPositions();
      Sleep(SleepTime);
     }
   Comment(bCrossedAvg,bOutCloud,bOutCloudAvg,bFutureCloud,bTenkasenNotCrossed,
           PositionsTotal());
//Pyramiding positions
   if(PositionsTotal()> 0 && Pyramid && PositionsTotal()<LayerNumber)
     {
      PositionSelectByTicket(PositionGetTicket(PositionsTotal() -1)) ;
      ulong PositionType=PositionGetInteger(POSITION_TYPE);
      double PositionOpen=PositionGetDouble(POSITION_PRICE_OPEN) ;
      double PositionProfit=PositionGetDouble(POSITION_PROFIT) ;
      if(MathAbs(PositionOpen-PriceInfo[ 1 ].close)>=(LayerWidth)*_Point &&
         PositionProfit> 0)
        {
         if(PositionType==POSITION_TYPE_BUY && LPyramid)
           {
            trade.Buy(AutoLot, NULL,Ask, NULL, NULL, NULL) ;
           }
         if(PositionType==POSITION_TYPE_SELL && SPyramid)
           {
            trade.Sell(AutoLot, NULL,Bid, NULL, NULL, NULL) ;
           }
        }
     }
//Pyramid stop loss tracking
   if(PyramidSl)
     {
      PyramidStopLoss(PyramidBack) ;
     }
  }
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
double LotSize(double Precent, double RiskInPoints)
  {
   double margin= AccountInfoDouble(ACCOUNT_BALANCE)*(Percent/ 100);
   double tickSize= SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double tradeSize=(margin/RiskInPoints)/tickSize;
   return tradeSize;
  }
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
void CloseBuyPositions()
  {
   for(int i= 0 ; i<PositionsTotal() ; i++)
     {
      ulong ticket=PositionGetTicket(i);
      ulong PositionType=PositionGetInteger(POSITION_TYPE);
      if(PositionType==POSITION_TYPE_BUY)
        {
         trade.PositionClose(ticket) ;
        }
     }
  }
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
void CloseSellPositions()
  {
   for(int i= 0 ; i<PositionsTotal() ; i++)
     {
      ulong ticket=PositionGetTicket(i);
      ulong PositionType=PositionGetInteger(POSITION_TYPE);
      if(PositionType==POSITION_TYPE_SELL)
        {
         trade.PositionClose(ticket) ;
        }
     }
  }
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
void PyramidStopLoss(int back)
  {
   if(PositionsTotal()>back)
     {
      PositionSelectByTicket(PositionGetTicket(PositionsTotal() -1 -back));
      double PriceOpen=PositionGetDouble(POSITION_PRICE_OPEN) ;
      for(int i= 0 ; i<PositionsTotal() ; i++)
        {
         trade.PositionModify(PositionGetTicket(i),PriceOpen, NULL);
         if(trade.ResultRetcode()==TRADE_RETCODE_INVALID_STOPS)
           {
            trade.PositionModify(PositionGetTicket(i), NULL,PriceOpen);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsInConsolidation(int period, double value)
  {
   MqlRates PriceInfo[] ;
   ArraySetAsSeries(PriceInfo, true) ;
   int s= 0 ;
   int PData=CopyRates(Symbol(),Period(), 0, 27,PriceInfo);
   for(int j= 2 ; j<period+ 2 ; j++)
     {
      s+=MathAbs(PriceInfo[ 1 ].close-PriceInfo[j].close);
     }
   s=(double)((double)s/(double)period);
   if(s>=value)
     {
      return false ;
     }
   if(s<value)
     {
      return true ;
     }
   return false ;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
