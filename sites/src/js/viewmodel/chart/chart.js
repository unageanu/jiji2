import Observable           from "../../utils/observable";
import Deferred             from "../../utils/deferred";
import CandleSticks         from "./candle-sticks";
import Slider               from "./slider";
import CoordinateCalculator from "./coordinate-calculator";
import Positions            from "./positions";
import Graphs               from "./graphs";
import Context              from "./context";

export default class Chart extends Observable {

  constructor( config, components ) {
    super();

    this.rates           = components.rates;
    this.pairs           = components.pairs;
    this.preferences     = components.preferences;
    this.positionService = components.positionService;
    this.graphService    = components.graphService;

    this.context         = new Context(components.rates);

    this.buildViewModels( config );
  }

  buildViewModels( config ) {
    this.coordinateCalculator = new CoordinateCalculator();
    this.slider               = new Slider(
      this.context, this.coordinateCalculator, this.preferences);
    this.candleSticks         = new CandleSticks(
      this.coordinateCalculator, this.rates, this.preferences);

    if (config.displayPositionsAndGraphs) {
      this.positions = new Positions( this.context,
        this.coordinateCalculator, this.positionService);
      this.graphs = new Graphs( this.context,
        this.coordinateCalculator, this.preferences, this.graphService);
    }

    this.coordinateCalculator.attach(this.slider, this.preferences);
    this.candleSticks.attach(this.slider);
    if (config.displayPositionsAndGraphs) {
      this.positions.attach(this.slider);
      this.graphs.attach(this.slider);
    }
  }

  initialize( ) {
    return Deferred.when([
      this.pairs.initialize(),
      this.context.initialize()
    ]);
  }

  destroy() {
    this.context.unregisterObservers();
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

  set backtest(backtest) {
    this.context.backtest = backtest;
  }
}
