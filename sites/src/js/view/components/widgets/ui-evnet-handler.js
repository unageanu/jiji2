import React             from "react"

import AbstractComponent from "../widgets/abstract-component"
import Theme             from "../../theme"

import Snackbar from "material-ui/Snackbar"
import Avatar from "material-ui/Avatar"

export default class UIEventHandler extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      event: null
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
      message={message}
      action={action}
      autoHideDuration={autoHideDuration}
      onActionTouchTap={this.onActionTouchTap.bind(this)}
      onDismiss={this.onDismiss.bind(this)} />;
  }

  onActionTouchTap(ev) {
    if ( this.state.event.type == "notificationReceived" ) {
      this.context.router.push({
        pathname: "/notifications/"+ this.state.event.data.additionalData.notificationId
      });
    }
    this.refs["message-bar"].dismiss();
  }

  onDismiss(ev) {
    this.setState({message: "", action: ""});
    setTimeout(() => this.processEventIfExist(), 500);
  }

  processEventIfExist() {
    if (this.refs["message-bar"].state.open) return;
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
    this.setState({event: event});
    this.refs["message-bar"].show();
  }
  processRoutingEvent(event) {
    this.context.routerpush({
      pathname:event.route
    });
  }

  createMessage(event) {
    if (!event) return { message:"", action: ""};
    switch (event.type) {
      case "error" :
      case "info" :
        return {
          message: event.message,
          action:  "閉じる",
          autoHideDuration: 3000
        };
      case "notificationReceived" :
        return {
          message: this.createNotificationContent(event.data),
          action:  "開く",
          autoHideDuration: null
        };
    }
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
