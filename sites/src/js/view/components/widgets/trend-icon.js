import React        from "react"

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
    if (this.props.value == null) {
      return "";
    } else if (this.props.value > 0) {
      return "up";
    } else if (this.props.value < 0) {
      return "down";
    } else if (this.props.value == 0) {
      return "flat";
    }
  }
}
TrendIcon.propTypes = {
  value: React.PropTypes.number
};
TrendIcon.defaultProps = {
  value: null
};
