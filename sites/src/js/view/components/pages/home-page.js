import React      from "react";
import MUI        from "material-ui";
import Chart      from "../chart/chart";
import Slider     from "../chart/slider";

export default class HomePage extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentWillMount() {
    this.chartModel = this.context.application.viewModelFactory.createChart();
    this.chartModel.stageSize = this.props.canvasSize;
  }

  componentDidMount() {
    const canvas = React.findDOMNode(this.refs.canvas);
    this.chart  = new Chart(
      canvas, this.props.devicePixelRatio, this.chartModel );
    this.context.application.initialize()
      .then( () => this.chartModel.initialize() );
  }

  render() {
    const r = this.props.devicePixelRatio;
    return (
      <div>
        <canvas ref="canvas"
          width={this.props.canvasSize.w*r}
          height={this.props.canvasSize.h*r}
          style={{
            width: this.props.canvasSize.w+"px",
            height: this.props.canvasSize.h+"px"
        }}>
        </canvas>
        <Slider chartModel={this.chartModel}></Slider>
      </div>
    );
  }
}

HomePage.contextTypes = {
  application: React.PropTypes.object.isRequired
};
HomePage.propTypes = {
  devicePixelRatio: React.PropTypes.number.isRequired,
  canvasSize: React.PropTypes.object.isRequired
};
HomePage.defaultProps = {
  devicePixelRatio: window.devicePixelRatio || 1,
  canvasSize: {w:300, h:200}
};
