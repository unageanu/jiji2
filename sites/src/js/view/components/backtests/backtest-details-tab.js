import React               from "react"
import MUI                 from "material-ui"
import AbstractComponent   from "../widgets/abstract-component"

const Tabs  = MUI.Tabs;
const Tab   = MUI.Tab;

export default class BacktestDetailsTab extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return <Tabs
      onChange={this.onTabChanged.bind(this)}
      initialSelectedIndex={0}>
      <Tab label="ホーム"   value=""></Tab>
      <Tab label="レポート" value="report"></Tab>
      <Tab label="チャート" value="chart"></Tab>
      <Tab label="取引一覧" value="trades"></Tab>
      <Tab label="ログ"    value="logs"></Tab>
    </Tabs>;
  }

  onTabChanged(value, ev, tab) {
    this.props.model.activeTab = value;
  }

}
BacktestDetailsTab.propTypes = {
  model: React.PropTypes.object
};
