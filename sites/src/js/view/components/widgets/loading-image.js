import React   from "react"
import MUI     from "material-ui"

const RefreshIndicator = MUI.RefreshIndicator;

export default class LoadingImage extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <span style={{position:"relative"}} >
        <RefreshIndicator
          left={this.props.left}
          top={this.props.top}
          status={this.props.status}
          size={this.props.size}
           />
      </span>
    );
  }
}
LoadingImage.propTypes = {
  status: React.PropTypes.string,
  left: React.PropTypes.number,
  top: React.PropTypes.number,
  size: React.PropTypes.number
};
LoadingImage.defaultProps = {
  status: "loading",
  left: 0,
  top: 0,
  size: 40
};
