import Observable           from "../../utils/observable";
import CandleSticks         from "./candle-sticks";
import Slider               from "./slider";
import CoordinateCalculator from "./coordinate-calculator";
import Positions            from "./positions";
import Graphs               from "./graphs";

export default class Chart extends Observable {

  constructor( rates, preferences, positionService, graphService,
    displayPositonsAndGraphs, backtestId, graphs ) {
    super();

    this.rates           = rates;
    this.preferences     = preferences;
    this.positionService = positionService;
    this.graphService    = graphService;

    this.coordinateCalculator = new CoordinateCalculator();
    this.slider               = new Slider(this.coordinateCalculator, rates, preferences);
    this.candleSticks         = new CandleSticks(this.coordinateCalculator, rates, preferences);

    if (displayPositonsAndGraphs) {
      this.positions = new Positions(
        this.coordinateCalculator, this.positionService, backtestId);
      this.graphs = new Graphs( this.coordinateCalculator,
        this.preferences, this.graphService, backtestId, graphs);
    }

    this.coordinateCalculator.attach(this.slider, preferences);
    this.candleSticks.attach(this.slider);
    if (displayPositonsAndGraphs) {
      this.positions.attach(this.slider);
      this.graphs.attach(this.slider);
    }
  }

  initialize( ) {
    this.rates.initialize();
  }
  destroy() {
    this.slider.unregisterObservers();
    this.candleSticks.unregisterObservers();
    if (this.positions) this.positions.unregisterObservers();
    if (this.graphs) this.graphs.unregisterObservers();
  }

  set stageSize(size) {
    this.candleSticks.stageSize = size;
    this.coordinateCalculator.stageSize = size;
    this.slider.width = size.w;
  }
}
