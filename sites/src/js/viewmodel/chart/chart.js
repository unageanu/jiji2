import Observable    from "../../utils/observable";
import CandleSticks  from "./candle-sticks";
import Slider        from "./slider";

export default class Chart extends Observable {

  constructor( rates, preferences ) {
    super();
    this.candleSticks = new CandleSticks(rates, preferences);
    this.slider       = new Slider(this.candleSticks, rates, preferences);

    this.candleSticks.attachSlider(this.slider);
  }

  set stageSize(size) {
    this.candleSticks.stageSize = size;
    this.slider.width = size.w;
  }
}
