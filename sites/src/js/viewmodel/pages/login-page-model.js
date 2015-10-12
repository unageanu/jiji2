import ContainerJS         from "container-js"
import AbstractPageModel   from "./abstract-page-model"
import Deferred            from "../../utils/deferred"
import Validators          from "../../utils/validation/validators"
import ValidationUtils     from "../utils/validation-utils"
import Error               from "../../model/error"

export default class LoginPageModel extends AbstractPageModel {

  constructor() {
    super();
    this.authenticator = ContainerJS.Inject;
    this.xhrManager    = ContainerJS.Inject;
    this.eventQueue    = ContainerJS.Inject;

    this.error = null;
    this.authenticating = false;
  }

  postCreate() {}

  login(password) {
    if (!this.validate(password)) return Deferred.errorOf({});

    this.error = null;
    this.authenticating = true;
    return this.authenticator.login( password ).then((result) => {
      this.xhrManager.restart();
      this.authenticating = false;
      this.eventQueue.push({ type: "routing", route: "/" });
      return result;
    }, (error)  => {
      if (error.code == Error.Code.UNAUTHORIZED) {
        this.error = "パスワードが一致していません";
        error.preventDefault = true;
      }
      this.authenticating = false;
      throw error;
    });
  }

  validate(password) {
    return ValidationUtils.validate(Validators.loginPassword, password,
      {field: "パスワード"}, (error) => this.error = error );
  }


  get error() {
    return this.getProperty("error");
  }
  set error(error) {
    this.setProperty("error", error);
  }

  get authenticating() {
    return this.getProperty("authenticating");
  }
  set authenticating(authenticating) {
    this.setProperty("authenticating", authenticating);
  }
}
