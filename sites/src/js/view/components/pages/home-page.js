import React      from "react";
import MUI        from "material-ui";
import Chart      from "../chart/chart";

export default class HomePage extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentDidMount() {
    const canvas = React.findDOMNode(this.refs.canvas);
    const chart  = new Chart( canvas, this.props.devicePixelRatio,
      this.props.canvasSize, this.context.application.viewModelFactory );
    this.context.application.initialize().then( () => chart.initModel() );
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
