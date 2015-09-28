import React              from "react"
import MUI                from "material-ui"
import Draggable          from "react-draggable"
import DateFormatter      from "../../../viewmodel/utils/date-formatter"
import NumberFormatter    from "../../../viewmodel/utils/number-formatter"
import RangeView          from "./range-view"
import AbstractComponent  from "../widgets/abstract-component"

const keys = new Set([
  "rate", "time"
]);

export default class RateView extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      rate : null,
      time : null
    };
  }

  componentWillMount() {
    this.registerPropertyChangeListener(this.props.chartModel.pointer, keys);
    const state = this.collectInitialState(this.props.chartModel.pointer, keys);
    this.setState(state);
  }

  render() {
    const rate = this.state.rate || { data: {} };
    return (
      <div className="rate-view">
        <div className="time">{DateFormatter.format(this.state.time)}</div>
        <div className="rate">
          <span className="label">始値:</span>
          <span className="value">
            {NumberFormatter.insertThousandsSeparator(rate.data.open ? rate.data.open.bid : null)}
          </span>
          <span className="label">終値:</span>
          <span className="value">
            {NumberFormatter.insertThousandsSeparator(rate.data.close ? rate.data.close.bid : null)}
          </span>
          <span className="label">高値:</span>
          <span className="value">
            {NumberFormatter.insertThousandsSeparator(rate.data.high ? rate.data.high.bid : null)}
          </span>
          <span className="label">安値:</span>
          <span className="value">
            {NumberFormatter.insertThousandsSeparator(rate.data.low ? rate.data.low.bid : null)}
          </span>
        </div>
      </div>
    );
  }
}
RateView.propTypes = {
  chartModel: React.PropTypes.object.isRequired
};
RateView.defaultProps = {};
