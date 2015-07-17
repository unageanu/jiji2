import ContainerJS  from "container-js";
import Observable   from "../../utils/observable";

export default class Rates extends Observable {
  constructor() {
    super();
    this.rateService = ContainerJS.Inject;
  }

  initialize() {
    if (!this.isInitialied()) {
      this.initializedDeferred = this.reload();
    }
    return this.initializedDeferred;
  }

  isInitialied() {
    if (!this.initializedDeferred) return false;
    if (this.initializedDeferred.rejected()) return false;
    return true;
  }

  reload() {
    const d = this.rateService.getRange();
    d.done((range) => this.range = range );
    return d;
  }

  fetchRates( name, interval, start, end ) {
    return this.rateService.fetchRates( name, interval, start, end )
      .then( this.updateRange.bind(this) );
  }

  updateRange(rates) {
    if (!rates || rates.length <= 0) return rates;
    const start = rates[0].timestamp;
    const end   = rates[rates.length-1].timestamp;
    const newRange = this.calculateNewRange(start, end);
    if (newRange) {
      this.setProperty("range", newRange);
    }
    return rates;
  }

  calculateNewRange(start, end) {
    if (!this.range) {
      return {
        start: start,
        end:   end
      };
    } else {
      let updated = false;
      let newRange = {
        start: this.range.start,
        end:   this.range.end
      };
      if ( start.getTime() < this.range.start.getTime() ) {
        newRange.start = start;
        updated = true;
      }
      if ( end.getTime() > this.range.end.getTime() ) {
        newRange.end = end;
        updated = true;
      }
      return updated ? newRange : null;
    }
  }

  get range() {
    return this.getProperty("range");
  }
  set range(range) {
    this.setProperty("range", range);
  }
}
