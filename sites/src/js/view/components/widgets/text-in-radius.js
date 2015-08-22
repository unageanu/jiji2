import React        from "react"
import Theme        from "../../theme"

export default class TextInRadius extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <span className="radius"
        style={{
          borderColor: this.props.color,
          color: this.props.color
        }}>
        {this.props.text}
      </span>
    );
  }
}
TextInRadius.propTypes = {
  text:  React.PropTypes.string.isRequired,
  color: React.PropTypes.string
};
TextInRadius.defaultProps = {
  color: Theme.getPalette().accent4Color
};
