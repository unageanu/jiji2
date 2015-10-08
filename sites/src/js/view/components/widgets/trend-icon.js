import React        from "react"
import PriceUtils   from "../../../viewmodel/utils/price-utils"

export default class TrendIcon extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <span className={"icon trend " + this.type } />
    );
  }

  get type() {
    return PriceUtils.resolvePriceClass(this.props.value);
  }
}
TrendIcon.propTypes = {
  value: React.PropTypes.number
};
TrendIcon.defaultProps = {
  value: null
};
