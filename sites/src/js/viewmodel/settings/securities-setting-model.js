import Observable      from "../../utils/observable"
import Deferred        from "../../utils/deferred"
import Error           from "../../model/error"
import ErrorMessages   from "../../errorhandling/error-messages"
import StringFormatter from "../utils/string-formatter"
import DateFormatter   from "../utils/date-formatter"

export default class SecuritiesSettingModel extends Observable {

  constructor(securitiesSettingService, timeSource) {
    super();
    this.securitiesSettingService = securitiesSettingService;
    this.timeSource = timeSource;
    this.setProperty("availableSecurities", []);
    this.error = null;
    this.message = null;
  }

  initialize() {
    this.setProperty("availableSecurities", []);
    this.error = null;
    this.message = null;
    this.isSaving = false
    this.activeSecuritiesId = null;
    const d = new Deferred();
    this.securitiesSettingService.getAvailableSecurities().done((securities) => {
      this.setProperty("availableSecurities",
        this.convertAvailableSecurities(securities));
      this.securitiesSettingService.getActiveSecuritiesId().then(
        (result) => {
          this.activeSecuritiesId  = result.securitiesId || securities[0].id;
          d.resolve();
        }, (error)  => {
          error.preventDefault = true;
          this.activeSecuritiesId  = securities[0].id;
          d.resolve();
        }
      );
    });
    return d;
  }

  save(configurations, formatMessage) {
    this.error = null;
    this.message = null;
    this.isSaving = true;
    return this.securitiesSettingService.setActiveSecurities(
      this.activeSecuritiesId, configurations).then(
      (result) => {
        this.isSaving = false;
        this.message = formatMessage({id:'viewmodel.SecuritiesSettingModel.finishToChangeSetting'}) + " ("
          + DateFormatter.format(this.timeSource.now) + ")";
      },
      (error)  => {
        this.isSaving = false;
        this.handleError(error, formatMessage);
        throw error;
      });
  }

  handleError(error, formatMessage) {
    if (error.code === Error.Code.INVALID_VALUE ) {
      this.error = formatMessage({id:'viewmodel.SecuritiesSettingModel.failedToChangeSetting'});
    } else {
      this.error = ErrorMessages.getMessageFor(formatMessage, error);
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
  get isSaving() {
    return this.getProperty("isSaving");
  }
  set isSaving(isSaving) {
    this.setProperty("isSaving", isSaving);
  }
}
