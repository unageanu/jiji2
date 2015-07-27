import Observable      from "../../utils/observable"
import Deferred        from "../../utils/deferred"
import Error           from "../../model/error"
import ErrorMessages   from "../../errorhandling/error-messages"
import StringFormatter from "../utils/string-formatter"

export default class SecuritiesSettingModel extends Observable {

  constructor(securitiesSettingService) {
    super();
    this.securitiesSettingService = securitiesSettingService;
    this.setProperty("availableSecurities", []);
    this.error = null;
    this.message = null;
  }

  initialize() {
    this.setProperty("availableSecurities", []);
    this.error = null;
    this.message = null;
    this.activeSecuritiesId = null;
    const d = Deferred.when([
      this.securitiesSettingService.getAvailableSecurities(),
      this.securitiesSettingService.getActiveSecuritiesId()
    ]);
    d.done((results) => {
      this.setProperty("availableSecurities",
        this.convertAvailableSecurities(results[0]));
      this.activeSecuritiesId  = results[1].securitiesId || results[0][0].id;
    });
    return d;
  }

  save(configurations) {
    this.error = null;
    this.message = null;
    const d = this.securitiesSettingService.setActiveSecurities(
      this.activeSecuritiesId, configurations);
    d.then(
      (result) => this.message = "証券会社の設定を変更しました",
      (error)  => this.handleError(error));
    return d;
  }

  handleError(error) {
    if (error.code === Error.Code.INVALID_VALUE ) {
      this.error = "証券会社に接続できませんでした。<br/>アクセストークンを確認してください。";
    } else {
      this.error = ErrorMessages.getMessageFor(error);
    }
    error.preventDefault = true;
  }

  convertAvailableSecurities(securities) {
    securities.forEach((s) => {
      s.id   = s.securitiesId;
      s.text = s.name;
    });
    return securities;
  }

  updateConfiguration() {
    this.activeSecuritiesConfiguration = [];
    const id = this.activeSecuritiesId;
    if (id == null) return;
    Deferred.when([
      this.securitiesSettingService.getSecuritiesConfigurationDefinitions(id),
      this.securitiesSettingService.getSecuritiesConfiguration(id)
    ]).then((results)=> {
      this.activeSecuritiesConfiguration =
        this.buildconfigurations(results[0], results[1]);
    });
  }

  buildconfigurations( definitions, values ) {
    definitions.forEach((i) => {
      const key = StringFormatter.snakeCaseToCamelCase(i.id);
      i.value = values[key] || null;
    });
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
