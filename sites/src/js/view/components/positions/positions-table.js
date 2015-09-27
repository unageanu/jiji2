import React               from "react"
import MUI                 from "material-ui"
import AbstractComponent   from "../widgets/abstract-component"
import LoadingImage        from "../widgets/loading-image"
import ViewUtils           from "../../utils/view-utils"

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
    key:"formatedProfitOrLoss",
    sort: "profit_or_loss",
    formatter(value, item) {
      const className = ViewUtils.resolvePriceClass(item.profitOrLoss);
      const profitOrLoss =
        (item.profitOrLoss > 0 ? "+" : "") + item.formatedProfitOrLoss;
      return <span className={className}>{profitOrLoss}</span>;
    }
  }, {
    id:"status",
    name:"状態",
    key:"formatedStatus",
    sort: "status",
    formatter(value, item) {
      if (item.status == "live" ) {
         return <span className="live">{item.formatedStatus}</span>;
      } else {
        return item.formatedStatus;
      }
    }
  },{
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
    sort: "entered_at",
    formatter(value, item) {
      return value || "-";
    }
  }, {
    id:"exitedAt",
    name:"決済日時",
    key:"formatedExitedAt",
    sort: "exited_at",
    formatter(value, item) {
      return value || "-";
    }
  }, {
    id:"agentName",
    name:"エージェント",
    key:"agentName",
    sort: "agent_name"
  }
];

const keys = new Set([
  "items", "sortOrder", "hasNext", "hasPrev"
]);
const selectionKeys = new Set([
  "selectedId"
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
        <a alt={column.name} onClick={onClick}>
          {column.name + " " + orderMark}
        </a>
      </th>;
    });
  }

  createBodyContent() {
    if (!this.state.items) return null;
    return this.state.items.map((item) => {
      const onClick  = (ev) => this.onItemTapped(ev, item);
      const selected = item.id === this.state.selectedId;
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
      let content = item[column.key];
      if (column.formatter) content = column.formatter(content, item);
      return <td className={column.id} key={column.id}>
              {content}
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
    this.context.router.transitionTo("/rmt/positions/"+position.id);
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
  router: React.PropTypes.func,
  windowResizeManager: React.PropTypes.object
};
