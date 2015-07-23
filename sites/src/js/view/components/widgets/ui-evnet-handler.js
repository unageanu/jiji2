import React             from "react";
import MUI               from "material-ui"
import AbstractComponent from "../widgets/abstract-component";

const Snackbar = MUI.Snackbar;

export default class UIEventHandler extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      message : ""
    };
  }

  componentWillMount() {
    this.eventQueue().addObserver("pushed", () => this.processErrorEvents());
  }
  componentWillUnmount() {
    this.eventQueue().removeAllObservers(this);
  }

  render() {
    return <Snackbar
      ref="message-bar"
      message={this.state.message}
      action="閉じる"
      autoHideDuration={3000}
      onActionTouchTap={this.onActionTouchTap.bind(this)}/>;
  }

  onActionTouchTap(ev) {
    this.refs["message-bar"].dismiss();
    this.setState({message: ""});
    this.processErrorEvents();
  }

  processErrorEvents() {
    if (this.refs["message-bar"].state.open) return;
    let errorEvent = this.eventQueue().shift();
    if (errorEvent) {
      this.processError(errorEvent);
    }
  }
  processError(errorEvent) {
    if (errorEvent.message) {
      this.setState({message: errorEvent.message});
      this.refs["message-bar"].show();
    } else if (errorEvent.route) {
      this.context.router.transitionTo(errorEvent.route);
    }
  }

  eventQueue() {
    return this.context.application.eventQueue;
  }
}
UIEventHandler.contextTypes = {
  application: React.PropTypes.object.isRequired,
  router: React.PropTypes.func
};
