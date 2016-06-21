import React        from "react"
import MUI          from "material-ui"
import Theme        from "../../theme"
import MenuItem     from 'material-ui/MenuItem'

const IconButton = MUI.IconButton;
const IconMenu   = MUI.IconMenu;

export default class SettingMenuButton extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    const iconButtonElement = <IconButton
        iconClassName="md-more-vert"
        iconStyle={{color:Theme.getPalette().textColorLight}}
      />;
    const menu = this.createMenuItems();
    return (
      <IconMenu
        iconButtonElement={iconButtonElement}
        {...this.props}>
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
