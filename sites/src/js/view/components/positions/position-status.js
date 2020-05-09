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
      <TextInRadius color={this.color} text={this.props.formattedStatus} />
    );
  }

  get color() {
    if (this.props.status == "live") {
      return Theme.palette.accent4Color;
    } else {
      return Theme.palette.textColor;
    }
  }
}
PositionStatus.propTypes = {
  status:  React.PropTypes.string.isRequired,
  formattedStatus:  React.PropTypes.string.isRequired
};
