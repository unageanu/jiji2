import React                from "react"
import MUI                  from "material-ui"
import AbstractComponent    from "../widgets/abstract-component"
import PriceUtils           from "../../../viewmodel/utils/price-utils"
import LoadingImage         from "../widgets/loading-image"
import PositionStatus       from "./position-status"

const Avatar = MUI.Avatar;

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

const keys = new Set([
  "selectedId", "selected"
]);

export default class PositionDetailsView extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
    };
  }

  componentWillMount() {
    this.registerPropertyChangeListener(this.props.model, keys);
    const state = this.collectInitialState(this.props.model, keys);
    this.setState(state);
  }

  render() {
    const position   = this.state.selected;
    const positionId = this.state.selectedId;

    if ( positionId == null ) {
      return null;
    } else if ( position == null ) {
      return this.createLoadingView();
    } else {
      return this.createDetailsView( position || nullPosition );
    }
  }

  createLoadingView() {
    return <div className="center-information"><LoadingImage /></div>;
  }
  createDetailsView( position ) {
    const closingPolicy = position.closingPolicy || nullPosition.closingPolicy;
    return (
      <div className="position-details">
        <div className="profit-or-loss">
          {this.createAvatar(position)}
          <span
            className={"price " + PriceUtils.resolvePriceClass(position.profitOrLoss)}>
            ¥ {(position.profitOrLoss > 0 ? "+" : "") + position.formatedProfitOrLoss}
          </span>
        </div>
        <div className="informations">
          <div className="category first">
            <span className="item">
              <span className="label">状態:</span>
              <span className="value">
                <PositionStatus status={position.formatedStatus}/>
              </span>
            </span>
            <span className="item">
              <span className="label">種別:</span>
              <span className="value">{position.formatedSellOrBuy}</span>
            </span>
            <span className="item">
              <span className="label">数量:</span>
              <span className="value">{position.formatedUnits}</span>
            </span>
            <span className="item">
              <span className="label">通貨ペア:</span>
              <span className="value">{position.pairName}</span>
            </span>
          </div>
          <div className="category">
            <span className="item">
              <span className="label">購入価格:</span>
              <span className="value">{position.formatedEntryPrice}</span>
            </span>
            <span className="item">
              <span className="label">決済価格:</span>
              <span className="value">{position.formatedExitPrice}</span>
            </span>
            <span className="item">
              <span className="label">購入日時:</span>
              <span className="value">
                {position.formatedEnteredAt || "-"}
              </span>
            </span>
            <span className="item">
              <span className="label">決済日時:</span>
              <span className="value">
                {position.formatedExitedAt || "-"}
              </span>
            </span>
            <span className="item">
              <span className="label">エージェント:</span>
              <span className="value">
                {position.agentName}
              </span>
            </span>
          </div>
          <div className="closing-policy category">
            <span className="item">
              <span className="label">トレールストップ:</span>
              <span className="value">
                {closingPolicy.trailingStop}pips
              </span>
            </span>
            <span className="item">
              <span className="label">利益確定:</span>
              <span className="value">
                {closingPolicy.formatedTakeProfit}
              </span>
            </span>
            <span className="item">
              <span className="label">ロスカット:</span>
              <span className="value">
                {closingPolicy.formatedLossCut}
              </span>
            </span>
          </div>
        </div>
      </div>
    );
  }
  createAvatar(position) {
    return <Avatar className="left-icon" src={position.agentIconUrl} />
  }
}
PositionDetailsView.propTypes = {
  position: React.PropTypes.object
};
PositionDetailsView.defaultProps = {
  position: null
};
