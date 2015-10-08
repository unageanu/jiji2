import NumberFormatter   from "../utils/number-formatter"
import DateFormatter     from "../utils/date-formatter"
import Deferred          from "../../utils/deferred"
import Observable        from "../../utils/observable"

export default class SelectionModel extends Observable {

  constructor( ) {
    super();
    this.selectedId = null;
    this.selected   = null;
  }

  attach(tableModel) {
    this.tableModel = tableModel;
    this.tableModel.addObserver("beforeLoadItems", () => {
      this.selected = null;
      this.selectedId = null;
    });
  }

  convertItem(item) {
    return item;
  }

  findFromItems(id) {
    if (!this.tableModel || !this.tableModel.items) return false;
    return this.selected = this.tableModel.items.find((n) => n.id == id);
  }
  loadItem(id) {}

  set selectedId( id ) {
    this.setProperty("selectedId", id);
    if (id == null) return;
    this.findFromItems(id) || this.loadItem(id);
  }
  get selectedId( ) {
    return this.getProperty("selectedId");
  }

  set selected( selected ) {
    this.setProperty("selected", selected);
  }
  get selected( ) {
    return this.getProperty("selected");
  }
}
