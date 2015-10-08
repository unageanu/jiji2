import React        from "react"
import TextInRadius from "../widgets/text-in-radius"
import Theme        from "../../theme"

export default class PositionStatus extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <TextInRadius color={this.color} text={this.props.status} />
    );
  }

  get color() {
    if (this.props.status == "未決済") {
      return Theme.getPalette().accent4Color;
    } else {
      return Theme.getPalette().textColor;
    }
  }
}
PositionStatus.propTypes = {
  status:  React.PropTypes.string.isRequired
};
