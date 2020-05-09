import React                            from "react"
import { injectIntl, FormattedMessage } from 'react-intl';

import AbstractComponent   from "../widgets/abstract-component"
import NumberFormatter     from "../../../viewmodel/utils/number-formatter"
import DateFormatter       from "../../../viewmodel/utils/date-formatter"
import Utils               from "./utils"
import AgentSettingEditor  from "../agents/agent-setting-editor"
import ConfirmDialog       from "../widgets/confirm-dialog"
import ButtonIcon          from "../widgets/button-icon"
import LoadingImage        from "../widgets/loading-image"

import RaisedButton from "material-ui/RaisedButton"

const keys = new Set([
  "selectedBacktest"
]);

class BacktestPropertiesView extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      executingAction: false
    };
  }

  componentWillMount() {
    const model = this.props.model;
    this.registerPropertyChangeListener(model, keys);
    this.setState(this.collectInitialState(model, keys));
  }

  render() {
    const { formatMessage } = this.props.intl;
    return <div className="backtest-properties-view">
      <ConfirmDialog
        key="confirmRemoveDialog" ref="confirmRemoveDialog"
        text={formatMessage({ id: 'backtests.BacktestPropertiesView.confirmRemove' })} />
      <ConfirmDialog
        key="confirmCancelDialog" ref="confirmCancelDialog"
        text={formatMessage({ id: 'backtests.BacktestPropertiesView.confirmCancel' })} />
      <ConfirmDialog
        key="confirmRestartDialog" ref="confirmRestartDialog"
        text={formatMessage({ id: 'backtests.BacktestPropertiesView.confirmRestart' })} />
      {this.createButtons()}
      <div className="items">
        {this.createItems()}
        <div className="item agent-settings">
          <div className="label"><FormattedMessage id='backtests.BacktestPropertiesView.agent' /></div>
          <div>
            <AgentSettingEditor
              model={this.props.model.agentSettingBuilder}
              readOnly={true} />
          </div>
        </div>
      </div>
    </div>;
  }

  createButtons() {
    const { formatMessage } = this.props.intl;
    const buttons = [];
    const backtest = this.state.selectedBacktest;

    if (backtest.enableRestart) {
      buttons.push(this.createButton("restart",
        formatMessage({ id: 'backtests.BacktestPropertiesView.button.restart' }), "md-replay", this.restart.bind(this)));
    }
    if (backtest.enableCancel) {
      buttons.push(this.createButton("cancel",
        formatMessage({ id: 'backtests.BacktestPropertiesView.button.cancel' }), "md-pause", this.cancel.bind(this)));
    }
    if (backtest.enableDelete) {
      buttons.push(this.createButton("delete",
        formatMessage({ id: 'backtests.BacktestPropertiesView.button.remove' }), "md-delete", this.delete.bind(this)));
    }
    const loading = this.state.executingAction
      ? <span className="loading">
          <LoadingImage size={20} top={0} left={-16} />
        </span>
      : null;
    return <div className="buttons">
      {loading}
      {buttons}
    </div>;
  }

  createButton(key, label, icon, action) {
    return <RaisedButton
      className="button"
      key={key}
      label={label}
      labelStyle={{padding:"0px 16px 0px 8px"}}
      disabled={this.state.executingAction}
      onClick={action}>
      <ButtonIcon className={icon} />
    </RaisedButton>;
  }

  createItems() {
    const { formatMessage } = this.props.intl;
    const backtest = this.state.selectedBacktest;
    return [
      this.createItem(formatMessage({ id: 'backtests.BacktestPropertiesView.columns.name' }),    backtest.name, "name"),
      this.createItem(formatMessage({ id: 'backtests.BacktestPropertiesView.columns.createdAt' }), backtest.formattedCreatedAt, "created-at"),
      this.createItem(formatMessage({ id: 'backtests.BacktestPropertiesView.columns.status' }),    this.createStatusContent(backtest), "status"),
      this.createItem(formatMessage({ id: 'backtests.BacktestPropertiesView.columns.range' }),    backtest.formattedPeriod, "period"),
      this.createItem(formatMessage({ id: 'backtests.BacktestPropertiesView.columns.balance' }), "￥ " + backtest.formattedBalance, "balance"),
      this.createItem(formatMessage({ id: 'backtests.BacktestPropertiesView.columns.pairs' }), backtest.pairNames.join(" "), "pairs"),
      this.createItem(formatMessage({ id: 'backtests.BacktestPropertiesView.columns.tickInterval' }), formatMessage({ id: `common.tickInterval.${backtest.tickInterval}`}), "tickInterval"),
      this.createItem(formatMessage({ id: 'backtests.BacktestPropertiesView.columns.memo' }),    <pre>{backtest.memo}</pre>, "memo")
    ];
  }

  createItem(label, value, key) {
    return <div key={key} className={"item " + key}>
      <div className="label">{label}</div>
      <div className="value">{value}</div>
    </div>;
  }

  createStatusContent(backtest) {
    switch(backtest.status) {
      case "error" :
        return <span className="error">
          <span className={"icon md-warning"} /> <FormattedMessage id='backtests.BacktestPropertiesView.error' />
        </span>;
      default :
        return Utils.createStatusContent(backtest);
    }
  }

  delete(ev) {
    const backtest = this.state.selectedBacktest;
    if (!backtest) return;
    this.refs.confirmRemoveDialog.confilm().then((id)=> {
      if (id != "yes") return;
      this.setState({executingAction:true});
      this.props.model.remove(backtest.id).always(
        () => this.setState({executingAction:false}) );
    });
  }
  restart(ev) {
    const backtest = this.state.selectedBacktest;
    if (!backtest) return;
    this.refs.confirmRestartDialog.confilm().then((id)=> {
      if (id != "yes") return;
      this.setState({executingAction:true});
      this.props.model.restart(backtest.id).always(
        () => this.setState({executingAction:false}) );
    });
  }
  cancel(ev) {
    const backtest = this.state.selectedBacktest;
    if (!backtest) return;
    this.refs.confirmCancelDialog.confilm().then((id)=> {
      if (id != "yes") return;
      this.setState({executingAction:true});
      this.props.model.cancel(backtest.id).always(
        () => this.setState({executingAction:false}) );
    });
  }
}
BacktestPropertiesView.propTypes = {
  model: React.PropTypes.object.isRequired
};
BacktestPropertiesView.defaultProps = {};

export default injectIntl(BacktestPropertiesView)
