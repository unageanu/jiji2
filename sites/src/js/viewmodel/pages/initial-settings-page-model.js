import ContainerJS     from "container-js"
import Observable      from "../../utils/observable"
import Validators      from "../../utils/validation/validators"
import Error           from "../../model/error"
import ErrorMessages   from "../../errorhandling/error-messages"

export default class InitialSettingsPageModel extends Observable {

  constructor() {
    super();
    this.viewModelFactory      = ContainerJS.Inject;
    this.initialSettingService = ContainerJS.Inject;
    this.eventQueue            = ContainerJS.Inject;
    this.sessionManager        = ContainerJS.Inject;

    this.setProperty("isInitialized", false);
    this.setProperty("phase", "none");
    this.isSaving = false;
    this.error = null;
    this.acceptLicense = false;
    this.acceptionError = null;
  }

  postCreate() {
    this.mailAddressSetting =
      this.viewModelFactory.createMailAddressSettingModel();
    this.passwordSetting   =
      this.viewModelFactory.createPasswordSettingModel();
    this.securitiesSetting =
      this.viewModelFactory.createSecuritiesSettingModel();
    this.smtpServerSetting =
      this.viewModelFactory.createSMTPServerSettingModel();
  }

  initialize() {
    this.error = null;
    this.acceptLicense = false;
    this.acceptionError = null;
    this.isSaving = false;

    const d = this.initialSettingService.isInitialized();
    d.done((result) => {
      this.setProperty("isInitialized", result.initialized);
      if (!this.isInitialized) this.setProperty("phase", "welcome");
    });
    return d;
  }

  changePhaseToSetMailAddressAndPassword(formatMessage) {
    if ( !this.acceptLicense ) {
      this.acceptionError = formatMessage({id:'validation.messages.acceptLicense'});
      return;
    }
    this.acceptionError = null;
    this.setProperty("phase", "mailAddressAndPassword");
  }
  changePhaseToSetSecurities() {
    this.securitiesSetting.initialize().done(
      () => this.setProperty("phase", "securities"));
  }
  changePhaseToSetSMTPServerIfRequired() {
    this.smtpServerSetting.initialize().done(() => {
      if (!this.smtpServerSetting.enablePostmark) {
        this.setProperty("phase", "smtpServer");
      } else {
        this.setProperty("phase", "finished");
      }
    });
  }

  startSetting(formatMessage) {
    this.changePhaseToSetMailAddressAndPassword(formatMessage);
  }

  setMailAddressAndPassword( mailAddress, password1, password2, formatMessage ) {
    if (!this.validateMailAddressAndPassword( mailAddress,
      password1, password2, formatMessage)) {
        return;
    }
    this.isSaving = true;
    this.initialSettingService.initialize(mailAddress, password1).then(
      (result) => {
        this.isSaving = false;
        this.setProperty("isInitialized", true);
        this.sessionManager.setToken(result.token);
        this.changePhaseToSetSecurities();
      }, (error)  => {
        this.isSaving = false;
        this.error = ErrorMessages.getMessageFor(formatMessage, error);
        error.preventDefault = true;
        throw error;
      });
  }
  setSecurities( configurations, formatMessage ) {
    this.securitiesSetting.save(configurations, formatMessage).done(
      () => this.changePhaseToSetSMTPServerIfRequired());
  }
  setSMTPServerSetting( settings, formatMessage ) {
    this.smtpServerSetting.save(settings, formatMessage).done(
      () => this.setProperty("phase", "finished"));
  }
  skipSMTPServerSetting( ) {
    this.setProperty("phase", "finished");
  }

  exit() {
    this.setProperty("phase", "none");
    this.eventQueue.push({ type: "routing", route: "/" });
  }

  validateMailAddressAndPassword( mailAddress, password1, password2, formatMessage) {
    return Validators.all(
      this.mailAddressSetting.validate(mailAddress, formatMessage),
      this.passwordSetting.validate(password1, password2,
        formatMessage({id:'validation.fields.password'}), formatMessage)
    );
  }

  get isInitialized() {
    return this.getProperty("isInitialized");
  }

  get phase() {
    return this.getProperty("phase");
  }
  get error() {
    return this.getProperty("error");
  }
  set error(error) {
    this.setProperty("error", error);
  }

  get acceptLicense() {
    return this.getProperty("acceptLicense");
  }
  set acceptLicense(acceptLicense) {
    this.setProperty("acceptLicense", acceptLicense);
  }
  get acceptionError() {
    return this.getProperty("acceptionError");
  }
  set acceptionError(acceptionError) {
    this.setProperty("acceptionError", acceptionError);
  }
  get isSaving() {
    return this.getProperty("isSaving");
  }
  set isSaving(isSaving) {
    this.setProperty("isSaving", isSaving);
  }
}
