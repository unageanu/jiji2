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
    this.error = null;
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
    const d = this.initialSettingService.isInitialized();
    d.done((result) => {
      this.setProperty("isInitialized", result.initialized);
      if (!this.isInitialized) this.setProperty("phase", "welcome");
    });
    return d;
  }

  changePhaseToSetMailAddressAndPassword() {
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

  startSetting() {
    this.changePhaseToSetMailAddressAndPassword();
  }

  setMailAddressAndPassword( mailAddress, password1, password2 ) {
    if (!this.validateMailAddressAndPassword( mailAddress,
      password1, password2)) {
        return;
    }
    this.initialSettingService.initialize(mailAddress, password1).then(
      (result) => {
        this.setProperty("isInitialized", true);
        this.sessionManager.setToken(result.token);
        this.changePhaseToSetSecurities();
      }, (error)  => {
        this.error = ErrorMessages.getMessageFor(error);
        error.preventDefault = true;
      });
  }
  setSecurities( configurations ) {
    this.securitiesSetting.save(configurations).done(
      () => this.changePhaseToSetSMTPServerIfRequired());
  }
  setSMTPServerSetting( settings ) {
    this.smtpServerSetting.save(settings).done(
      () => this.setProperty("phase", "finished"));
  }

  exit() {
    this.setProperty("phase", "none");
    this.eventQueue.push({ type: "routing", route: "/" });
  }

  validateMailAddressAndPassword( mailAddress, password1, password2 ) {
    return Validators.all(
      this.mailAddressSetting.validate(mailAddress),
      this.passwordSetting.validate(password1, password2, "パスワード")
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
}
