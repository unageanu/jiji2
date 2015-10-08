import PriceUtils        from "../utils/price-utils"
import React             from "react"

export default [
  {
    id:"profitOrLoss",
    name:"損益",
    key:"formatedProfitOrLoss",
    sort: "profit_or_loss",
    formatter(value, item) {
      const className = PriceUtils.resolvePriceClass(item.profitOrLoss);
      const profitOrLoss =
        (item.profitOrLoss > 0 ? "+" : "") + item.formatedProfitOrLoss;
      return <span className={className}>{profitOrLoss}</span>;
    }
  }, {
    id:"status",
    name:"状態",
    key:"formatedStatus",
    sort: "status",
    formatter(value, item) {
      if (item.status == "live" ) {
         return <span className="live">{item.formatedStatus}</span>;
      } else {
        return item.formatedStatus;
      }
    }
  },{
    id:"pairName",
    name:"通貨ペア",
    key:"pairName",
    sort: "pair_name"
  }, {
    id:"sellOrBuy",
    name:"売/買",
    key:"formatedSellOrBuy",
    sort: "sell_or_buy"
  }, {
    id:"units",
    name:"数量",
    key:"formatedUnits",
    sort: "units"
  }, {
    id:"entryPrice",
    name:"購入価格",
    key:"formatedEntryPrice",
    sort: "entry_price"
  }, {
    id:"exitPrice",
    name:"決済価格",
    key:"formatedExitPrice",
    sort: "exit_price"
  }, {
    id:"enteredAt",
    name:"購入日時",
    key:"formatedEnteredAt",
    sort: "entered_at",
    formatter(value, item) {
      return value || "-";
    }
  }, {
    id:"exitedAt",
    name:"決済日時",
    key:"formatedExitedAt",
    sort: "exited_at",
    formatter(value, item) {
      return value || "-";
    }
  }, {
    id:"agentName",
    name:"エージェント",
    key:"agentName",
    sort: "agent_name"
  }
];
