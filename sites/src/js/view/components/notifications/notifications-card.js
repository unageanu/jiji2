import React             from "react"
import MUI               from "material-ui"
import AbstractCard      from "../widgets/abstract-card"
import Chart             from "../chart/chart"
import SettingMenuButton from "../widgets/setting-menu-button"
import NotificationList  from "./notification-list"

export default class NotificationsCard extends AbstractCard {

  constructor(props) {
    super(props);
    this.state = {
    };
  }

  getClassName() {
    return "notifications-card";
  }
  getTitle() {
    return "通知";
  }
  getSettingMenuItems() {
    return ["更新"];
  }
  createBody() {
    return <NotificationList
            selectable={false}
            {...this.props} />;
  }

  onMenuItemTouchTap(e, item) {
    this.props.model.reload();
  }

}
NotificationsCard.propTypes = {
  model: React.PropTypes.object.isRequired
};
