import React         from "react"
import MUI           from "material-ui"
import Draggable     from "react-draggable2"
import DateFormatter from "../../../viewmodel/utils/date-formatter"

class RangeView extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      range: {}
    };
  }
  render() {
    const displayRange = this.format(this.state.range.start)
              + " ～ " + this.format(this.state.range.end);
    return (
      <div className="range">{displayRange}</div>
    );
  }
  format(date) {
    return DateFormatter.formatDateYYYYMMDD(date)
       + " " + DateFormatter.formatTimeHHMM(date);
  }
}

export default class Slider extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      handlePosition : 0,
      handleWidth: 0,
      barWidth: 0
    };
  }

  componentWillMount() {
    this.props.chartModel.slider.addObserver("propertyChanged", (n, e) => {
      if (e.key !== "width"     && e.key !== "pageWidth"
       && e.key !== "positionX" && e.key !== "currentRange" ) {
        return;
      }
      this.setState({
        handlePosition : this.props.chartModel.slider.positionX,
        handleWidth: this.props.chartModel.slider.pageWidth,
        barWidth: this.props.chartModel.slider.width
      });
      this.refs.rangeView.setState({
        range: this.props.chartModel.slider.currentRange || {}
      });
    });
  }

  render() {
    return (
      <div className="slider">
        <RangeView ref="rangeView" />
        <div className="bar" style={{
          width: this.state.barWidth+"px"
        }}>
          <Draggable
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
          </Draggable>
        </div>
      </div>
    );
  }

  handleStart(event, ui) {
  }
  handleDrag(event, ui) {
    const result = this.props.chartModel.slider.calculateCurrentRange(ui.position.left);
    this.refs.rangeView.setState({
      range: result.range
    });
  }
  handleStop(event, ui) {
    this.props.chartModel.slider.positionX = ui.position.left;
  }
}
Slider.propTypes = {
  chartModel: React.PropTypes.object.isRequired
};
Slider.defaultProps = {};
