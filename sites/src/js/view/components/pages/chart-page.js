import React      from "react";
import MUI        from "material-ui";

import ChartModel       from "../../../viewmodel/chart/chart";
import CandleStickChart from "../chart/candle-sticks";

export default React.createClass({

  contextTypes: {
    application: React.PropTypes.object.isRequired
  },

  componentDidMount() {

    const canvas = React.findDOMNode(this.refs.canvas);
    this.viewModel = new ChartModel();
    this.candleStickChart = new CandleStickChart(
      canvas, this.viewModel, window.devicePixelRatio / 2);

    console.log( "window.devicePixelRatio :" + window.devicePixelRatio);

    this.viewModel.stageSize = {w:640, h:800};
    this.viewModel.rateData = [
      {high:179.0, low:178.0, open:178.2, close:178.5},
      {high:179.5, low:178.2, open:178.5, close:179.5},
      {high:179.8, low:179.0, open:179.5, close:179.0},
      {high:179.0, low:178.0, open:179.0, close:178.5},
      {high:178.7, low:177.5, open:178.5, close:177.5},
      {high:179.0, low:177.7, open:177.7, close:178.5}
    ];
  },

  render() {
    var canvas = null;
    if (window.devicePixelRatio === 1) {
      canvas = <canvas ref="canvas" width="320" height="400"></canvas>;
    } else {
      const r = window.devicePixelRatio;
      canvas = <canvas ref="canvas" width={320*r} height={400*r}
        style={{width: 320+"px", height: 400+"px"}}></canvas>;
    }
    const ratio = window.devicePixelRatio / 2;
    return (
      <div>
        {{canvas}}
      </div>
    );
  }

});
