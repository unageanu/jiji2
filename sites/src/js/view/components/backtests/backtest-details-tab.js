import React              from "react"
import AbstractComponent  from "../widgets/abstract-component"
import {Tabs, Tab}        from "material-ui/Tabs"

export default class BacktestDetailsTab extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return <Tabs
      onChange={this.onTabChanged.bind(this)}
      initialSelectedIndex={0}>
      <Tab label="テスト情報" value=""></Tab>
      <Tab label="レポート"   value="report"></Tab>
      <Tab label="チャート"   value="chart"></Tab>
      <Tab label="建玉一覧"   value="trades"></Tab>
      <Tab label="ログ"      value="logs"></Tab>
    </Tabs>;
  }

  onTabChanged(value, ev, tab) {
    this.props.model.activeTab = value;
  }

}
BacktestDetailsTab.propTypes = {
  model: React.PropTypes.object
};
