import React          from "react"
import { injectIntl } from 'react-intl';


import AbstractComponent    from "../widgets/abstract-component"
import LoadingImage         from "../widgets/loading-image"
import ChartView            from "../chart/chart-view"

import Avatar from "material-ui/Avatar"
import RaisedButton from "material-ui/RaisedButton"

const keys = new Set([
  "selectedId", "selected"
]);

class NotificationDetailsView extends AbstractComponent {

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
    const notification   = this.state.selected;
    const notificationId = this.state.selectedId;

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
    return <div className="center-information"><LoadingImage /></div>;
  }
  createDetailsView(notification) {
    const { formatMessage } = this.props.intl;
    return <div className="notification-details">
      <div className="top-panel">
        <div className="avatar-panel">
          {this.createAvatar(notification)}
        </div>
        <div className="content-panel">
          <div className="message">
            {notification.message}
          </div>
          <div className="agent-name">
            {notification.getAgentAndBacktestName(formatMessage)}
          </div>
          <div className="timestamp">
            {notification.formattedTimestamp}
          </div>
        </div>
      </div>
      <div className="note">
        <pre>
        {notification.note}
        </pre>
      </div>
      {this.createChart(notification)}
      <div className="action-buttons">
        {this.createActionButtons(notification)}
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
  createChart(notification) {
    if (!notification.isDisplayChart) return null;
    return <div className="chart">
      <ChartView
        model={this.props.chartModel}
        size={this.calculateChartSize()}
        enableSlider={false} />
    </div>
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
  calculateChartSize() {
    const windowSize = this.context.windowResizeManager.windowSize;
    return {
      w: windowSize.w - this.props.outerWidth,
      h: 200,
      profitAreaHeight: 80
    };
  }
}
NotificationDetailsView.propTypes = {
  model: React.PropTypes.object.isRequired,
  chartModel: React.PropTypes.object.isRequired,
  outerWidth: React.PropTypes.number
};
NotificationDetailsView.defaultProps = {
  outerWidth: 288 + 440 + 16*7
};
NotificationDetailsView.contextTypes = {
  windowResizeManager: React.PropTypes.object.isRequired
};
export default injectIntl(NotificationDetailsView);
