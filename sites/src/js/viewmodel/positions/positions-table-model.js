import TableModel      from "../widgets/table-model"
import NumberFormatter from "../utils/number-formatter"
import DateFormatter   from "../utils/date-formatter"
import Deferred        from "../../utils/deferred"

class Loader {
  constructor( positionService, backtestId="rmt", status=null ) {
    this.backtestId = backtestId;
    this.status     = status;
    this.positionService = positionService;
  }
  load( offset, limit, sortOrder) {
    return this.positionService.fetchPositions(
      offset, limit, sortOrder, this.backtestId, this.status);
  }
  count() {
    const d = new Deferred();
    this.positionService.countPositions(this.backtestId, this.status).then(
      (result) => d.resolve(result) );
    return d;
  }
}

class PositionModel {

  constructor(position, urlResolver) {
    for (let i in position) {
      if (i === "closingPolicy") {
        this[i] = new ClosingPolicyModel(position[i]);
      } else {
        this[i] = position[i];
      }
    }
    this.urlResolver = urlResolver;
  }

  get formatedProfitOrLoss() {
    return NumberFormatter.insertThousandsSeparator(this.profitOrLoss);
  }
  get formatedSellOrBuy() {
    if (this.sellOrBuy === "sell") {
      return "売";
    } else {
      return "買";
    }
  }
  get formatedUnits() {
    return NumberFormatter.insertThousandsSeparator(this.units);
  }
  get formatedEntryPrice() {
    return NumberFormatter.insertThousandsSeparator(this.entryPrice);
  }
  get formatedExitPrice() {
    return this.exitPrice ?
      NumberFormatter.insertThousandsSeparator(this.exitPrice) : "-";
  }
  get formatedEnteredAt() {
    return DateFormatter.format(this.enteredAt);
  }
  get formatedExitedAt() {
    return this.exitedAt ? DateFormatter.format(this.exitedAt) : "";
  }
  get formatedExitedAtShort() {
    return this.exitedAt
      ? DateFormatter.format(this.exitedAt, "MM-dd hh:mm:ss") : "";
  }
  get agentIconUrl() {
    const iconId = this.agent ? this.agent.iconId : null;
    return this.urlResolver.resolveServiceUrl(
      "icon-images/" + (iconId || "default"));
  }
}

class ClosingPolicyModel {
  constructor(policy) {
    if (policy) for (let i in policy) {
      this[i] = policy[i];
    }
  }
  get formatedTakeProfit() {
    return this.takeProfit ?
      NumberFormatter.insertThousandsSeparator(this.takeProfit) : "-";
  }
  get formatedLossCut() {
    return this.lossCut ?
      NumberFormatter.insertThousandsSeparator(this.lossCut) : "-";
  }
}

export default class PositionsTableModel extends TableModel {
  constructor( pageSize, defaultSortOrder,
    positionService, urlResolver ) {
    super( defaultSortOrder, pageSize );
    this.defaultSortOrder = defaultSortOrder;
    this.positionService = positionService;
    this.selectedPosition = null;
    this.urlResolver = urlResolver;
  }

  initialize(backtestId="rmt", status=null) {
    super.initialize(new Loader(this.positionService, backtestId, status));
  }

  loadItems() {
    this.selectedPosition = null;
    super.loadItems();
  }

  convertItems(items) {
    return items.map((item) => this.convertItem(item));
  }

  convertItem(item) {
    return new PositionModel(item, this.urlResolver);
  }

  processCount(count) {
    this.notExited = count.notExited;
  }

  set selectedPosition( position ) {
    this.setProperty("selectedPosition", position);
  }
  get selectedPosition( ) {
    return this.getProperty("selectedPosition");
  }

  set notExited(notExited) {
    this.setProperty("notExited", notExited);
  }
  get notExited() {
    return this.getProperty("notExited");
  }
}
