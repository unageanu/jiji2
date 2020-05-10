import Observable      from "../../utils/observable"
import Deferred        from "../../utils/deferred"
import Error           from "../../model/error"
import ErrorMessages   from "../../errorhandling/error-messages"
import Validators      from "../../utils/validation/validators"
import ValidationUtils from "../utils/validation-utils"
import DateFormatter   from "../utils/date-formatter"

export default class MailAddressSettingModel extends Observable {

  constructor(userSettingService, smtpServerSettingService, timeSource) {
    super();
    this.userSettingService = userSettingService;
    this.smtpServerSettingService  = smtpServerSettingService;
    this.timeSource = timeSource;
    this.error = null;
    this.message = null;
  }

  initialize() {
    this.error = null;
    this.message = null;
    this.isSaving = false;
    this.mailAddress = null;
    const d = this.userSettingService.getMailAddress();
    d.then((result) => {
      this.mailAddress = result.mailAddress;
    }, (error) => {
      error.preventDefault = true;
    });
    return d;
  }

  composeTestMail(mailAddress) {
    return this.smtpServerSettingService.composeTestMail({
      mailAddress: mailAddress
    });
  }

  save(mailAddress, formatMessage) {
    this.message = null;
    if (!this.validate(mailAddress, formatMessage)) return;
    this.isSaving = true;
    this.userSettingService.setMailAddress(mailAddress).then(
        (result) => {
          this.isSaving = false;
          this.mailAddress = mailAddress;
          this.message = formatMessage({id:'validation.messages.finishToChangeMailAddress'}) + " ("
            + DateFormatter.format(this.timeSource.now) + ")" ;
        },
        (error) => {
          this.isSaving = false;
          this.error = ErrorMessages.getMessageFor(formatMessage, error);
          error.preventDefault = true;
        });
  }

  validate(mailAddress, formatMessage) {
    return ValidationUtils.validate(Validators.mailAddress, mailAddress,
      {field: formatMessage({id:'validation.fields.mailAddress'})}, (error) => this.error = error, formatMessage );
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
  get isSaving() {
    return this.getProperty("isSaving");
  }
  set isSaving(isSaving) {
    this.setProperty("isSaving", isSaving);
  }
}
