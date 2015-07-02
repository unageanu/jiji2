import Observable           from "../../utils/observable";
import CandleSticks         from "./candle-sticks";
import Slider               from "./slider";
import CoordinateCalculator from "./coordinate-calculator";
import Positions            from "./positions";
import Graphs               from "./graphs";
import Context              from "./context";

export default class Chart extends Observable {

  constructor( backtest, config, components ) {
    super();

    this.rates           = components.rates;
    this.preferences     = components.preferences;
    this.positionService = components.positionService;
    this.graphService    = components.graphService;

    this.context         = this.createContext(backtest);

    this.buildViewModels( config );
  }

  createContext(backtest) {
    return backtest
      ? Context.createBacktestContext(backtest)
      : Context.createRmtContext(this.rates);
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
    return this.context.initialize();
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
}
