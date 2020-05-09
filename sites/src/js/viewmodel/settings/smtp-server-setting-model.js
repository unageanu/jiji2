import Observable      from "../../utils/observable"
import Deferred        from "../../utils/deferred"
import Error           from "../../model/error"
import ErrorMessages   from "../../errorhandling/error-messages"
import Validators      from "../../utils/validation/validators"
import ValidationUtils from "../utils/validation-utils"
import DateFormatter   from "../utils/date-formatter"

export default class SMTPServerSettingModel extends Observable {

  constructor(smtpServerSettingService, timeSource) {
    super();
    this.smtpServerSettingService  = smtpServerSettingService;
    this.timeSource = timeSource;
    this.error = null;
    this.hostError = null;
    this.portError = null;
    this.userNameError = null;
    this.passwordError = null;
    this.message = null;
    this.testMailMessage = null;
  }

  initialize() {
    this.error = null;
    this.hostError = null;
    this.portError = null;
    this.userNameError = null;
    this.passwordError = null;
    this.message = null;
    this.testMailMessage = null;
    this.enablePostmark = true;
    this.setting = {};
    this.isSaving = false;
    const d = Deferred.when([
      this.smtpServerSettingService.getStatus(),
      this.smtpServerSettingService.getSMTPServerSetting()
    ]);
    d.then((result) => {
      this.enablePostmark = result[0].enablePostmark;
      this.setting        = result[1];
    }, (error) => {
      this.enablePostmark = false;
      error.preventDefault = true;
    });
    return d;
  }

  composeTestMail(setting, formatMessage) {
    this.error = null;
    this.message = null;
    this.testMailMessage = null;
    if (!this.validate(setting, formatMessage)) return;
    this.isSaving = true;
    this.smtpServerSettingService.composeTestMail(setting).then(
      (result) => {
        this.testMailMessage =
        formatMessage({id:'validation.messages.sentTestMail'}) + " ("
            + DateFormatter.format(this.timeSource.now) + ")";
        this.isSaving = false;
      }, (error) => {
        this.isSaving = false;
        this.error = formatMessage({id:'validation.messages.failedToSentMail'});
        error.preventDefault = true;
      });
  }

  save(setting, formatMessage) {
    this.error = null;
    this.message = null;
    this.testMailMessage = null;
    if (!this.validate(setting, formatMessage)) return Deferred.errorOf(null);
    this.isSaving = true;
    return this.smtpServerSettingService.setSMTPServerSetting(setting).then(
      (result) => {
        this.isSaving = false
        this.setting = setting;
        this.message = formatMessage({id:'validation.messages.finishToChangeSetting'}) + " ("
          + DateFormatter.format(this.timeSource.now) + ")";
      },
      (error) => {
        this.isSaving = false
        this.error = ErrorMessages.getMessageFor(formatMessage, error);
        error.preventDefault = true;
        throw error;
      });
  }

  validate(setting, formatMessage) {
    return Validators.all(
      this.validateHost(setting.smtpHost, formatMessage),
      this.validatePort(setting.smtpPort, formatMessage),
      this.validateUserName(setting.userName, formatMessage),
      this.validatePassword(setting.password, formatMessage)
    );
  }
  validateHost(host, formatMessage) {
    return ValidationUtils.validate(Validators.smtpServer.host, host,
        {field: formatMessage({id:'validation.fields.smtpServer'})}, (error) => this.hostError = error, formatMessage );
  }
  validatePort(port, formatMessage) {
    return ValidationUtils.validate(Validators.smtpServer.port, port,
        {field: formatMessage({id:'validation.fields.smtpPort'})}, (error) => this.portError = error, formatMessage );
  }
  validateUserName(userName, formatMessage) {
    return ValidationUtils.validate(Validators.smtpServer.userName, userName,
        {field: formatMessage({id:'validation.fields.userName'})}, (error) => this.userNameError = error, formatMessage );
  }
  validatePassword(password, formatMessage) {
    return ValidationUtils.validate(Validators.smtpServer.password, password,
        {field: formatMessage({id:'validation.fields.password'})}, (error) => this.passwordError = error, formatMessage );
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
  get testMailMessage() {
    return this.getProperty("testMailMessage");
  }
  set testMailMessage(testMailMessage) {
    this.setProperty("testMailMessage", testMailMessage);
  }
  get isSaving() {
    return this.getProperty("isSaving");
  }
  set isSaving(isSaving) {
    this.setProperty("isSaving", isSaving);
  }
}
