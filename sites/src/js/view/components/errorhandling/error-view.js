import React             from "react";
import MUI               from "material-ui"
import AbstractComponent from "../widgets/abstract-component";

const Snackbar = MUI.Snackbar;

export default class ErrorView extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      message : ""
    };
  }

  componentWillMount() {
    this.errorQueue().addObserver("pushed", () => this.processErrorEvents());
  }
  componentWillUnmount() {
    this.errorQueue().removeAllObservers(this);
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
    let errorEvent = this.errorQueue().shift();
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

  errorQueue() {
    return this.context.application.errorEventQueue;
  }
}
ErrorView.contextTypes = {
  application: React.PropTypes.object.isRequired,
  router: React.PropTypes.func
};
