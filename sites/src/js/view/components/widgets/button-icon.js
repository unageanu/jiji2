import React   from "react"
import MUI     from "material-ui"

const FontIcon = MUI.FontIcon;

const iconStyle = {
  height: '100%',
  display: 'inline-block',
  verticalAlign: 'middle',
  float: 'left',
  paddingLeft: '12px',
  lineHeight: '36px'
};

export default class ButtonIcon extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <FontIcon style={
        Object.assign(this.props.style, iconStyle)
      } className={this.props.className}/>
    );
  }
}
ButtonIcon.propTypes = {
  style: React.PropTypes.object,
  className: React.PropTypes.string.isRequired
};
ButtonIcon.defaultProps = {
  style: {}
};
