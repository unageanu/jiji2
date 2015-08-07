import React        from "react"
import Router       from "react-router"
import MUI          from "material-ui"
import AbstractCard from "../widgets/abstract-card"

export default class AccountView extends AbstractCard {

  constructor(props) {
    super(props);
    this.state = {
      formatedBalance: "-",
      formatedChangesFromPreviousDay:  "-",
      formatedChangeratioFromPreviousDay:  "-",
      changesFromPreviousDay : 0
    };
  }

  componentWillMount() {
    const model = this.props.model;
    this.registerPropertyChangeListener(model);
    this.setState({
      formatedBalance: model.formatedBalance,
      formatedChangesFromPreviousDay:  model.formatedChangesFromPreviousDay,
      formatedChangeRatioFromPreviousDay: model.formatedChangeRatioFromPreviousDay,
      changesFromPreviousDay : model.changesFromPreviousDay
    });
  }
  componentWillUnmount() {
    this.props.model.removeAllObservers(this);
  }

  getClassName() {
    return "account-view";
  }
  getTitle() {
    return "口座残高";
  }
  createBody() {
    const icon = this.createIcon();
    return [
      <div key="balance" className="balance">￥{this.state.formatedBalance}</div>,
      <div key="changes-from-previous-day" className="changes-from-previous-day">
        <span className="label">前日比:</span>
        <span className="price">￥{this.state.formatedChangesFromPreviousDay}</span>
        <span className="ratio">({this.state.formatedChangeratioFromPreviousDay})</span>
        {icon}
      </div>
    ];
  }

  createIcon() {
    if (this.state.changesFromPreviousDay == null) {
      return "";
    } else if (this.state.changesFromPreviousDay > 0) {
      return <span className="icon md-trending-up" />;
    } else if (this.state.changesFromPreviousDay < 0) {
      return <span className="icon md-trending-down" />;
    } else if (this.state.changesFromPreviousDay == 0) {
      return <span className="icon md-trending-flat" />;
    }
  }

}
AccountView.contextTypes = {
  application: React.PropTypes.object.isRequired
};
