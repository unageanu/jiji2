import Observable         from "../../utils/observable"

export default class TableModel extends Observable {

  constructor(loader, defaultSortOrder, pageSize=100) {
    super();
    this.pageSize  = pageSize;
    this.offset    = 0;
    this.loader    = loader;
    this.sortOrder = defaultSortOrder;

    this.items = [];
    this.hasNext = false;
    this.hasPrev = false;
  }

  load() {
    this.offset = 0;
    return this.loadItems();
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
      this.offset, this.pageSize, this.sortOrder ).then((result) => {
        this.totalCount = result.totalCount;
        this.items      = this.items.concat(result.items);
        this.updateState();
    });
  }

  loadItems() {
    this.items  = [];
    return this.loader.load(
      this.offset, this.pageSize, this.sortOrder ).then((result) => {
        this.totalCount = result.totalCount;
        this.items      = result.items;
        this.updateState();
    });
  }

  updateState() {
    this.hasNext = this.totalCount > this.offset+this.pageSize;
    this.hasPrev = this.offset > 0;
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
}
