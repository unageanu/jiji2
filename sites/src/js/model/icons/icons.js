import ContainerJS  from "container-js"
import Observable   from "../../utils/observable"

export default class Icons extends Observable {

  constructor() {
    super();
    this.iconService = ContainerJS.Inject;

    this.icons = null;
  }

  initialize() {
    if (!this.isInitialied()) {
      this.initializedDeferred = this.reload();
    }
    return this.initializedDeferred;
  }

  isInitialied() {
    if (!this.initializedDeferred) return false;
    if (this.initializedDeferred.rejected()) return false;
    return true;
  }

  reload() {
    return this.iconService.fetch().then((icons) => {
      this.icons = icons;
      return icons;
    });
  }

  add(file) {
    const d = this.iconService.post(file);
    d.then((icon) => {
      this.reload();
      return icon;
    });
    return d;
  }

  set icons( icons ) {
    this.setProperty("icons", icons);
  }
  get icons( ) {
    return this.getProperty("icons");
  }

}
