import ContainerJS         from "container-js"
import AbstractPageModel   from "./abstract-page-model"
import Deferred            from "../../utils/deferred"

export default class NewBacktestPageModel extends AbstractPageModel {

  constructor() {
    super();
    this.backtestBuilder = ContainerJS.Inject;
  }

  postCreate() {}

  initialize() {
    return this.backtestBuilder.initialize([]).then((results) => {
      this.isLoading = false;
    });
  }
}
