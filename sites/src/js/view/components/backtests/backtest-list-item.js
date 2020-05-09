import React               from "react"

import AbstractComponent   from "../widgets/abstract-component"
import TextInRadius        from "../widgets/text-in-radius"
import Theme               from "../../theme"
import Environment         from "../../environment"
import NumberFormatter     from "../../../viewmodel/utils/number-formatter"
import DateFormatter       from "../../../viewmodel/utils/date-formatter"
import Utils               from "./utils"

import {ListItem} from "material-ui/List"
import LinearProgress from "material-ui/LinearProgress"

const nullBacktest = {};

export default class BacktestListItem extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    const backtest = this.props.backtest || nullBacktest;
    const props = {
      className: "list-item",
      innerDivStyle : Object.assign( {}, Theme.listItem.innerDivStyle, {
        backgroundColor: this.props.selected
          ? Theme.palette.backgroundColorDarkAlpha : "rgba(0,0,0,0)"
      }),
      primaryText: this.createPrimaryText(backtest),
      secondaryText: this.createSecondaryText(backtest),
      secondaryTextLines: 2,
      onTouchTap: this.props.onTouchTap
    };
    return Environment.get().createListItem(props);
  }
  createPrimaryText(backtest) {
    return <div className={"primary-text"}>
      {backtest.name}
    </div>;
  }
  createSecondaryText(backtest) {
    return <div className="secondary-text">
      <div className="createdAt">
        {backtest.formattedCreatedAt}
      </div>
      <div className="status">{this.createStatusContent(backtest)}</div>
    </div>;
  }

  createStatusContent(backtest) {
    switch(backtest.status) {
      case "wait_for_finished" :
      case "running" :
        return this.createProgress(backtest);
      default :
        return Utils.createStatusContent(backtest);
    }
  }

  createProgress(backtest) {
    const progress = backtest.progress*100;
    const formattedProgress = NumberFormatter.formatRatio(backtest.progress, 1);
    return <span className="progress">
      <span className="number">{formattedProgress}</span>
      <LinearProgress mode="determinate" className="bar"
        min={0} max={100} value={Math.round(progress)} style={{
          display: "inline-block",
          width: "200px",
          top: "-3px",
          backgroundColor: Theme.palette.borderColor
        }} />
    </span>
  }
}
BacktestListItem.propTypes = {
  backtest: React.PropTypes.object,
  selected: React.PropTypes.bool,
  onTouchTap: React.PropTypes.func,
  onDelete: React.PropTypes.func
};
BacktestListItem.defaultProps = {
  backtest: null,
  selected: false,
  onTouchTap: null
};
