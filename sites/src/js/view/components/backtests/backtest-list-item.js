import React               from "react"
import MUI                 from "material-ui"
import AbstractComponent   from "../widgets/abstract-component"
import TextInRadius        from "../widgets/text-in-radius"
import Theme               from "../../theme"
import Environment         from "../../environment"
import NumberFormatter     from "../../../viewmodel/utils/number-formatter"
import DateFormatter       from "../../../viewmodel/utils/date-formatter"

const ListItem       = MUI.ListItem;
const LinearProgress = MUI.LinearProgress;
const FontIcon       = MUI.FontIcon;

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
          ? Theme.getPalette().backgroundColorDarkAlpha : "rgba(0,0,0,0)"
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
        {this.formatDate(backtest.createdAt)}
      </div>
      <div className="status">{this.createStatusContent(backtest)}</div>
    </div>;
  }

  createStatusContent(backtest) {
    switch(backtest.status) {
      case "wait_for_finished" :
      case "running" :
        return this.createProgress(backtest);
      case "wait_for_start" :
        return <span className={backtest.status}>待機中</span>;
      case "cancelled" :
        return <span className={backtest.status}>キャンセル</span>;
      case "error" :
        return <span className={backtest.status}>
          <span className={"icon md-warning"} /> エラー
        </span>;
      case "finished" :
        return <span className={backtest.status}>完了</span>;
      default :
        return null;
    }
  }

  createProgress(backtest) {
    const progress = backtest.progress*100;
    const formatedProgress = NumberFormatter.formatRatio(backtest.progress, 1);
    return <span className="progress">
      <span className="number">{formatedProgress}</span>
      <LinearProgress mode="determinate" className="bar"
        min={0} max={100} value={Math.round(progress)} style={{
          display: "inline-block",
          width: "200px",
          top: "-3px",
          backgroundColor: Theme.getPalette().borderColor
        }} />
    </span>
  }

  formatDate(date) {
    return DateFormatter.format(date, "yyyy-MM-dd hh:mm");
  }
}
BacktestListItem.propTypes = {
  backtest: React.PropTypes.object,
  selected: React.PropTypes.bool,
  onTouchTap: React.PropTypes.func
};
BacktestListItem.defaultProps = {
  backtest: null,
  selected: false,
  onTouchTap: null
};
