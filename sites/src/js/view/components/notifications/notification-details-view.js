import React                from "react"
import MUI                  from "material-ui"
import AbstractComponent    from "../widgets/abstract-component"
import LoadingImage         from "../widgets/loading-image"

const Avatar       = MUI.Avatar;
const RaisedButton   = MUI.RaisedButton;

const keys = new Set([
  "selectedNotificationId", "selectedNotification"
]);

export default class NotificationDetailsView extends AbstractComponent {

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

  render() {
    const notification   = this.state.selectedNotification;
    const notificationId = this.state.selectedNotificationId;

    if ( notificationId == null ) {
      return this.createEmptyView();
    } else if ( notification == null ) {
      return this.createLoadingView();
    } else {
      return this.createDetailsView( notification );
    }
  }

  createEmptyView() {
    return null;
  }
  createLoadingView() {
    return <div className="info"><LoadingImage /></div>;
  }
  createDetailsView(notification) {
    return <div className="details">
      <div className="avatar-panel">
        {this.createAvatar(notification)}
      </div>
      <div className="content-panel">
        <div className="message">
          {notification.message}
        </div>
        <div className="agent-name">
          {notification.agentAndBacktestName}
        </div>
        <div className="timestamp">
          {notification.formatedTimestamp}
        </div>
        <div className="action-buttons">
          {this.createActionButtons(notification)}
        </div>
      </div>
    </div>;
  }
  createAvatar(notification) {
    return <Avatar className="left-icon" src={notification.agentIconUrl} />
  }
  createActionButtons(notification) {
    return (notification.actions || []).map(
      (action, index)=> this.createActionButton(notification, action, index));
  }

  createActionButton(item, action, index) {
    const execute = () => this.props.model.executeAction(item, action.action);
    return <div key={index} className="action-button">
      <RaisedButton
        label={action.label}
        onClick={execute}
      />
    </div>;
  }
}
NotificationDetailsView.propTypes = {
  model: React.PropTypes.object.isRequired
};
