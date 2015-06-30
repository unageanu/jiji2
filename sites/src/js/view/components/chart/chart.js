import React                from "react";

import CreateJS             from "easeljs"
import CandleSticks         from "./candle-sticks"
import Background           from "./background"
import Axises               from "./axises"
import Slider               from "./slider"
import CoordinateCalculator from "../../../viewmodel/chart/coordinate-calculator"

const padding = CoordinateCalculator.padding();

export default class Chart extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentWillMount() {
    this.chartModel = this.context.application.viewModelFactory.createChart(
      this.props.backtest,
      {displayPositionsAndGraphs: this.props.displayPositionsAndGraphs});
    this.chartModel.stageSize = this.props.size;
  }

  componentDidMount() {
    const canvas = React.findDOMNode(this.refs.canvas);

    this.buildStage(canvas, this.props.devicePixelRatio);
    this.buildViewComponents();

    this.initViewComponents();
    this.context.application.initialize()
      .then( () => this.chartModel.initialize() );
  }

  componentWillUnmount() {
    this.chartModel.destroy();
    this.axises.unregisterObservers();
    this.candleSticks.unregisterObservers();
  }

  render() {
    const r = this.props.devicePixelRatio;
    const slider = this.props.enableSlider ?
      <Slider chartModel={this.chartModel}></Slider> : null;
    return (
      <div>
        <canvas ref="canvas"
          width={this.props.size.w*r}
          height={this.props.size.h*r}
          style={{
            width: this.props.size.w+"px",
            height: this.props.size.h+"px"
        }}>
        </canvas>
        {slider}
      </div>
    );
  }

  buildStage(canvas, scale) {
    this.stage = new CreateJS.Stage(canvas);
    this.stage.scaleX = scale;
    this.stage.scaleY = scale;
    CreateJS.Touch.enable(this.stage);

    this.registerSlideAction();
  }

  buildViewComponents() {
    this.slidableMask = this.createSlidableMask();

    this.background   = new Background( this.chartModel );
    this.axises       = new Axises( this.chartModel, this.slidableMask );
    this.candleSticks = new CandleSticks( this.chartModel, this.slidableMask );
  }
  initViewComponents() {
    this.background.attach( this.stage );
    this.axises.attach( this.stage );
    this.candleSticks.attach( this.stage );
  }

  registerSlideAction() {
    this.stage.addEventListener("mousedown", (event) => {
      this.slideStart = event.stageX;
      this.chartModel.slider.slideStart();
    });
    this.stage.addEventListener("pressmove", (event) => {
      if (!this.slideStart) return;
      this.doSlide( event.stageX );
    });
    this.stage.addEventListener("pressup", (event) => {
      if (!this.slideStart) return;
      this.doSlide( event.stageX );
      this.chartModel.slider.slideEnd();
      this.slideStart = null;
    });
  }

  doSlide(x) {
    x = Math.ceil((this.slideStart - x) / (6*this.props.devicePixelRatio)) * -6;
    this.chartModel.slider.slideByChart(x/6);
  }

  createSlidableMask() {
    const stageSize    = this.chartModel.candleSticks.stageSize;
    const axisPosition = this.chartModel.candleSticks.axisPosition;
    const mask         = new CreateJS.Shape();
    mask.graphics.beginFill("#000000")
      .drawRect( padding, padding, axisPosition.horizontal - padding, stageSize.h )
      .endFill();
    return mask;
  }
}
Chart.contextTypes = {
  application: React.PropTypes.object.isRequired
};
Chart.propTypes = {
  enableSlider : React.PropTypes.bool.isRequired,
  displayPositionsAndGraphs: React.PropTypes.bool.isRequired,
  devicePixelRatio: React.PropTypes.number.isRequired,
  size: React.PropTypes.object.isRequired,
  backtest: React.PropTypes.object
};
Chart.defaultProps = {
  enableSlider : true,
  displayPositionsAndGraphs: false,
  devicePixelRatio: window.devicePixelRatio || 1,
  size: {w:600, h:500},
  backtest: null
};
