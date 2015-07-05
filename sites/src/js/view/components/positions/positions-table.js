import React               from "react"
import MUI                 from "material-ui"
import PositionDetailsView from "./position-details-view"

const Table        = MUI.Table;
const FlatButton   = MUI.FlatButton;

const defaultSortOrder = {
  order:     "profit_or_loss",
  direction: "desc"
};

const columns = [
  {
    id:"profitOrLoss",
    name:"損益",
    key:"profitOrLoss",
    sort: "profit_or_loss"
  }, {
    id:"pairName",
    name:"通貨ペア",
    key:"pairName",
    sort: "pair_name"
  }, {
    id:"sellOrBuy",
    name:"売/買",
    key:"formatedSellOrBuy",
    sort: "sell_or_buy"
  }, {
    id:"units",
    name:"数量",
    key:"formatedUnits",
    sort: "units"
  }, {
    id:"entryPrice",
    name:"購入価格",
    key:"formatedEntryPrice",
    sort: "entry_price"
  }, {
    id:"exitPrice",
    name:"決済価格",
    key:"formatedExitPrice",
    sort: "exit_price"
  }, {
    id:"enteredAt",
    name:"購入日時",
    key:"formatedEnteredAt",
    sort: "entered_at"
  }, {
    id:"exitedAt",
    name:"決済日時",
    key:"formatedExitedAt",
    sort: "exited_at"
  }
];

export default class PositionsTable extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      hasNext :         false,
      hasPrev :         false,
      items :           [],
      selectedPosition: null,
      sortOrder:        defaultSortOrder
    };
  }

  componentWillMount() {
    const viewModelFactory = this.context.application.viewModelFactory;
    const backtestId = this.props.backtest ? this.props.backtest.id : "rmt";
    this.model = viewModelFactory
      .createPositionsTableModel(backtestId, 50, defaultSortOrder);

    this.model.addObserver("propertyChanged",
      this.onPropertyChanged.bind(this), this);
    this.model.load();
  }
  componentWillUnmount() {
    this.model.removeAllObservers(this);
  }

  render() {
    const headers       = this.createHeaderContent();
    const body          = this.createBodyContent();
    const actionContent = this.createActionContent();
    return (
      <div className="positions-table">
        <PositionDetailsView position={this.state.selectedPosition} />
        <div className="actions">
          {actionContent}
        </div>
        <table>
          <thead>
            <tr>{headers}</tr>
          </thead>
          <tbody>
            {body}
          </tbody>
        </table>
      </div>
    );
  }

  createActionContent() {
    const prev = () => this.model.prev();
    const next = () => this.model.next();
    return [
      <FlatButton
        label="次の50件"
        disabled={!this.state.hasPrev}
        onClick={prev}
      />,
      <FlatButton
        label="前の50件"
        disabled={!this.state.hasNext}
        onClick={next}
      />
    ];
  }

  createHeaderContent() {
    return columns.map((column) => {
      const isCurrentSortKey = this.state.sortOrder.order === column.sort;
      const onClick = (e) => this.onHeaderTapped(e, column);
      const orderMark = isCurrentSortKey
        ? (this.state.sortOrder.direction === "asc" ? "△" : "▽")
        : "";
      return <th
        className={column.id + (isCurrentSortKey ? " sortBy" : "")}
        key={column.id}>
        <FlatButton
          label={column.name + " " + orderMark}
          onClick={onClick}
        />
      </th>;
    });
  }
  createBodyContent() {
    return this.state.items.map((item) => {
      const onClick  = (ev) => this.onItemTapped(ev, item);
      const selected = this.state.selectedPosition
        && item.id === this.state.selectedPosition.id;
      return <tr
          key={item.id}
          className={selected ? "selected" : ""}
          onClick={onClick}>
          {this.createRow(item)}
        </tr>;
    });
  }
  createRow(item) {
    return columns.map((column) => {
      return <td className={column.id} key={column.id}>
              {item[column.key]}
             </td>;
    });
  }

  onPropertyChanged(k, ev) {
    const newState = {};
    newState[ev.key] = ev.newValue;
    this.setState(newState);
  }

  onItemTapped(e, position) {
    this.model.selectedPosition = position;
  }
  onHeaderTapped(e, column) {
    const isCurrentSortKey = this.state.sortOrder.order === column.sort;
    const direction = isCurrentSortKey
      ? (this.state.sortOrder.direction === "asc" ? "desc" : "asc")
      : "asc";
    this.model.sortBy({
      order:     column.sort,
      direction: direction
    });
  }
}
PositionsTable.propTypes = {
  backtest: React.PropTypes.object
};
PositionsTable.defaultProp = {
  backtest: null
};
PositionsTable.contextTypes = {
  application: React.PropTypes.object.isRequired
};
