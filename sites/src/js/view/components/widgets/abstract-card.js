import React              from "react"
import Router             from "react-router"

import AbstractComponent  from "../widgets/abstract-component"
import Theme              from "../../theme"
import SettingMenuButton  from "../widgets/setting-menu-button"

import {Card, CardTitle, CardText} from "material-ui/Card"

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
  getIconClass() {
    return "";
  }
  getSettingMenuItems() {
    return [];
  }

  createHeader() {
    const title = this.createTitle();
    const settingMenu = this.createSettingMenu();
    const titleIcon = this.createTitleIcon();
    if (!title && !settingMenu && !titleIcon) return null;

    return <div className="header">
        {titleIcon}
        {title}
        {settingMenu}
      </div>;
  }

  createTitle() {
    const title = this.getTitle();
    if (!title) return null;
    return <span className="title">{title}</span>;
  }
  createTitleIcon() {
    const iconClass = this.getIconClass();
    if (!iconClass) return null;
    return <span className={"icon " + iconClass}></span>;
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
