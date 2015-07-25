import Observable      from "../../utils/observable"
import Deferred        from "../../utils/deferred"

export default class SecuritiesSettingModel extends Observable {

  constructor(securitiesSettingService) {
    super();
    this.securitiesSettingService = securitiesSettingService;
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
    return this.securitiesSettingService.setActiveSecurities(
      this.activeSecuritiesId, configurations);
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

}
