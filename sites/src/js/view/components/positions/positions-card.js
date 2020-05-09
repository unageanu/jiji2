import React          from "react"
import { injectIntl } from 'react-intl';

import AbstractCard      from "../widgets/abstract-card"
import Chart             from "../chart/chart"
import SettingMenuButton from "../widgets/setting-menu-button"
import PositionList      from "./position-list"
import TextInRadius      from "../widgets/text-in-radius"

const keys = new Set([
  "notExited"
]);

class PositionsCard extends AbstractCard {

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
    const { formatMessage } = this.props.intl;
    return  formatMessage({id:'positions.PositionsCard.title'});
  }
  getIconClass() {
    return "md-list";
  }
  getSettingMenuItems() {
    const { formatMessage } = this.props.intl;
    return [formatMessage({id:'common.action.reload'})];
  }
  createTitle() {
    const { formatMessage } = this.props.intl;
    const title = this.getTitle();
    const result = [ <span key="title" className="title">{title}</span> ];
    if (this.state.notExited && this.state.notExited > 0) {
      result.push(<TextInRadius key="icon"
        text={formatMessage({id:'positions.PositionsCard.notClosed'}) + ":" + this.state.notExited} />);
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

export default injectIntl(PositionsCard)
