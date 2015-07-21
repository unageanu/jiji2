import TableModel    from "../widgets/table-model"
import Deferred      from "../../utils/deferred"

class Loader {
  constructor(logService, backtestId="rmt") {
    this.logService = logService;
    this.backtestId = backtestId;
  }
  load(offset, pageSize, sortOrder) {
    return this.logService.get(offset, sortOrder.direction, this.backtestId);
  }
  count() {
    const d = new Deferred();
    this.logService.count(this.backtestId).then(
      (result) => d.resolve(result.count) );
    return d;
  }
}

class PageSelectorBuilder {

  constructor(totalCount, offset, model) {
    this.totalCount = totalCount;
    this.offset = offset;
    this.model = model;
    this.selectors = [];
  }

  build() {
    this.addLatestSelector();
    if (this.offset + 2 < this.totalCount -1 ) this.addSeparator();
    this.addCenterSelectors();
    if (this.offset -2 > 0 ) this.addSeparator();
    this.addOldestselector();
    return this.selectors;
  }
  addSeparator() {
    this.selectors.push( this.createSelectorSeparator() );
  }
  addLatestSelector() {
    if (this.totalCount > 1) {
      this.selectors.push( this.createSelector( this.totalCount -1 ) );
    }
  }
  addCenterSelectors() {
    [this.offset+1, this.offset, this.offset-1].forEach((page) => {
      if (page >= this.totalCount - 1 || page <= 0 ) return;
      this.selectors.push( this.createSelector( page ) );
    });
  }
  addOldestselector() {
    if (this.totalCount > 0) {
      this.selectors.push( this.createSelector( 0 ) );
    }
  }
  createSelector( page ) {
    return {
      label :  page,
      action: () => this.model.goTo(page),
      selected: page === this.offset
    };
  }
  createSelectorSeparator() {
    return { label: "..." };
  }
}

export default class LogViewerModel extends TableModel {

  constructor(logService) {
    super({direction: "asc"}, 1);
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
