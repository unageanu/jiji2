import Slider       from "./chart/slider";
import CandleSticks from "./chart/candle-sticks";

import ContainerJS  from "container-js";

export default class ViewModelFactory {

  constructor() {
    this.rates       = ContainerJS.Inject;
    this.preferences = ContainerJS.Inject;
    this.rateService = ContainerJS.Inject;
  }
  createSlider() {
    const candleSticks = new CandleSticks();
    return new Slider(candleSticks, this.rates, this.preferences);
  }

}
