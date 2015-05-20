import ContainerJS          from "container-js"
import Observable           from "../../utils/observable"
import Dates                from "../../utils/dates"
import NumberUtils          from "../../utils/number-utils"
import DateFormatter        from "../utils/date-formatter"
import Intervals            from "../../model/trading/intervals"

/**
 * 同時に表示するポジションの最大数。
 */
const maxDisplayCounts = 8;


class Slot {

  constructor(coordinateCalculator) {
    this.coordinateCalculator = coordinateCalculator;
    this.positions = [];
  }
  isVacant( position ) {
    return this.positions.findIndex(
      (item) => Slot.overlap( position, item )) === -1;
  }
  add( position ) {
    this.positions.push(position);
  }
  clear() {
    this.positions = [];
  }
  toDisplayPositions() {
    return this.positions.map((p) => {
      p.startX = this.coordinateCalculator.calculateX(p.normalizedStart);
      if (p.normalizedEnd) p.endX = this.coordinateCalculator.calculateX(p.normalizedEnd);
      return p;
    });
  }

  static overlap( a, b ) {
    return (!b.normalizedEnd || a.normalizedStart.getTime() <= b.normalizedEnd.getTime())
        && (!a.normalizedEnd || a.normalizedEnd.getTime() >= b.normalizedStart.getTime());
  }
}

export default class Positions extends Observable {

  constructor(coordinateCalculator, positionService, backtestId) {
    super();
    this.backtestId           = backtestId;
    this.positionService      = positionService;
    this.coordinateCalculator = coordinateCalculator;

    this.initSlots();
  }

  initSlots() {
    this.slots = [];
    for (let i=0; i<maxDisplayCounts; i++) {
      this.slots.push(new Slot(this.coordinateCalculator));
    }
  }

  attach(slider) {
    this.slider = slider;
    this.slider.addObserver("propertyChanged", (n, e) => {
      if (e.key === "currentRange") {
        this.currentRange = e.newValue;
        this.update();
      }
    }, this);

    this.currentRange = slider.currentRange;
    this.update();
  }

  unregisterObservers() {
    this.slider.removeAllObservers(this);
  }

  update() {
    if (!this.currentRange) return;
    this.positionService.fetchPositions(
      this.currentRange.start,
      this.currentRange.end,
      this.backtestId
    ).then((data) => this.positions = data );
  }

  set positionsForDisplay(positions) {
    this.setProperty("positionsForDisplay", positions);
  }
  get positionsForDisplay() {
    return this.getProperty("positionsForDisplay");
  }

  set positions(data) {
    this.setProperty("positions", data);
    this.positionsForDisplay = this.calculatePositionsForDisplay(data);
  }
  get positions() {
    return this.getProperty("positions");
  }

  calculatePositionsForDisplay( positions ) {
    this.slots.forEach((s) => s.clear());
    positions.forEach((p) => {
      p.normalizedStart = this.normalizeDate(p.enteredAt);
      p.normalizedEnd   = this.normalizeDate(p.exitedAt);
      const vacancy = this.slots.find((slot) => slot.isVacant(p));
      if (vacancy) vacancy.add(p);
    });
    return this.slots.map((s) => s.toDisplayPositions());
  }

  normalizeDate(date) {
    if (!date) return null;
    return this.coordinateCalculator.normalizeDate(date);
  }
}
