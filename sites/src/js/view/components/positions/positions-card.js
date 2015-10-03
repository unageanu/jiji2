import React             from "react"
import MUI               from "material-ui"
import AbstractCard      from "../widgets/abstract-card"
import Chart             from "../chart/chart"
import SettingMenuButton from "../widgets/setting-menu-button"
import PositionList      from "./position-list"
import TextInRadius      from "../widgets/text-in-radius"

const keys = new Set([
  "notExited"
]);

export default class PositionsCard extends AbstractCard {

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
    return "positions-card";
  }
  getTitle() {
    return "建玉";
  }
  getIconClass() {
    return "md-list";
  }
  getSettingMenuItems() {
    return ["更新"];
  }
  createTitle() {
    const title = this.getTitle();
    const result = [ <span key="title" className="title">{title}</span> ];
    if (this.state.notExited && this.state.notExited > 0) {
      result.push(<TextInRadius key="icon"
        text={"未決済:" + this.state.notExited} />);
    }
    return result;
  }

  createBody() {
    return <PositionList
            selectable={false}
            {...this.props} />;
  }

  onMenuItemTouchTap(e, item) {
    this.props.model.load();
  }

}
PositionsCard.propTypes = {
  model: React.PropTypes.object.isRequired
};
