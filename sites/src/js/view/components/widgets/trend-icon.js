import React        from "react"
import ViewUtils    from "../../utils/view-utils"

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
    return ViewUtils.resolvePriceClass(this.props.value);
  }
}
TrendIcon.propTypes = {
  value: React.PropTypes.number
};
TrendIcon.defaultProps = {
  value: null
};
