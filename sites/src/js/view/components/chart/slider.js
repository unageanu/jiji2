import React         from "react"

import Draggable     from "react-draggable"
import DateFormatter from "../../../viewmodel/utils/date-formatter"
import RangeView     from "./range-view"
import AbstractComponent  from "../widgets/abstract-component"

const keys = new Set([
  "pageWidth", "positionX", "temporaryPositionX", "width"
]);

export default class Slider extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      handlePosition : 0,
      handleWidth: 0,
      barWidth: 0
    };
  }

  componentWillMount() {
    this.registerPropertyChangeListener(  this.props.chartModel.slider, keys);
    this.setState({
      barWidth       : this.props.chartModel.slider.width,
      handlePosition : this.props.chartModel.slider.positionX,
      handleWidth:     this.props.chartModel.slider.pageWidth
    });
  }

  onPropertyChanged(k, e) {
    if ( e.key === "pageWidth" ) {
      this.setState({ handleWidth: e.newValue});
    } else if ( e.key === "positionX" || e.key === "temporaryPositionX") {
      this.setState({ handlePosition: e.newValue});
    } else if ( e.key === "width") {
      this.setState({ barWidth: e.newValue});
    }
  }

  render() {
    return (
      <div className="slider">
        <RangeView ref="rangeView" chartModel={this.props.chartModel} />
        <div className="bar" style={{
          width:   this.state.barWidth+"px"
        }} >
          {this.createHandle()}
        </div>
      </div>
    );
  }

  createHandle() {
    if ( this.state.handleWidth >= this.state.barWidth ) return null;
    return <Draggable
      axis="x"
      handle=".handle"
      start={{x: this.state.handlePosition, y: 0}}
      bound="box all"
      onStart={this.handleStart.bind(this)}
      onDrag={this.handleDrag.bind(this)}
      onStop={this.handleStop.bind(this)}>
      <div className="handle" style={{
        width:   this.state.handleWidth+"px",
        display: this.state.handleWidth > 0 ? "inline-block" : "none"
      }}>
      </div>
    </Draggable>;
  }

  handleStart(event, ui) {
    this.props.chartModel.slider.slideStart();
  }
  handleDrag(event, ui) {
    this.props.chartModel.slider.slideByHandle(ui.position.left);
  }
  handleStop(event, ui) {
    this.props.chartModel.slider.slideByHandle(ui.position.left);
    this.props.chartModel.slider.slideEnd();
  }
}
Slider.propTypes = {
  chartModel: React.PropTypes.object.isRequired
};
Slider.defaultProps = {};
