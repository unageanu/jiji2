import Observable      from "../../utils/observable"
import Deferred        from "../../utils/deferred"
import Error           from "../../model/error"
import ErrorMessages   from "../../errorhandling/error-messages"
import Validators      from "../../utils/validation/validators"

export default class PasswordSettingModel extends Observable {

  constructor(userSettingService) {
    super();
    this.userSettingService = userSettingService;
    this.error = null;
    this.message = null;
  }

  save(newPassword, newPassword2, oldPassword) {
    this.message = null;
    if (!this.validate(newPassword, newPassword2)) return;
    this.userSettingService.setPassword(oldPassword, newPassword).then(
        (result) => this.message = "パスワードを変更しました",
        (error)  => this.handleError(error));
  }

  handleError(error) {
    if (error.code === Error.Code.UNAUTHORIZED) {
      this.error = "現在のパスワードが一致していません。入力した値をご確認ください";
    } else {
      this.error = ErrorMessages.getMessageFor(error);
    }
    error.preventDefault = true;
  }

  validate(newPassword, newPassword2, field="新しいパスワード") {
    this.error = null;
    if (newPassword !== newPassword2) {
      this.error = field+ "が一致していません";
      return false;
    }
    try {
      Validators.password.validate(newPassword);
      return true;
    } catch (error) {
      this.error = ErrorMessages.getMessageFor(error, {field:  field});
      return false;
    }
  }

  get error() {
    return this.getProperty("error");
  }
  set error(error) {
    this.setProperty("error", error);
  }
  get message() {
    return this.getProperty("message");
  }
  set message(message) {
    this.setProperty("message", message);
  }
}
