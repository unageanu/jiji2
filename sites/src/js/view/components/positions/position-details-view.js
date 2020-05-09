import React                            from "react"
import { injectIntl, FormattedMessage } from 'react-intl';

import AbstractComponent    from "../widgets/abstract-component"
import PriceUtils           from "../../../viewmodel/utils/price-utils"
import LoadingImage         from "../widgets/loading-image"
import PositionStatus       from "./position-status"

import Avatar from "material-ui/Avatar"

const nullPosition = {
  profitOrLoss : 0,
  formattedProfitOrLoss : "-",
  formattedSellOrBuy: "-",
  formattedUnits: "-",
  formattedEntryPrice: "-",
  formattedExitPrice: "-",
  formattedEnteredAt: "-",
  formattedExitedAt: "-",
  closingPolicy : {
    trailingStop: "-",
    formattedTakeProfit: "-",
    formattedLossCut: "-"
  }
};

const keys = new Set([
  "selectedId", "selected"
]);

class PositionDetailsView extends AbstractComponent {

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
    const { formatMessage } = this.props.intl;
    const closingPolicy = position.closingPolicy || nullPosition.closingPolicy;
    return (
      <div className="position-details">
        <div className="profit-or-loss">
          {this.createAvatar(position)}
          <span
            className={"price " + PriceUtils.resolvePriceClass(position.profitOrLoss)}>
            ¥ {(position.profitOrLoss > 0 ? "+" : "") + position.formattedProfitOrLoss}
          </span>
        </div>
        <div className="informations">
          <div className="category first">
            <span className="item">
              <span className="label"><FormattedMessage id='positions.PositionDetailsView.status'/>:</span>
              <span className="value">
                <PositionStatus
                  formattedStatus={formatMessage({id: position.formattedStatus})}
                  status={position.status} />
              </span>
            </span>
            <span className="item">
              <span className="label"><FormattedMessage id='positions.PositionDetailsView.type'/>:</span>
              <span className="value"><FormattedMessage id={position.formattedSellOrBuy} /></span>
            </span>
            <span className="item">
              <span className="label"><FormattedMessage id='positions.PositionDetailsView.volume'/>:</span>
              <span className="value">{position.formattedUnits}</span>
            </span>
            <span className="item">
              <span className="label"><FormattedMessage id='positions.PositionDetailsView.pair'/>:</span>
              <span className="value">{position.pairName}</span>
            </span>
          </div>
          <div className="category">
            <span className="item">
              <span className="label"><FormattedMessage id='positions.PositionDetailsView.price'/>:</span>
              <span className="value">{position.formattedEntryPrice}</span>
            </span>
            <span className="item">
              <span className="label"><FormattedMessage id='positions.PositionDetailsView.closePrice'/>:</span>
              <span className="value">{position.formattedExitPrice}</span>
            </span>
            <span className="item">
              <span className="label"><FormattedMessage id='positions.PositionDetailsView.enteredAt'/>:</span>
              <span className="value">
                {position.formattedEnteredAt || "-"}
              </span>
            </span>
            <span className="item">
              <span className="label"><FormattedMessage id='positions.PositionDetailsView.exitedAt'/>:</span>
              <span className="value">
                {position.formattedExitedAt || "-"}
              </span>
            </span>
            <span className="item">
              <span className="label"><FormattedMessage id='positions.PositionDetailsView.agent'/>:</span>
              <span className="value">
                {position.agentName}
              </span>
            </span>
          </div>
          <div className="closing-policy category">
            <span className="item">
              <span className="label"><FormattedMessage id='positions.PositionDetailsView.trailStop'/>:</span>
              <span className="value">
                {closingPolicy.trailingStop}pips
              </span>
            </span>
            <span className="item">
              <span className="label"><FormattedMessage id='positions.PositionDetailsView.takeProfit'/>:</span>
              <span className="value">
                {closingPolicy.formattedTakeProfit}
              </span>
            </span>
            <span className="item">
              <span className="label"><FormattedMessage id='positions.PositionDetailsView.lossCut'/>:</span>
              <span className="value">
                {closingPolicy.formattedLossCut}
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
export default  injectIntl(PositionDetailsView);
