import React  from "react"
import MUI    from "material-ui"

const Table        = MUI.Table;
const RaisedButton = MUI.RaisedButton;

const defaultSortOrder = {
  order:     "profit_or_loss",
  direction: "desc"
};

const columnOrder = [
  "profitOrLoss", "pairName", "sellOrBuy", "entryPrice",
  "exitPrice", "enteredAt", "exitedAt"
];
const columns = {
  profitOrLoss: {
    content: "損益",
    tooltip: "決済済みの場合は決済時の損益、決済されていない場合は現在の損益になります"
  },
  pairName: {
    content: "通貨ペア",
    tooltip: "通貨ペアです"
  },
  sellOrBuy: {
    content: "売/買",
    tooltip: "売り買いの種別です"
  },
  entryPrice: {
    content: "購入価格",
    tooltip: "取引を行って建玉を作成したときの購入価格です"
  },
  exitPrice: {
    content: "決済価格",
    tooltip: "建玉を決裁したときの価格です"
  },
  enteredAt: {
    content: "購入日時",
    tooltip: "購入日時です"
  },
  exitedAt: {
    content: "決済日時",
    tooltip: "決済日時です"
  }
};

export default class PositionsTable extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      hasNext : false,
      hasPrev : false,
      items :    []
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
    return (
      <div className="positions-table">
        <Table
          headerColumns={columns}
          columnOrder={columnOrder}
          rowData={this.state.items}
          height={500}
          fixedHeader={true}
          stripedRows={false}
          showRowHover={true}
          selectable={false}
          multiSelectable={false}
          displaySelectAll={false}
          canSelectAll={false}
          showRowSelectCheckbox={false}
        />
      </div>
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
