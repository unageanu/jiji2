import React  from "react"
import Router from "react-router"
import MUI    from "material-ui"

const List         = MUI.List;
const ListItem     = MUI.ListItem;
const RaisedButton = MUI.RaisedButton;

export default class BacktestList extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      items :    []
    };
  }

  componentWillMount() {
    this.model().addObserver("propertyChanged",
      this.onPropertyChanged.bind(this), this);
  }
  componentWillUnmount() {
    this.model().removeAllObservers(this);
  }

  render() {
    const items = this.state.items.map(
      (item) => this.createItemComponent(item));
    return (
      <div className="backtest-list">
        <div className="list">
          <List>{items}</List>
        </div>
      </div>
    );
  }

  createItemComponent(backtest) {
    const tapAction = (e) => this.onItemTapped(e, backtest);
    const selected  = this.props.selectedId === backtest.id;
    return (
      <ListItem
        key={backtest.id}
        className={selected ? "mui-selected" : ""}
        onTouchTap={tapAction}>
        {backtest.name + " " + backtest.status + " " + (backtest.progress*100)}
      </ListItem>
    );
  }

  onPropertyChanged(k, ev) {
    const newState = {};
    newState[ev.key] = ev.newValue;
    this.setState(newState);
  }

  onItemTapped(e, backtest) {
    this.context.router.transitionTo("/backtests/list/" + backtest.id);
  }

  model() {
    return this.props.model;
  }
}
BacktestList.propTypes = {
  selectedId : React.PropTypes.string.isRequired,
  model: React.PropTypes.object.isRequired
};
BacktestList.defaultProp = {
  selectedId : null,
  model: null
};
BacktestList.contextTypes = {
  application: React.PropTypes.object.isRequired,
  router: React.PropTypes.func
};
