import ContainerJS         from "container-js"
import Observable          from "../../utils/observable"

export default class AbstractPageModel extends Observable {

  constructor() {
    super();
  }

  postCreate() {
    this.isLoading = true;
  }

  initialize() {
    this.isLoading = false;
  }

  set isLoading(isLoading) {
    this.setProperty("isLoading", isLoading);
  }
  get isLoading() {
    return this.getProperty("isLoading");
  }
}
