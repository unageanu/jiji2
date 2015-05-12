import React         from "react"
import MUI           from "material-ui"
import Draggable     from "react-draggable2"
import DateFormatter from "../../../viewmodel/utils/date-formatter"

export default class Slider extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      handlePosition : 0,
      handleWidth: 0,
      barWidth: 0,
      range: {}
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
        barWidth: this.props.chartModel.slider.width,
        range: this.props.chartModel.slider.currentRange || {}
      });
    });
  }

  render() {
    const displayRange = DateFormatter.format(this.state.range.start)
              + " ～ " + DateFormatter.format(this.state.range.end);
    return (
      <div className="slider">
        <div className="range">{displayRange}</div>
        <div className="bar" style={{
          width: this.state.barWidth+"px"
        }}>
          <Draggable
            axis="x"
            handle=".handle"
            start={{x: this.state.handlePosition, y: 0}}
            bound="point"
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
    this.setState({
      range: result.range,
      handlePosition: ui.position.left
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
