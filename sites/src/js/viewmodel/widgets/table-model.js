import Observable         from "../../utils/observable"
import Deferred           from "../../utils/deferred"

export default class TableModel extends Observable {

  constructor(defaultSortOrder, pageSize=100) {
    super();
    this.pageSize  = pageSize;
    this.defaultSortOrder = defaultSortOrder;
  }

  initialize(loader) {
    this.offset          = 0;
    this.loader          = loader;
    this.sortOrder       = this.defaultSortOrder;
    this.filterCondition = null;

    this.items = null;
    this.hasNext = false;
    this.hasPrev = false;
  }

  load() {
    const d = new Deferred ();
    this.loader.count(this.filterCondition).then((count)=>{
      this.totalCount = count.count;
      this.processCount(count);
      this.offset = this.getDefaultOffset();
      if (this.totalCount > 0) {
        this.loadItems().then(
          (r) => d.resolve(this.items), (e) => d.reject(e) );
      } else {
        this.items = [];
        this.updateState();
        d.resolve(this.items)
      }
    }, (e) => d.reject(e));
    return d;
  }

  goTo(offset) {
    if (offset > this.totalCount - this.pageSize) {
      offset = this.totalCount - this.pageSize;
    }
    if (offset < 0) {
      offset = 0;
    }
    this.offset = offset;
    this.loadItems();
  }

  next() {
    if (!this.hasNext) return null;
    this.offset += this.pageSize;
    return this.loadItems();
  }

  prev() {
    if (!this.hasPrev) return null;
    this.offset -= this.pageSize;
    if (this.offset < 0) this.offset = 0;
    return this.loadItems();
  }

  filter(condition) {
    this.filterCondition = condition;
    this.offset = this.getDefaultOffset();
    return this.load();
  }

  sortBy(sortOrder) {
    this.sortOrder = sortOrder;
    this.offset = this.getDefaultOffset();
    return this.loadItems();
  }

  fillNext() {
    if (!this.hasNext) return null;
    this.offset += this.pageSize;
    return this.loader.load(this.offset, this.pageSize,
      this.sortOrder, this.filterCondition ).then((items) => {
        this.items      = this.items.concat(
          this.convertItems(items));
        this.updateState();
    });
  }

  loadItems() {
    this.items  = null;
    this.loading = true;
    return this.loader.load( this.offset, this.pageSize,
      this.sortOrder, this.filterCondition ).then((items) => {
        this.loading = false;
        this.items   = this.convertItems(items);
        this.updateState();
    }, (error) => this.loading = false );
  }

  updateState() {
    this.hasNext = this.totalCount > this.offset + this.pageSize;
    this.hasPrev = this.offset > 0;
  }


  getDefaultOffset() {
    return 0;
  }

  convertItems(items) {
    return items;
  }

  processCount(count) {}

  set hasNext(hasNext) {
    this.setProperty("hasNext", hasNext);
  }
  get hasNext() {
    return this.getProperty("hasNext");
  }

  set hasPrev(hasPrev) {
    this.setProperty("hasPrev", hasPrev);
  }
  get hasPrev() {
    return this.getProperty("hasPrev");
  }

  set items(items) {
    this.setProperty("items", items);
  }
  get items() {
    return this.getProperty("items");
  }

  set sortOrder(sortOrder) {
    this.setProperty("sortOrder", sortOrder);
  }
  get sortOrder() {
    return this.getProperty("sortOrder");
  }
  set filterCondition(filterCondition) {
    this.setProperty("filterCondition", filterCondition);
  }
  get filterCondition() {
    return this.getProperty("filterCondition");
  }
  set loading(loading) {
    this.setProperty("loading", loading);
  }
  get loading() {
    return this.getProperty("loading");
  }

  set totalCount(totalCount) {
    this.setProperty("totalCount", totalCount);
  }
  get totalCount() {
    return this.getProperty("totalCount");
  }
}
