import React                from "react"
import { FormattedMessage } from 'react-intl';

import PriceUtils from "../../../viewmodel/utils/price-utils"
import TrendIcon  from "./trend-icon"

export default class PriceView extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    const price = this.props.price || {};
    const className = this.props.color
      ? PriceUtils.resolvePriceClass(price.price)
      : "";
    return <span className={"price-view " + className}>
      { this.props.iconPosition != "right" ? this.createIcon(price) : null}
      {this.createMark()}
      <span className={"price"}>{price.str}</span>
      {this.createUnit(price)}
      { this.props.iconPosition == "right" ? this.createIcon(price) : null}
    </span>;
  }
  createMark() {
    return this.props.showMark ? <span className="mark"><FormattedMessage id='common.currencyUnit'/></span> : null;
  }
  createUnit(price) {
    return price.unit
      ? <span className="unit">{price.unit}</span>
      : null;
  }
  createIcon(price) {
    return this.props.showIcon
      ? <TrendIcon value={price.price} />
      : null;
  }
}
PriceView.propTypes = {
  price: React.PropTypes.object,
  showMark: React.PropTypes.bool,
  showIcon: React.PropTypes.bool,
  color: React.PropTypes.bool,
  iconPosition: React.PropTypes.string
};
PriceView.defaultProps = {
  price: null,
  showMark: true,
  showIcon: false,
  color: false,
  iconPosition: "right"
};
