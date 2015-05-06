import React      from "react";
import MUI        from "material-ui";
import Chart      from "../chart/chart";

export default React.createClass({

  contextTypes: {
    application: React.PropTypes.object.isRequired
  },
  propTypes: {
    devicePixelRatio: React.PropTypes.number.isRequired,
    canvasSize: React.PropTypes.object.isRequired
  },

  getDefaultProps() {
    const devicePixelRatio = window.devicePixelRatio || 1;
    const canvasSize       = {w:300, h:200};
    return {
      devicePixelRatio: devicePixelRatio,
      canvasSize: canvasSize
    };
  },

  componentDidMount() {
    const canvas = React.findDOMNode(this.refs.canvas);
    const chart  = new Chart( canvas, this.props.devicePixelRatio,
      this.props.canvasSize, this.context.application.viewModelFactory );
  },

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
});
