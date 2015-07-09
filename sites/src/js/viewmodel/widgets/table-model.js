import Observable         from "../../utils/observable"

export default class TableModel extends Observable {

  constructor(loader, defaultSortOrder, pageSize=100) {
    super();
    this.pageSize  = pageSize;
    this.defaultSortOrder = defaultSortOrder;

    this.initialize(loader);
  }

  initialize(loader) {
    this.offset    = 0;
    this.loader    = loader;
    this.sortOrder = this.defaultSortOrder;

    this.items = [];
    this.hasNext = false;
    this.hasPrev = false;
  }

  load() {
    this.offset = 0;
    this.loader.count().then((count)=>{
      this.totalCount = count;
      this.loadItems();
    });
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

  sortBy(sortOrder) {
    this.sortOrder = sortOrder;
    this.offset = 0;
    return this.loadItems();
  }

  fillNext() {
    if (!this.hasNext) return null;
    this.offset += this.pageSize;
    return this.loader.load(
      this.offset, this.pageSize, this.sortOrder ).then((items) => {
        this.items      = this.items.concat(
          this.convertItems(items));
        this.updateState();
    });
  }

  loadItems() {
    this.items  = [];
    return this.loader.load(
      this.offset, this.pageSize, this.sortOrder ).then((items) => {
        this.items      = this.convertItems(items);
        this.updateState();
    });
  }

  updateState() {
    this.hasNext = this.totalCount > this.offset+this.pageSize;
    this.hasPrev = this.offset > 0;
  }

  convertItems(items) {
    return items;
  }

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
}
