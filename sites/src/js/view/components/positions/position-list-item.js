import React               from "react"
import MUI                 from "material-ui"
import AbstractComponent   from "../widgets/abstract-component"
import PositionStatus      from "./position-status"

const ListItem   = MUI.ListItem;
const Avatar     = MUI.Avatar;

const nullPosition = {};

export default class PositionListItem extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    const position = this.props.position || nullPosition;
    const props = {
      className: "list-item",
      innerDivStyle : Object.assign({
        paddingRight:"72px",
        backgroundColor: this.props.selected
          ? Theme.getPalette().backgroundColorDarkAlpha : "rgba(0,0,0,0)"
      }, this.props.innerDivStyle),
      leftAvatar: this.createAvatar(position),
      primaryText: this.createPrimaryText(position),
      secondaryText: this.createSecondaryText(position),
      onTouchTap: this.props.onTouchTap,
      rightIcon: this.createRightIcon(position)
    };
    return this.props.mobile
      ? <MobileListItem {...props} />
      : <ListItem {...props} />;
  }

  createPrimaryText(position) {
    return <span className="primary-text">
      <span key="pair" className="pair">{position.pairName}</span>
      <span key="separator" className="separator">/</span>
      <span key="sell-or-buy" className="sell-or-buy">{position.formatedSellOrBuy}</span>
      {this.createProfitOrLossElement(position)}
    </span>;
  }
  createProfitOrLossElement(position) {
    const type = this.resolveProfitOrLossClass(position.profitOrLoss);
    return <span key="profitOrLoss" className={"profit-or-loss " + type}>
      ￥{type == "up" ? "+" : ""}{position.formatedProfitOrLoss}
    </span>;
  }
  resolveProfitOrLossClass(profitOrLoss) {
    if (profitOrLoss == 0) {
      return "flat";
    } else if (profitOrLoss > 0) {
      return "up";
    } else if (profitOrLoss < 0) {
      return "down";
    }
  }
  createSecondaryText(position) {
    let time = "";
    if ( position.formatedEnteredAt != null ) {
      time += position.formatedEnteredAt + " - ";
    }
    if ( position.formatedExitedAt != null ) {
      time += position.formatedExitedAtShort;
    }
    return [
      <span key="units" className="units">{position.units}</span>,
      <span key="units-suffix" className="suffix">単位</span>,
      <span key="separator" className="separator">/</span>,
      <span key="time" className="time">{time}</span>
    ];
  }
  createRightIcon(position) {
      if (position.status != "live") return null;
      return <span className="right-icon" style={{width:"auto"}}>
        <PositionStatus status={position.formatedStatus} />
      </span>;
  }
  createAvatar(position) {
    return <Avatar className="left-icon" src={position.agentIconUrl} />
  }
}
PositionListItem.propTypes = {
  position: React.PropTypes.object,
  selected: React.PropTypes.bool,
  innerDivStyle: React.PropTypes.object
};
PositionListItem.defaultProps = {
  position: null,
  selected: false,
  innerDivStyle: {}
};
