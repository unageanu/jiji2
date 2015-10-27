import React               from "react"
import Router              from "react-router"
import MUI                 from "material-ui"
import AbstractComponent   from "../widgets/abstract-component"
import LoadingImage        from "../widgets/loading-image"
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
    return <div className="backtest-list list">
      {this.createContent()}
    </div>;
  }

  createContent() {
    if ( !this.state.items ) {
      return <div className="center-information loading"><LoadingImage left={-20}/></div>;
    }
    if (this.state.items.length <= 0) {
      return <div className="center-information">バックテストはありません</div>;
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
