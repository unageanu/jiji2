import React               from "react"
import Router              from "react-router"
import MUI                 from "material-ui"
import AbstractComponent   from "../widgets/abstract-component"
import BacktestListItem    from "./backtest-list-item"

const List         = MUI.List;

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
    const items = this.state.items.map(
      (item) => this.createItemComponent(item));
    return (
      <div className="backtest-list list">
        <List>{items}</List>
      </div>
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
    this.context.router.transitionTo("/backtests/list/" + backtest.id);
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
  router: React.PropTypes.func
};
