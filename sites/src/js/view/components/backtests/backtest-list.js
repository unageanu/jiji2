import React               from "react"
import Router              from "react-router"
import MUI                 from "material-ui"
import AbstractComponent   from "../widgets/abstract-component"

const List         = MUI.List;
const ListItem     = MUI.ListItem;
const RaisedButton = MUI.RaisedButton;

export default class BacktestList extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      items :    []
    };
  }

  componentWillMount() {
    this.registerPropertyChangeListener(this.props.model);
    this.setState({
      items : this.props.model.items
    });
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
        onTouchTap={tapAction}
        primaryText={backtest.name + " " + backtest.status + " " + (backtest.progress*100)}>
      </ListItem>
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
  selectedId : React.PropTypes.string.isRequired,
  model: React.PropTypes.object.isRequired
};
BacktestList.defaultProps = {
  selectedId : null,
  model: null
};
BacktestList.contextTypes = {
  application: React.PropTypes.object.isRequired,
  router: React.PropTypes.func
};
