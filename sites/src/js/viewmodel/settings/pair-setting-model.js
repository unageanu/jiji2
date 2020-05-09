import Observable        from "../../utils/observable"
import Deferred          from "../../utils/deferred"
import Error             from "../../model/error"
import ErrorMessages     from "../../errorhandling/error-messages"
import Validators        from "../../utils/validation/validators"
import PairSelectorModel from "../widgets/pair-selector-model"
import DateFormatter     from "../utils/date-formatter"

export default class PairSettingModel extends PairSelectorModel {

  constructor(pairSettingService, pairs, timeSource) {
    super(Validators.pairNames);
    this.pairs = pairs;
    this.pairSettingService = pairSettingService;
    this.timeSource = timeSource;

    this.message = null;
    this.isSaving = false;
  }

  initialize() {
    this.message = null;
    Deferred.when([
      this.pairSettingService.getPairs(),
      this.pairSettingService.getAllPairs()
    ]).then( (results) => {
      super.initialize(results[1], results[0].map((p) => p.name));
    });
  }

  save(formatMessage) {
    this.message = null;
    if (!this.validate(formatMessage)) return;
    this.isSaving = true;
    const pairs = this.pairNames.map((p) => { return { name:p } });
    this.pairSettingService.setPairs(pairs).then(
      (result) => {
        this.isSaving = false;
        this.message = formatMessage({id:'validation.messages.finishToChangeSetting'}) + " ("
          + DateFormatter.format(this.timeSource.now) + ")" ;
        this.pairs.reload();
      },
      (error) => {
        this.isSaving = false;
        this.pairNamesError = ErrorMessages.getMessageFor(formatMessage, error);
        error.preventDefault = true;
      });
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
