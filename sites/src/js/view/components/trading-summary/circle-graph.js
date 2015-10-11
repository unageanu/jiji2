import React             from "react"
import Router            from "react-router"
import MUI               from "material-ui"
import ReactChart        from "react-chartjs"
import AbstractComponent from "../widgets/abstract-component"

const DoughnutChart = ReactChart.Doughnut;
const doughnutChartOptions = {
  tooltipTemplate(values) {
    return `${values.label} ${values.value}`;
  },
  segmentStrokeColor : "#f0f0f0",
  tooltipFillColor: "rgba(30,30,30,0.7)",
  tooltipFontFamily: "Roboto Condensed', 'ヒラギノ角ゴ Pro W3', 'Hiragino Kaku Gothic Pro', 'メイリオ', Meiryo, 'Noto Sans Japanese', sans-serif",
  tooltipCornerRadius: 2,
  percentageInnerCutout : 80,
  segmentStrokeWidth : 0,
  segmentShowStroke : false
};

export default class CircleGraph extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <div className="circle-graph">
        <div className="title">{this.props.title}</div>
        <div className="circle-graph-body">
          <div className="chart">
            <span>
              <DoughnutChart
                redraw={true}
                data={this.props.data}
                options={this.getDoughnutChartOptions()}
                width={this.props.size} height={this.props.size} />
            </span>
          </div>
          <div className="tables">
            {this.createTableRows()}
          </div>
        </div>
      </div>
    );
  }

  createTableRows() {
    return this.props.data.map( (content, index) => {
      return <div className="item" key={index}>
        <div className="label">{content.label}</div>
        <div className="value">{content.value}</div>
      </div>
    });
  }

  getDoughnutChartOptions() {
    return doughnutChartOptions;
  }
}

CircleGraph.propTypes = {
  title: React.PropTypes.string.isRequired,
  data:  React.PropTypes.array,
  size:  React.PropTypes.number
};
CircleGraph.defaultProps = {
  data: [],
  size: 200
};
