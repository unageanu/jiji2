import ContainerJS         from "container-js"
import Observable          from "../../utils/observable"

export default class IconSelectorModel extends Observable {

  constructor(icons) {
    super();
    this.icons = icons;
    this.selectedId = null;
  }

  initialize(selectdIconId) {
    this.icons.initialize().then(() => {
      this.selectdId = selectdIconId;
    });
  }

  get selectedId() {
    return this.getProperty("selectedId");
  }
  set selectedId(id) {
    this.setProperty("selectedId", id);
  }
}
