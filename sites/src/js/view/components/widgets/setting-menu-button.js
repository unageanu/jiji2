import React        from "react"

import Theme        from "../../theme"
import MenuItem     from 'material-ui/MenuItem'

import IconButton from "material-ui/IconButton"
import IconMenu   from "material-ui/IconMenu"

export default class SettingMenuButton extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    const iconButtonElement = <IconButton
        iconClassName="md-more-vert"
        iconStyle={{color:Theme.palette.textColorLight}}
      />;
    const menu = this.createMenuItems();
    const { menuItems, ...others } = this.props;
    return (
      <IconMenu
        iconButtonElement={iconButtonElement}
        {...others}>
        {menu}
      </IconMenu>
    );
  }

  createMenuItems() {
    return this.props.menuItems.map(
      (menuItem) => <MenuItem key={menuItem} primaryText={menuItem} /> );
  }
}
SettingMenuButton.propTypes = {
  menuItems: React.PropTypes.array
};
SettingMenuButton.defaultProps = {
  menuItems: []
};
