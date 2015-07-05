import React           from "react"

const nullPosition = {
  profitOrLoss : 0,
  formatedProfitOrLoss : "-",
  formatedSellOrBuy: "-",
  formatedUnits: "-",
  formatedEntryPrice: "-",
  formatedExitPrice: "-",
  formatedEnteredAt: "-",
  formatedExitedAt: "-",
  closingPolicy : {
    trailingStop: "-",
    formatedTakeProfit: "-",
    formatedLossCut: "-"
  }
};

export default class PositionDetailsView extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
    };
  }

  render() {
    const position = this.props.position || nullPosition;
    const closingPolicy = position.closingPolicy || nullPosition.closingPolicy;
    return (
      <div className="details">
        <div className="profitOrLoss">
          <span></span>
          <span
            className={"price " + position.profitOrLoss >= 0 ? "up" : "down"}>
            {position.formatedProfitOrLoss}
          </span>
        </div>
        <div className="prices">
          <span>種別: {position.formatedSellOrBuy}</span>
          <span>数量: {position.formatedUnits}</span>
          <span>購入価格: {position.formatedEntryPrice}</span>
          <span>決済価格: {position.formatedExitPrice}</span>
        </div>
        <div className="period">
          <span>期間: {position.formatedEnteredAt}
           ～ {position.formatedExitedAt}
          </span>
        </div>
        <div className="closing-policy">
          <span>トレールストップ: {closingPolicy.trailingStop}pips</span>
          <span>利益確定: {closingPolicy.formatedTakeProfit}</span>
          <span>ロスカット: {closingPolicy.formatedLossCut}</span>
        </div>
      </div>
    );
  }
}
PositionDetailsView.propTypes = {
  position: React.PropTypes.object
};
PositionDetailsView.defaultProp = {
  position: null
};
