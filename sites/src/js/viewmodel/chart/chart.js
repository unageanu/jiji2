import Observable           from "../../utils/observable";
import CandleSticks         from "./candle-sticks";
import Slider               from "./slider";
import CoordinateCalculator from "./coordinate-calculator";

export default class Chart extends Observable {

  constructor( rates, preferences ) {
    super();

    this.coordinateCalculator = new CoordinateCalculator();
    this.slider               = new Slider(this.coordinateCalculator, rates, preferences);
    this.candleSticks         = new CandleSticks(this.coordinateCalculator, rates, preferences);

    this.coordinateCalculator.attach(this.slider, preferences);
    this.candleSticks.attach(this.slider);
  }

  set stageSize(size) {
    this.candleSticks.stageSize = size;
    this.coordinateCalculator.stageSize = size;
    this.slider.width = size.w;
  }
}
