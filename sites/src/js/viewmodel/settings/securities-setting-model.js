import Observable      from "../../utils/observable"
import Deferred        from "../../utils/deferred"
import Error           from "../../model/error"
import ErrorMessages   from "../../errorhandling/error-messages"

export default class SecuritiesSettingModel extends Observable {

  constructor(securitiesSettingService) {
    super();
    this.securitiesSettingService = securitiesSettingService;
    this.error = null;
    this.message = null;
  }

  initialize() {
    const d = Deferred.when([
      this.securitiesSettingService.getAvailableSecurities(),
      this.securitiesSettingService.getActiveSecuritiesId()
    ]);
    d.done((results) => {
      this.setProperty("availableSecurities", results[0]);
      this.activeSecuritiesId  = results[1].securitiesId || results[0][0].id;
    });
    return d;
  }

  save(configurations) {
    this.error = null;
    this.message = null;
    return this.securitiesSettingService.setActiveSecurities(
      this.activeSecuritiesId, configurations).then(
      (result) => this.message = "証券会社の設定を変更しました",
      (error)  => this.handleError(error));
  }

  handleError(error) {
    if (error.code === Error.Code.INVALID_VALUE ) {
      this.error = "証券会社に接続できませんでした。<br/>アクセストークンを確認してください。";
    } else {
      this.error = ErrorMessages.getMessageFor(error);
    }
    error.preventDefault = true;
  }

  updateConfiguration() {
    const id = this.activeSecuritiesId;
    this.activeSecuritiesConfiguration = null;
    Deferred.when([
      this.securitiesSettingService.getSecuritiesConfiguration(id),
      this.securitiesSettingService.getSecuritiesConfigurationDefinitions(id)
    ]).then((results)=> {
      this.activeSecuritiesConfiguration =
        this.buildconfigurations(results[0], results[1]);
    });
  }

  buildconfigurations( definitions, values ) {
    definitions.forEach((i) => i.value = values[i.id] || null );
    return definitions;
  }

  get availableSecurities() {
    return this.getProperty("availableSecurities");
  }

  get activeSecuritiesId() {
    return this.getProperty("activeSecuritiesId");
  }
  set activeSecuritiesId(activeSecuritiesId) {
    const oldSetting = this.activeSecuritiesId;
    this.setProperty("activeSecuritiesId", activeSecuritiesId);
    if (oldSetting !== activeSecuritiesId) this.updateConfiguration();
  }

  get activeSecuritiesConfiguration() {
    return this.getProperty("activeSecuritiesConfiguration");
  }
  set activeSecuritiesConfiguration(configuration) {
    this.setProperty("activeSecuritiesConfiguration", configuration);
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
