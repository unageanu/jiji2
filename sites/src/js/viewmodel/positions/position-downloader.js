import RangeSelectorModel from "../widgets/range-selector-model"
import Observable         from "../../utils/observable"
import Validators         from "../../utils/validation/validators"
import Dates              from "../../utils/dates"
import Deferred           from "../../utils/deferred"

export default class PositionDownloader extends Observable {

  constructor(rates, positionService, timeSource) {
    super();
    this.positionService = positionService;
    this.rates = rates;
    this.timeSource = timeSource;

    this.rangeSelectorModel = new RangeSelectorModel(
      Validators.backtest.startTime,
      Validators.backtest.endTime
    );

    this.downloadType = "all";
  }

  initialize(backtest) {
    const today = Dates.truncate(this.timeSource.now);
    const twentyYearsAgo = Dates.plusYears(today, -20);
    if (backtest) {
      this.backtestId = backtest.id;
      this.rangeSelectorModel.initialize(twentyYearsAgo, today,
        backtest.startTime, backtest.endTime);
    } else {
      const thirtyDaysAgo = Dates.plusDays(today, -30);
      const startTime     = Dates.truncate(thirtyDaysAgo);
      this.backtestId = "rmt";
      this.rangeSelectorModel.initialize(twentyYearsAgo,
        today, startTime, today);
    }
  }

  prepare() {
    this.rangeSelectorModel.startTimeError = null;
    this.rangeSelectorModel.endTimeError = null;
  }

  createCSVDownloadUrl(formatMessage) {
    const type = this.downloadType;
    if ( type !== "all" && !this.rangeSelectorModel.validate(formatMessage)) {
      return Deferred.valueOf(null);
    }
    const startTime = type === "all" ? null : this.rangeSelectorModel.startTime;
    const endTime   = this.calculateEndTime(type);
    const sortOrder = { order:"entered_at", direction: "desc" };
    return this.positionService.createCSVDownloadUrl(
      startTime, endTime, sortOrder, this.backtestId );
  }

  calculateEndTime(type) {
    if (type === "all") return null;
    return Dates.plusDays(this.rangeSelectorModel.endTime, 1);
    // for including all positions in the end date.
  }

  get downloadType() {
    return this.getProperty("downloadType");
  }
  set downloadType(downloadType) {
    this.setProperty("downloadType", downloadType);
    this.rangeSelectorModel.enable = downloadType !== "all"
  }

}
