import ContainerJS         from "container-js"
import AbstractPageModel   from "./abstract-page-model"
import Deferred            from "../../utils/deferred"

export default class LoginPageModel extends AbstractPageModel {

  constructor() {
    super();
    this.authenticator = ContainerJS.Inject;
  }

  postCreate() {}

  login(password) {
    this.error = "";
    const d = this.authenticator.login( password );
    d.fail((error) => this.error = "パスワードが一致しません。" );
    return d;
  }

  get error() {
    return this.getProperty("error");
  }
  set error(error) {
    this.setProperty("error", error);
  }

}
