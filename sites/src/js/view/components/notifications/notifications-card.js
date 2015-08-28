import React             from "react"
import MUI               from "material-ui"
import AbstractCard      from "../widgets/abstract-card"
import Chart             from "../chart/chart"
import SettingMenuButton from "../widgets/setting-menu-button"
import NotificationList  from "./notification-list"
import TextInRadius      from "../widgets/text-in-radius"

const keys = new Set([
  "notRead"
]);

export default class NotificationsCard extends AbstractCard {

  constructor(props) {
    super(props);
    this.state = {
    };
  }

  componentWillMount() {
    this.registerPropertyChangeListener(this.props.model, keys);
    const state = this.collectInitialState(this.props.model, keys);
    this.setState(state);
  }

  getClassName() {
    return "notifications-card";
  }
  getTitle() {
    return "未読の通知";
  }
  getIconClass() {
    return "md-notifications";
  }
  getSettingMenuItems() {
    return ["更新"];
  }
  createTitle() {
    const title = this.getTitle();
    const result = [ <span key="title" className="title">{title}</span> ];
    if (this.state.notRead && this.state.notRead > 0) {
      result.push(<TextInRadius key="icon"
        text={"未読:" + this.state.notRead} />);
    }
    return result;
  }

  createBody() {
    return <NotificationList
            selectable={false}
            {...this.props} />;
  }

  onMenuItemTouchTap(e, item) {
    this.props.model.load();
  }

}
NotificationsCard.propTypes = {
  model: React.PropTypes.object.isRequired,
  innerDivStyle: React.PropTypes.object
};
