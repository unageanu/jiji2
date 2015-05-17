import React        from "react"
import MUI          from "material-ui"
import AbstractPage from "./abstract-page"
import Chart        from "../chart/chart"

export default class HomePage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <Chart />
    );
  }
}
