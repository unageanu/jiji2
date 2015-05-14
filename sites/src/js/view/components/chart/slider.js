import React         from "react"
import MUI           from "material-ui"
import Draggable     from "react-draggable2"
import DateFormatter from "../../../viewmodel/utils/date-formatter"
import RangeView     from "./range-view"

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
      if ( e.key === "pageWidth" ) {
        this.setState({ handleWidth: e.newValue});
      } else if ( e.key === "positionX" || e.key === "temporaryPositionX") {
        this.setState({ handlePosition: e.newValue});
      }
    });
    this.setState({
      handlePosition : this.props.chartModel.slider.positionX,
      handleWidth:     this.props.chartModel.slider.pageWidth
    });
  }

  render() {
    return (
      <div className="slider">
        <RangeView ref="rangeView" chartModel={this.props.chartModel} />
        <div className="bar">
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
