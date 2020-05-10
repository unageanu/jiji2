import PriceUtils           from "../utils/price-utils"
import React                from "react"
import { FormattedMessage } from 'react-intl';

export default [
  {
    id:"profitOrLoss",
    name:"accounts.PerformancePanel.profitOrLoss",
    key:"formattedProfitOrLoss",
    sort: "profit_or_loss",
    formatter(value, item) {
      const className = PriceUtils.resolvePriceClass(item.profitOrLoss);
      const profitOrLoss =
        (item.profitOrLoss > 0 ? "+" : "") + item.formattedProfitOrLoss;
      return <span className={className}>{profitOrLoss}</span>;
    }
  }, {
    id:"status",
    name:"positions.PositionDetailsView.status",
    key:"formattedStatus",
    sort: "status",
    formatter(value, item) {
      if (item.status == "live" ) {
         return <span className="live"><FormattedMessage id={item.formattedStatus} /></span>;
      } else {
        return <FormattedMessage id={item.formattedStatus} />;
      }
    }
  },{
    id:"pairName",
    name:"positions.PositionDetailsView.pair",
    key:"pairName",
    sort: "pair_name"
  }, {
    id:"sellOrBuy",
    name:"tradingSummary.TradingSummaryView.sellOrBuy",
    key:"formattedSellOrBuy",
    sort: "sell_or_buy",
    formatter(value, item) {
      return <FormattedMessage id={value} />;
    }
  }, {
    id:"units",
    name:"positions.PositionDetailsView.volume",
    key:"formattedUnits",
    sort: "units"
  }, {
    id:"entryPrice",
    name:"positions.PositionDetailsView.price",
    key:"formattedEntryPrice",
    sort: "entry_price"
  }, {
    id:"exitPrice",
    name:"positions.PositionDetailsView.closePrice",
    key:"formattedExitPrice",
    sort: "exit_price"
  }, {
    id:"enteredAt",
    name:"positions.PositionDetailsView.enteredAt",
    key:"formattedEnteredAt",
    sort: "entered_at",
    formatter(value, item) {
      return value || "-";
    }
  }, {
    id:"exitedAt",
    name:"positions.PositionDetailsView.exitedAt",
    key:"formattedExitedAt",
    sort: "exited_at",
    formatter(value, item) {
      return value || "-";
    }
  }, {
    id:"agentName",
    name:"positions.PositionDetailsView.agent",
    key:"agentName",
    sort: "agent_name"
  }
];
