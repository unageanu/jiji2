import React              from "react"
import Router             from "react-router"
import MUI                from "material-ui"
import AbstractComponent  from "../widgets/abstract-component"
import Theme              from "../../theme"
import SettingMenuButton  from "../widgets/setting-menu-button"

const Card       = MUI.Card;
const CardTitle  = MUI.CardTitle;
const CardText   = MUI.CardText;

export default class AbstractCard extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <Card initiallyExpanded={true}
        className={"card " + this.getClassName()} >
        {this.createHeader()}
        {this.createBody()}
      </Card>
    );
  }

  getClassName() {
    return "";
  }
  getTitle() {
    return "";
  }
  getSettingMenuItems() {
    return [];
  }

  createHeader() {
    const title = this.createTitle();
    const settingMenu = this.createSettingMenu();
    if (!title && !settingMenu) return null;

    return <div className="header">
        {title}
        {settingMenu}
      </div>;
  }

  createTitle() {
    const title = this.getTitle();
    if (!title) return null;
    return <span className="title">{title}</span>;
  }

  createSettingMenu(paddingTop="") {
    const items = this.getSettingMenuItems();
    if (!items || items.length == 0) return null;
    return <SettingMenuButton
      className="setting-menu"
      menuItems={items}
      style={{float:"right", "paddingTop":paddingTop}}
      onItemTouchTap={this.onMenuItemTouchTap.bind(this)} />
  }

  createBody() {
    return "";
  }
  onMenuItemTouchTap(ev, item) {}
}
