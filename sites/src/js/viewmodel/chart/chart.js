import Observable              from "../../utils/observable"
import Deferred                from "../../utils/deferred"
import CandleSticks            from "./candle-sticks"
import Slider                  from "./slider"
import CoordinateCalculator    from "./coordinate-calculator"
import Positions               from "./positions"
import Graphs                  from "./graphs"
import Context                 from "./context"
import Pointer                 from "./pointer"
import PreferencesPairSelector from "./preferences-pair-selector"
import BasicPairSelector       from "./basic-pair-selector"

export default class Chart extends Observable {

  constructor( config, components ) {
    super();

    this.rates           = components.rates;
    this.pairs           = components.pairs;
    this.preferences     = components.preferences;
    this.positionService = components.positionService;
    this.graphService    = components.graphService;

    this.context         = new Context(components.rates,config);

    this.buildViewModels();
  }

  buildViewModels( ) {
    this.coordinateCalculator = new CoordinateCalculator();
    this.pairSelector = this.context.usePreferencesPairSelector
      ? new PreferencesPairSelector(this.pairs, this.preferences)
      : new BasicPairSelector(this.pairs, null);

    this.slider = new Slider(
      this.context, this.coordinateCalculator, this.preferences);
    this.candleSticks = new CandleSticks( this.coordinateCalculator,
      this.rates, this.preferences, this.pairSelector);
    this.positions = new Positions( this.context,
      this.coordinateCalculator, this.positionService);
    this.graphs = new Graphs( this.context, this.coordinateCalculator,
      this.preferences, this.pairSelector, this.graphService);
    this.pointer = new Pointer(
        this.coordinateCalculator, this.candleSticks, this.graphs);

    this.coordinateCalculator.attach(this.slider, this.preferences);
    this.candleSticks.attach(this.slider);
    this.positions.attach(this.slider);
    this.graphs.attach(this.slider);
    this.pointer.attach(this.slider);
  }

  reset() {
    this.candleSticks.initialize();
    this.pointer.initialize();
    this.slider.initialize();
  }

  initialize( ) {
    this.pointer.initialize();
    return Deferred.when([
      this.pairs.initialize(),
      this.context.reload()
    ]);
  }

  reload() {
    return this.context.reload();
  }

  destroy() {
    this.context.unregisterObservers();
    this.slider.unregisterObservers();
    this.candleSticks.unregisterObservers();
    this.positions.unregisterObservers();
    this.graphs.unregisterObservers();
    this.pairSelector.unregisterObservers();
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
