import Observable           from "../../utils/observable";
import CandleSticks         from "./candle-sticks";
import Slider               from "./slider";
import CoordinateCalculator from "./coordinate-calculator";
import Positions            from "./positions";

export default class Chart extends Observable {

  constructor( rates, preferences, positionService, displayPositons, backtestId ) {
    super();

    this.rates           = rates;
    this.preferences     = preferences;
    this.positionService = positionService;

    this.coordinateCalculator = new CoordinateCalculator();
    this.slider               = new Slider(this.coordinateCalculator, rates, preferences);
    this.candleSticks         = new CandleSticks(this.coordinateCalculator, rates, preferences);

    if (displayPositons) {
      this.positions = new Positions(
        this.coordinateCalculator, this.positionService, backtestId);
    }

    this.coordinateCalculator.attach(this.slider, preferences);
    this.candleSticks.attach(this.slider);
    if (this.positions) {
      this.positions.attach(this.slider);
    }
  }

  initialize( ) {
    this.rates.initialize();
  }
  destroy() {
    this.slider.unregisterObservers();
    this.candleSticks.unregisterObservers();
  }

  set stageSize(size) {
    this.candleSticks.stageSize = size;
    this.coordinateCalculator.stageSize = size;
    this.slider.width = size.w;
  }
}
