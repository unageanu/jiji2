import React                from "react";

import CreateJS             from "easeljs"
import CandleSticks         from "./candle-sticks"
import Background           from "./background"
import Axises               from "./axises"
import Slider               from "./slider"
import GraphView            from "./graph-view"
import PositionsView        from "./positions-view"
import Pointer              from "./pointer"
import CoordinateCalculator from "../../../viewmodel/chart/coordinate-calculator"

const padding = CoordinateCalculator.padding();

export default class Chart extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentWillMount() {
  }

  componentDidMount() {
    this.props.model.stageSize = this.props.size;
    const canvas = React.findDOMNode(this.refs.canvas);

    this.buildStage(canvas, this.props.devicePixelRatio);
    this.buildViewComponents();

    this.initViewComponents();
    this.context.application.initialize()
      .then( () => this.props.model.initialize() );
  }

  componentWillUnmount() {
    this.axises.unregisterObservers();
    this.candleSticks.unregisterObservers();
    this.graphView.unregisterObservers();
    this.positionsView.unregisterObservers();
  }

  render() {
    const r = this.props.devicePixelRatio;
    const slider = this.props.enableSlider ?
      <Slider chartModel={this.props.model}></Slider> : null;
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
    const model = this.props.model;

    this.background    = new Background( model );
    this.axises        = new Axises( model, this.slidableMask );
    this.candleSticks  = new CandleSticks( model, this.slidableMask );
    this.graphView     = new GraphView( model, this.slidableMask );
    this.positionsView = new PositionsView( model, this.slidableMask );
    this.pointer       = new Pointer( model, this.slidableMask );
  }
  initViewComponents() {
    this.background.attach( this.stage );
    this.axises.attach( this.stage );
    this.pointer.attach( this.stage );
    this.candleSticks.attach( this.stage );
    this.graphView.attach( this.stage );
    this.positionsView.attach( this.stage );
  }

  registerSlideAction() {
    this.stage.addEventListener("mousedown", (event) => {
      if (this.pointer.slideXStart != null
       || this.pointer.slideYStart != null) {
        return;
      }
      this.slideStart = event.stageX;
      this.props.model.slider.slideStart();
    });
    this.stage.addEventListener("pressmove", (event) => {
      if (!this.slideStart) return;
      this.doSlide( event.stageX );
    });
    this.stage.addEventListener("pressup", (event) => {
      if (!this.slideStart) return;
      this.doSlide( event.stageX );
      this.props.model.slider.slideEnd();
      this.slideStart = null;
    });
  }

  doSlide(x) {
    x = Math.ceil((this.slideStart - x) / (6*this.props.devicePixelRatio)) * -6;
    this.props.model.slider.slideByChart(x/6);
  }

  createSlidableMask() {
    const stageSize    = this.props.model.candleSticks.stageSize;
    const axisPosition = this.props.model.candleSticks.axisPosition;
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
  devicePixelRatio: React.PropTypes.number.isRequired,
  size: React.PropTypes.object.isRequired,
  model: React.PropTypes.object.isRequired
};
Chart.defaultProps = {
  enableSlider : true,
  devicePixelRatio: window.devicePixelRatio || 1,
  size: {w:600, h:500}
};
