import React               from "react"
import MUI                 from "material-ui"
import AbstractComponent   from "../widgets/abstract-component"
import PositionDetailsView from "./position-details-view"
import LoadingImage         from "../widgets/loading-image"

const Table        = MUI.Table;
const FlatButton   = MUI.FlatButton;
const IconButton   = MUI.IconButton;
const FontIcon     = MUI.FontIcon;

const defaultSortOrder = {
  order:     "profit_or_loss",
  direction: "desc"
};

const columns = [
  {
    id:"profitOrLoss",
    name:"損益",
    key:"profitOrLoss",
    sort: "profit_or_loss",
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
    id:"agentName",
    name:"エージェント",
    key:"agentName",
    sort: "agent_name"
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

const keys = new Set([
  "items", "sortOrder", "hasNext", "hasPrev"
]);
const selectionKeys = new Set([
  "selecedId"
]);

export default class PositionsTable extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentWillMount() {
    this.registerPropertyChangeListener(this.props.model, keys);
    this.registerPropertyChangeListener(this.props.selectionModel, selectionKeys);
    const state = Object.assign(
      this.collectInitialState(this.props.model, keys),
      this.collectInitialState(this.props.selectionModel, selectionKeys));
    this.setState(state);
  }

  render() {
    const headers       = this.createHeaderContent();
    const body          = this.createBodyContent();
    const loading       = this.createLoading();
    const actionContent = this.createActionContent();
    return (
      <div className="positions-table">
        <PositionDetailsView position={this.state.selected} />
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
        {loading}
      </div>
    );
  }

  createActionContent() {
    const prev = () => this.props.model.prev();
    const next = () => this.props.model.next();
    return [
      <IconButton
        key="prev"
        tooltip={"前の" + this.props.model.pageSize +  "件"}
        disabled={this.state.loading || !this.state.hasPrev}
        onClick={prev}>
        <FontIcon className="md-navigate-before"/>
      </IconButton>,
      <IconButton
        key="next"
        tooltip={"次の" + this.props.model.pageSize +  "件"}
        disabled={this.state.loading || !this.state.hasNext}
        onClick={next}>
        <FontIcon className="md-navigate-next"/>
      </IconButton>
    ];
  }

  createHeaderContent() {
    return columns.map((column) => {
      const isCurrentSortKey = this.state.sortOrder.order === column.sort;
      const onClick = (e) => this.onHeaderTapped(e, column);
      const orderMark = isCurrentSortKey
        ? (this.state.sortOrder.direction === "asc" ? "▲" : "▼")
        : "";
      return <th
        className={column.id + (isCurrentSortKey ? " sortBy" : "")}
        key={column.id}>
        <a href="javascript:void(0)" alt={column.name} onClick={onClick}>
          {column.name + " " + orderMark}
        </a>
      </th>;
    });
  }

  createBodyContent() {
    if (!this.state.items) return null;
    return this.state.items.map((item) => {
      const onClick  = (ev) => this.onItemTapped(ev, item);
      const selected = this.state.selected
        && item.id === this.state.selectedId;
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

  createLoading() {
    if (this.state.items == null) {
      return <div className="center-information"><LoadingImage /></div>;
    }
    if (this.state.items.length <= 0) {
      return <div className="center-information">建玉はありません</div>;
    }
    return null;
  }

  onItemTapped(ev, position) {
    this.context.router.transitionTo("/positions/"+position.id);
    ev.preventDefault();
  }
  onHeaderTapped(e, column) {
    const isCurrentSortKey = this.state.sortOrder.order === column.sort;
    const direction = isCurrentSortKey
      ? (this.state.sortOrder.direction === "asc" ? "desc" : "asc")
      : "asc";
    this.props.model.sortBy({
      order:     column.sort,
      direction: direction
    });
  }
}
PositionsTable.propTypes = {
  model: React.PropTypes.object
};
PositionsTable.defaultProps = {
  model: null
};
PositionsTable.contextTypes = {
  application: React.PropTypes.object.isRequired
};
