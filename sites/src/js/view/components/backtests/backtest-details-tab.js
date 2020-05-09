import React              from "react"
import { injectIntl }     from 'react-intl';
import AbstractComponent  from "../widgets/abstract-component"
import {Tabs, Tab}        from "material-ui/Tabs"

class BacktestDetailsTab extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    const { formatMessage } = this.props.intl;
    return <Tabs
      onChange={this.onTabChanged.bind(this)}
      initialSelectedIndex={0}>
      <Tab label={formatMessage({ id: 'backtests.BacktestDetailsTab.info'   })} value=""></Tab>
      <Tab label={formatMessage({ id: 'backtests.BacktestDetailsTab.report' })} value="report"></Tab>
      <Tab label={formatMessage({ id: 'backtests.BacktestDetailsTab.chart'  })} value="chart"></Tab>
      <Tab label={formatMessage({ id: 'backtests.BacktestDetailsTab.trades' })} value="trades"></Tab>
      <Tab label={formatMessage({ id: 'backtests.BacktestDetailsTab.logs'   })} value="logs"></Tab>
    </Tabs>;
  }

  onTabChanged(value, ev, tab) {
    this.props.model.activeTab = value;
  }

}
BacktestDetailsTab.propTypes = {
  model: React.PropTypes.object
};

export default injectIntl(BacktestDetailsTab);
