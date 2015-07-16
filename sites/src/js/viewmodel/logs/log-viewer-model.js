import TableModel    from "../widgets/table-model"
import Deferred      from "../../utils/deferred"

class Loader {
  constructor(logService, backtestId="rmt") {
    this.logService = logService;
    this.backtestId = backtestId;
  }
  load(offset, pageSize, sortOrder) {
    return this.logService.get(offset, sortOrder.direction);
  }
  count() {
    const d = new Deferred();
    this.logService.count(this.backtestId).then(
      (result) => d.resolve(result.count) );
    return d;
  }
}

export default class LogViewerModel extends TableModel {

  constructor(logService) {
    super({direction: "asc"}, 1);
    this.logService = logService;
  }

  initialize(backtestId="rmt") {
    super.initialize(new Loader(this.logService, backtestId));
  }

  getDefaultOffset() {
    return this.totalCount -1;
  }

  convertItems(log) {
    return [log];
  }
}
