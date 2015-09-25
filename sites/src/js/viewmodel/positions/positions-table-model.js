import TableModel      from "../widgets/table-model"
import Deferred        from "../../utils/deferred"
import PositionModel   from "./position-model"

class Loader {
  constructor( positionService, backtestId="rmt", status=null ) {
    this.backtestId = backtestId;
    this.status     = status;
    this.positionService = positionService;
  }
  load( offset, limit, sortOrder) {
    return this.positionService.fetch(
      offset, limit, sortOrder, this.backtestId, this.status);
  }
  count() {
    const d = new Deferred();
    this.positionService.count(this.backtestId, this.status).then(
      (result) => d.resolve(result) );
    return d;
  }
}

export default class PositionsTableModel extends TableModel {
  constructor( pageSize, defaultSortOrder,
    positionService, urlResolver ) {
    super( defaultSortOrder, pageSize );
    this.defaultSortOrder = defaultSortOrder;
    this.positionService = positionService;
    this.urlResolver = urlResolver;
  }

  initialize(backtestId="rmt", status=null) {
    super.initialize(new Loader(this.positionService, backtestId, status));
  }

  loadItems() {
    this.fire("beforeLoadItems");
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

  set notExited(notExited) {
    this.setProperty("notExited", notExited);
  }
  get notExited() {
    return this.getProperty("notExited");
  }
}
