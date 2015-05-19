import React            from "react"
import MUI              from "material-ui"
import AbstractPage     from "./abstract-page"
import Chart            from "../chart/chart"
import IntervalSelector from "../chart/interval-selector"
import PairSelector     from "../chart/pair-selector"

export default class HomePage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <div>
        <PairSelector />
        <IntervalSelector />
        <Chart />
      </div>
    );
  }
}
