import React                from "react"
import { FormattedMessage } from 'react-intl';
import { Router } from 'react-router'

import AbstractComponent   from "../widgets/abstract-component"
import LoadingImage        from "../widgets/loading-image"
import BacktestListItem    from "./backtest-list-item"

import {List} from "material-ui/List"

const keys = new Set([
  "selectedBacktestId"
]);
const listModelKeys = new Set([
  "items"
]);

export default class BacktestList extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      items :    []
    };
  }

  componentWillMount() {
    const model = this.model();
    this.registerPropertyChangeListener(model, keys);
    this.registerPropertyChangeListener(model.backtestList, listModelKeys);
    this.setState(Object.assign(
      this.collectInitialState(model, keys),
      this.collectInitialState(model.backtestList, listModelKeys)
    ));
  }

  render() {
    return <div className="backtest-list list">
      {this.createContent()}
    </div>;
  }

  createContent() {
    if ( !this.state.items ) {
      return <div className="center-information loading"><LoadingImage left={-20}/></div>;
    }
    if (this.state.items.length <= 0) {
      return <div className="center-information"><FormattedMessage id='backtests.BacktestList.noBacktests' /></div>;
    }
    const items = this.state.items.map(
      (item) => this.createItemComponent(item));
    return (
      <List style={{
        paddingTop: "8px",
        backgroundColor: "rgba(0,0,0,0)"}}>
        {items}
      </List>
    );
  }

  createItemComponent(backtest) {
    const tapAction = (e) => this.onItemTapped(e, backtest);
    const selected  = this.state.selectedBacktestId === backtest.id;
    return (
      <BacktestListItem
        key={backtest.id}
        selected={selected}
        onTouchTap={tapAction}
        backtest={backtest}>
      </BacktestListItem>
    );
  }

  onItemTapped(e, backtest) {
    this.context.router.push({ pathname: "/backtests/list/" + backtest.id });
  }

  model() {
    return this.props.model;
  }
}
BacktestList.propTypes = {
  model: React.PropTypes.object.isRequired
};
BacktestList.defaultProps = {
  model: null
};
BacktestList.contextTypes = {
  router: React.PropTypes.object
};
