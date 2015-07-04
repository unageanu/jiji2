import TableModel      from "../widgets/table-model"
import NumberFormatter from "../utils/number-formatter"
import DateFormatter   from "../utils/date-formatter"
import Deferred        from "../../utils/deferred"

class Loader {
  constructor(  backtestId, positionsService ) {
    this.backtestId = backtestId;
    this.positionsService = positionsService;
  }
  load( offset, limit, sortOrder) {
    return this.positionsService.fetchPositions(
      offset, limit, sortOrder, this.backtestId );
  }
  count() {
    const d = new Deferred();
    this.positionsService.countPositions(this.backtestId ).then(
      (result) => d.resolve(result.count) );
    return d;
  }
}

export default class PositionsTableModel extends TableModel {
  constructor( backtestId, pageSize, defaultSortOrder, positionsService) {
    super( new Loader(backtestId, positionsService),
      defaultSortOrder, pageSize );
  }

  convertItems(items) {
    return items.map((item) => this.convertItem(item));
  }

  convertItem(item) {
    const converted = {};
    for (let i in item) {
      converted[i] = this.convertValue(i, item[i]);
    }
    return converted;
  }
  convertValue(key, value) {
    switch (key) {
      case "exitPrice"    :
      case "entryPrice"   :
        return { content: value ? NumberFormatter.formatPrice(value) : "-" };
      case "profitOrLoss" :
        return this.convertProfitOrLoss(value);
      case "sellOrBuy"    :
        return this.convertSellOrBuy(value);
      case "exitedAt"     :
      case "enteredAt"    :
        return { content: value ? DateFormatter.format(value) : "-" };
      default:
        return { content: value };
    }
  }
  convertProfitOrLoss(value) {
    return {
      content: NumberFormatter.formatPrice(value),
      style:   value > 0 ? {color: "#55D"} : {color: "#D55"}
    };
  }
  convertSellOrBuy(value) {
    if (value === "sell") {
      return {
        content: "売",
        style:   {color: "#5DD"}
      };
    } else {
      return {
        content: "買",
        style:   {color: "#DD5"}
      };
    }
  }
}
