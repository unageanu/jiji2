import TableModel          from "../widgets/table-model"
import Deferred            from "../../utils/deferred"
import PageSelectorBuilder from "./page-selector-builder"

class Loader {
  constructor(logService, backtestId="rmt") {
    this.logService = logService;
    this.backtestId = backtestId;
  }
  load(offset, pageSize, sortOrder) {
    return this.logService.get(offset, this.backtestId);
  }
  count() {
    const d = new Deferred();
    this.logService.count(this.backtestId).then(
      (result) => d.resolve(result) );
    return d;
  }
}

export default class LogViewerModel extends TableModel {

  constructor(logService) {
    super({}, 1);
    this.logService = logService;
    this.pageSelectors = [];
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

  updateState() {
    super.updateState();
    this.updatePageSelectors();
  }
  updatePageSelectors() {
    this.pageSelectors =
        new PageSelectorBuilder(this.totalCount, this.offset, this).build();
  }

  set pageSelectors(pageSelectors) {
    this.setProperty("pageSelectors", pageSelectors);
  }
  get pageSelectors() {
    return this.getProperty("pageSelectors");
  }
}
