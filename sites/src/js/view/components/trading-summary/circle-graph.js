import React             from "react"
import { Router } from 'react-router'

import ReactChart        from "react-chartjs"
import AbstractComponent from "../widgets/abstract-component"

const DoughnutChart = ReactChart.Doughnut;
const doughnutChartOptions = {
  legend: { display: false },
  tooltips: {
    titleFontFamily: "Roboto Condensed', 'ヒラギノ角ゴ Pro W3', 'Hiragino Kaku Gothic Pro', 'メイリオ', Meiryo, 'Noto Sans Japanese', sans-serif",
    backgroundColor: "rgba(30,30,30,0.7)",
    custom(values) {
      return `${values.label} ${values.value}`;
    }
  },
  cutoutPercentage : 80
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
    const data = this.props.data;
    return data.labels.map( (content, index) => {
      return <div className="item" key={index}>
        <div className="label">{content}</div>
        <div className="value">{data.datasets[0].data[index]}</div>
      </div>
    });
  }

  getDoughnutChartOptions() {
    return doughnutChartOptions;
  }
}

CircleGraph.propTypes = {
  title: React.PropTypes.string.isRequired,
  data:  React.PropTypes.object,
  size:  React.PropTypes.number
};
CircleGraph.defaultProps = {
  data: {},
  size: 200
};
