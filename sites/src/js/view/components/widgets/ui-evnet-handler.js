import React             from "react"
import { injectIntl }    from 'react-intl';

import AbstractComponent from "../widgets/abstract-component"
import Theme             from "../../theme"
import ErrorMessages from "../../../errorhandling/error-messages"

import Snackbar from "material-ui/Snackbar"
import Avatar from "material-ui/Avatar"

class UIEventHandler extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      event: null,
      open: false
    };
  }

  componentWillMount() {
    this.eventQueue().addObserver("pushed", () => this.processEventIfExist());
  }
  componentWillUnmount() {
    this.eventQueue().removeAllObservers(this);
  }

  render() {
    const {message, action, autoHideDuration}
      = this.createMessage(this.state.event);
    return <Snackbar
      className="snackbar"
      ref="message-bar"
      style={Theme.snackbar}
      open={this.state.open}
      message={message}
      action={action}
      autoHideDuration={autoHideDuration}
      onActionTouchTap={this.onActionTouchTap.bind(this)}
      onRequestClose={this.onRequestClose.bind(this)} />;
  }

  onActionTouchTap(ev) {
    if ( this.state.event.type == "notificationReceived" ) {
      const notificationId = this.state.event.data.additionalData.notificationId;
      this.context.router.push({pathname: "/notifications/"+ notificationId});
    }
    this.onRequestClose(ev);
  }

  onRequestClose(ev) {
    this.setState({event:null, open:false});
    setTimeout(() => this.processEventIfExist(), 500);
  }

  processEventIfExist() {
    if (this.state.open) return;
    let event = this.eventQueue().shift();
    if (event) {
      this.processEvent(event);
    }
  }
  processEvent(event) {
    switch (event.type) {
      case "error" :
      case "info" :
      case "notificationReceived" :
        this.processMessageEvent(event); return;
      case "routing":
        this.processRoutingEvent(event); return;
    }
  }
  processMessageEvent(event) {
    this.setState({event: event, open:true});
  }
  processRoutingEvent(event) {
    this.context.router.push({
      pathname:event.route
    });
  }

  createMessage(event) {
    const emptyMessage = { message:"", action: ""};
    if (!event) return emptyMessage;
    const { formatMessage } = this.props.intl;
    switch (event.type) {
      case "error" :
      case "info" :
        const message = this.detectMessage(event, formatMessage);
        if (message == null) return emptyMessage;
        return {
          message: message,
          action:  formatMessage({id:'widgets.UIEventHandler.close'}),
          autoHideDuration: 3000
        };
      case "notificationReceived" :
        return {
          message: this.createNotificationContent(event.data),
          action:  formatMessage({id:'widgets.UIEventHandler.open'}),
          autoHideDuration: null
        };
    }
  }

  detectMessage(event, formatMessage) {
    if (event.message) return event.message;
    if (event.error && event.error.message) return event.error.message
    if (event.error) return ErrorMessages.getMessageFor(formatMessage, event.error);
    return null;
  }

  createNotificationContent(data) {
    return <span className="notification">
        <Avatar className="left-icon" src={data.image} />
        <span className="content">
          <span className="title">{data.title}</span><br/>
          <span className="message">{data.message}</span>
        </span>
      </span>;
  }

  eventQueue() {
    return this.context.application.eventQueue;
  }
}
UIEventHandler.contextTypes = {
  application: React.PropTypes.object.isRequired,
  router: React.PropTypes.object
};
export default injectIntl(UIEventHandler)
