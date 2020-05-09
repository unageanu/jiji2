import React             from "react"
import { injectIntl }    from 'react-intl';

import AbstractCard      from "../widgets/abstract-card"
import Chart             from "../chart/chart"
import SettingMenuButton from "../widgets/setting-menu-button"
import NotificationList  from "./notification-list"
import TextInRadius      from "../widgets/text-in-radius"

const keys = new Set([
  "notRead"
]);

class NotificationsCard extends AbstractCard {

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
    const { formatMessage } = this.props.intl;
    return formatMessage({ id: 'notifications.NotificationsCard.title' });
  }
  getIconClass() {
    return "md-notifications";
  }
  getSettingMenuItems() {
    const { formatMessage } = this.props.intl;
    return [formatMessage({ id: 'common.action.reload' })];
  }
  createTitle() {
    const { formatMessage } = this.props.intl;
    const title = this.getTitle();
    const result = [ <span key="title" className="title">{title}</span> ];
    if (this.state.notRead && this.state.notRead > 0) {
      result.push(<TextInRadius key="icon"
        text={formatMessage({ id: 'notifications.NotificationsCard.unread' }) + ":" + this.state.notRead} />);
    }
    return result;
  }

  createBody() {
    return <NotificationList
            selectable={true}
            {...this.props} />;
  }

  onMenuItemTouchTap(e, item) {
    this.props.model.load();
  }

}
NotificationsCard.propTypes = {
  model: React.PropTypes.object.isRequired,
  selectionModel: React.PropTypes.object
};
NotificationsCard.defaultProps = {
  selectionModel: null,
};
export default injectIntl(NotificationsCard);
