import Observable      from "../../utils/observable"
import Deferred        from "../../utils/deferred"
import Error           from "../../model/error"
import ErrorMessages   from "../../errorhandling/error-messages"
import Validators      from "../../utils/validation/validators"

export default class SMTPServerSettingModel extends Observable {

  constructor(smtpServerSettingService) {
    super();
    this.smtpServerSettingService  = smtpServerSettingService;
    this.error = null;
    this.hostError = null;
    this.portError = null;
    this.userNameError = null;
    this.passwordError = null;
    this.message = null;
  }

  initialize() {
    const d = Deferred.when([
      this.smtpServerSettingService.getStatus(),
      this.smtpServerSettingService.getSMTPServerSetting()
    ]);
    d.done((result) => {
      this.enablePostmark = result[0].enablePostmark;
      this.setting        = result[1];
    });
    return d;
  }

  composeTestMail(setting) {
    this.error = null;
    this.message = null;
    if (!this.validate(setting)) return;
    this.smtpServerSettingService.composeTestMail(setting).then(
      (result) => this.message = "登録されているメールアドレスにテストメールを送信しました。ご確認ください",
      (error) => {
        this.error = "メールの送信でエラーが発生しました。接続先SMTPサーバーの設定を確認してください";
        error.preventDefault = true;
      });
  }

  save(setting) {
    this.error = null;
    this.message = null;
    if (!this.validate(setting)) return;
    this.smtpServerSettingService.setSMTPServerSetting(setting).then(
      (result) => {
        this.setting = setting;
        this.message = "設定を変更しました";
      },
      (error) => {
        this.error = ErrorMessages.getMessageFor(error);
        error.preventDefault = true;
      });
  }

  validate(setting) {
    return Validators.all(
      this.validateHost(setting.smtpHost),
      this.validatePort(setting.smtpPort),
      this.validateUserName(setting.userName),
      this.validatePassword(setting.password)
    );
  }
  validateHost(host) {
    this.hostError = null;
    try {
      Validators.smtpServer.host.validate(host);
      return true;
    } catch (error) {
      this.hostError = ErrorMessages.getMessageFor(error, {field: "SMTPサーバー"});
      return false;
    }
  }
  validatePort(port) {
    this.portError = null;
    try {
      Validators.smtpServer.port.validate(port);
      return true;
    } catch (error) {
      this.portError = ErrorMessages.getMessageFor(error, {field: "SMTPポート"});
      return false;
    }
  }
  validateUserName(userName) {
    this.userNameError = null;
    try {
      Validators.smtpServer.userName.validate(userName);
      return true;
    } catch (error) {
      this.userNameError = ErrorMessages.getMessageFor(error, {field: "ユーザー名"});
      return false;
    }
  }
  validatePassword(password) {
    this.passwordError = null;
    try {
      Validators.smtpServer.password.validate(password);
      return true;
    } catch (error) {
      this.passwordError = ErrorMessages.getMessageFor(error, {field: "パスワード"});
      return false;
    }
  }

  get enablePostmark() {
    return this.getProperty("enablePostmark");
  }
  set enablePostmark(enablePostmark) {
    this.setProperty("enablePostmark", enablePostmark);
  }
  get setting() {
    return this.getProperty("setting");
  }
  set setting(setting) {
    this.setProperty("setting", setting);
  }

  get error() {
    return this.getProperty("error");
  }
  set error(error) {
    this.setProperty("error", error);
  }
  get hostError() {
    return this.getProperty("hostError");
  }
  set hostError(error) {
    this.setProperty("hostError", error);
  }
  get portError() {
    return this.getProperty("portError");
  }
  set portError(error) {
    this.setProperty("portError", error);
  }
  get userNameError() {
    return this.getProperty("userNameError");
  }
  set userNameError(error) {
    this.setProperty("userNameError", error);
  }
  get passwordError() {
    return this.getProperty("passwordError");
  }
  set passwordError(error) {
    this.setProperty("passwordError", error);
  }

  get message() {
    return this.getProperty("message");
  }
  set message(message) {
    this.setProperty("message", message);
  }
}
