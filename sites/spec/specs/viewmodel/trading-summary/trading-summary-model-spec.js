import TradingSummaryModel from "src/viewmodel/trading-summary/trading-summary-model"

describe("TradingSummaryModel", () => {

  var loader;
  var model;

  beforeEach(() => {
    model = new TradingSummaryModel({
      states:          {
        count:  10,
        exited: 8
      },
      winsAndLosses: {
        win:  4,
        lose: 4,
        draw: 2
      },
      sellOrBuy:     { sell: 6, buy: 4 },
      pairs:           {
        EURJPY: 6,
        USDJPY: 4
      },
      profitOrLoss:  {
        maxProfit:          1400,
        maxLoss:            -1200,
        avgProfit:          1200,
        avgLoss:            -1000,
        totalProfit:        5800,
        totalLoss:          -4000,
        totalProfitOrLoss:  1800,
        profitFactor:       1.2
      },
      holdingPeriod:  {
        maxPeriod: 200,
        minPeriod: 10,
        avgPeriod: 100
      },
      units:           {
        maxUnits: 1400,
        minUnits: 500,
        avgUnits: 980
      },
      agentSummary:   {
        a1 : {
          states: {
            count:  5,
            exited: 4
          },
          winsAndLosses: {
            win:  2,
            lose: 2,
            draw: 1
          },
          sellOrBuy: { sell: 3, buy: 2 },
          pairs: {
            EURJPY: 3,
            USDJPY: 2
          },
          profitOrLoss:  {
            maxProfit:          1400,
            maxLoss:            -1200,
            avgProfit:          1200,
            avgLoss:            -1000,
            totalProfit:        2400,
            totalLoss:          -2000,
            totalProfitOrLoss:   400,
            profitFactor:       1.2
          },
          holdingPeriod:  {
            maxPeriod: 200,
            minPeriod: 10,
            avgPeriod: 100
          },
          units:           {
            maxUnits: 1400,
            minUnits: 500,
            avgUnits: 980
          }
        },
        a2 : {
          states: {
            count:  5,
            exited: 4
          },
          winsAndLosses: {
            win:  2,
            lose: 2,
            draw: 1
          },
          sellOrBuy: { sell: 3, buy: 2 },
          pairs: {
            EURJPY: 3,
            USDJPY: 2
          },
          profitOrLoss:  {
            maxProfit:          1400,
            maxLoss:            -1200,
            avgProfit:          1200,
            avgLoss:            -1000,
            totalProfit:        2400,
            totalLoss:          -2000,
            totalProfitOrLoss:   400,
            profitFactor:       1.2
          },
          holdingPeriod:  {
            maxPeriod: 200,
            minPeriod: 10,
            avgPeriod: 100
          },
          units:           {
            maxUnits: 1400,
            minUnits: 500,
            avgUnits: 980
          }
        },
        a3 : {
          states: {
            count:  0,
            exited: 0
          },
          winsAndLosses: {
            win:  0,
            lose: 0,
            draw: 0
          },
          sellOrBuy: { sell: 0, buy: 0 },
          pairs: {
            EURJPY: 0,
            USDJPY: 0
          },
          profitOrLoss:  {
            maxProfit:          0,
            maxLoss:            0,
            avgProfit:          0,
            avgLoss:            0,
            totalProfit:        0,
            totalLoss:          0,
            totalProfitOrLoss:  0,
            profitFactor:       0
          },
          holdingPeriod:  {
            maxPeriod: 0,
            minPeriod: 0,
            avgPeriod: 0
          },
          units:           {
            maxUnits: 0,
            minUnits: 0,
            avgUnits: 0
          }
        }
      }
    });
  });

  it("formatedProfitOrLoss", () => {
    expect(model.formatedProfitOrLoss).toEqual(
      { price: 1800, str: '1,800', unit: null });
  });

  it("pairData", () => {
    expect(model.pairData).toEqual({
      labels: ["EURJPY", "USDJPY"],
      datasets: [{
        data: [6, 4],
        borderWidth: [0, 0],
        backgroundColor: [
          '#00BFA5', '#666699'
        ],
        hoverBackgroundColor: [
          '#4CD2C0', '#9494B7'
        ]
      }]
    });
  });

  it("sellOrBuyData", () => {
    expect(model.sellOrBuyData).toEqual({
      labels: ["買", "売"],
      datasets: [{
        data: [4, 6],
        borderWidth: [0, 0],
        backgroundColor: [
          '#FD8A6A', '#FFCC66'
        ],
        hoverBackgroundColor: [
          '#FEB49E', '#FFDB94'
        ]
      }]
    });
  });

  it("winsAndLossesData", () => {
    expect(model.winsAndLossesData).toEqual({
      labels: ["勝", "負", "引き分け"],
      datasets: [{
        data: [4, 4, 2],
        borderWidth: [0, 0, 0],
        backgroundColor: [
          "#F7464A", "#46BFBD", "#999"
        ],
        hoverBackgroundColor: [
          "#FF5A5E", "#5AD3D1", "#AAA"
        ]
      }]
    });
  });

  it("formatedProfitFactor", () => {
    expect(model.formatedProfitFactor).toEqual( "1.200" );
  });

  it("agentSummary", () => {
    expect(model.agentSummary.a1.formatedProfitOrLoss).toEqual(
      { price: 400, str: '400.0', unit: null } );
    expect(model.agentSummary.a2.formatedProfitOrLoss).toEqual(
      { price: 400, str: '400.0', unit: null } );
  });

  it("formatedWinPercentage", () => {
    expect(model.formatedWinPercentage).toEqual( "40.0%" );
    expect(model.agentSummary.a1.formatedWinPercentage).toEqual( "40.0%" );
    expect(model.agentSummary.a3.formatedWinPercentage).toEqual( "-%" );
  });

});
