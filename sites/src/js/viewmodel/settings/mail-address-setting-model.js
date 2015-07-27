import Observable      from "../../utils/observable"
import Deferred        from "../../utils/deferred"
import Error           from "../../model/error"
import ErrorMessages   from "../../errorhandling/error-messages"
import Validators      from "../../utils/validation/validators"

export default class MailAddressSettingModel extends Observable {

  constructor(userSettingService, smtpServerSettingService) {
    super();
    this.userSettingService = userSettingService;
    this.smtpServerSettingService  = smtpServerSettingService;
    this.error = null;
    this.message = null;
  }

  initialize() {
    this.error = null;
    this.message = null;
    this.mailAddress = null;
    const d = this.userSettingService.getMailAddress();
    d.done((result) => {
      this.mailAddress = result.mailAddress;
    });
    return d;
  }

  composeTestMail(mailAddress) {
    return this.smtpServerSettingService.composeTestMail({
      mailAddress: mailAddress
    });
  }

  save(mailAddress) {
    this.message = null;
    if (!this.validate(mailAddress)) return;
    this.userSettingService.setMailAddress(mailAddress).then(
        (result) => {
          this.mailAddress = mailAddress;
          this.message = "メールアドレスを変更しました";
        },
        (error) => {
          this.error = ErrorMessages.getMessageFor(error);
          error.preventDefault = true;
        });
  }

  validate(mailAddress) {
    this.error = null;
    try {
      Validators.mailAddress.validate(mailAddress);
      return true;
    } catch (error) {
      this.error = ErrorMessages.getMessageFor(error, {field: "メールアドレス"});
      return false;
    }
  }

  get mailAddress() {
    return this.getProperty("mailAddress");
  }
  set mailAddress(mailAddress) {
    this.setProperty("mailAddress", mailAddress);
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
