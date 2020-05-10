import Observable      from "../../utils/observable"
import Deferred        from "../../utils/deferred"
import Error           from "../../model/error"
import ErrorMessages   from "../../errorhandling/error-messages"
import Validators      from "../../utils/validation/validators"
import ValidationUtils from "../utils/validation-utils"
import DateFormatter   from "../utils/date-formatter"

export default class PasswordSettingModel extends Observable {

  constructor(userSettingService, timeSource) {
    super();
    this.userSettingService = userSettingService;
    this.timeSource = timeSource;
    this.error = null;
    this.message = null;
    this.isSaving = false;
  }

  initialize() {
    this.error = null;
    this.message = null;
  }

  save(newPassword, newPassword2, oldPassword, formatMessage) {
    this.message = null;
    if (!this.validate(newPassword, newPassword2, formatMessage({id: 'validation.fields.password'}), formatMessage)) return;
    this.isSaving = true;
    this.userSettingService.setPassword(oldPassword, newPassword).then(
        (result) => {
          this.isSaving = false;
          this.message = formatMessage({id:'validation.messages.finishToChangePassword'}) + " ("
            + DateFormatter.format(this.timeSource.now) + ")";
        }, (error)  => {
          this.isSaving = false;
          this.handleError(error, formatMessage)
        });
  }

  handleError(error, formatMessage) {
    if (error.code === Error.Code.UNAUTHORIZED) {
      this.error = formatMessage({id:'validation.messages.mismatchCurrentPassword'});
    } else {
      this.error = ErrorMessages.getMessageFor(formatMessage, error);
    }
    error.preventDefault = true;
  }

  validate(newPassword, newPassword2, field, formatMessage) {
    this.error = null;
    if (newPassword !== newPassword2) {
      this.error = field+ formatMessage({id:'validation.messages.mismatch'});
      return false;
    }
    return ValidationUtils.validate(Validators.password, newPassword,
      {field: field}, (error) => this.error = error, formatMessage );
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
