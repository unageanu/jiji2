import React              from "react"

import DateFormatter      from "../../../viewmodel/utils/date-formatter"
import AbstractComponent  from "../widgets/abstract-component"

import DatePicker from "material-ui/DatePicker"

const keys = new Set([
  "startTime", "endTime", "minDate", "maxDate",
  "startTimeError", "endTimeError", "enable"
]);

export default class RangeSelector extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentWillMount() {
    this.registerPropertyChangeListener(this.props.model, keys);
    const state = this.collectInitialState(this.props.model, keys);
    this.setState(state);
  }

  render() {
    return (
      <div className="range-selector">
        <div className="selector">
        {this.createDatePicker("startTime", "開始", this.state.startTime)}
        <span className="separator">～</span>
        {this.createDatePicker("endTime", "終了", this.state.endTime)}
        </div>
        {this.createErrorContent(
          this.state.startTimeError || this.state.endTimeError)}
      </div>
    );
  }

  createDatePicker(name, hintText, defaultValue) {
    return <DatePicker
      key={name}
      ref={name}
      formatDate={DateFormatter.formatDateYYYYMMDD}
      hintText={hintText}
      minDate={this.state.minDate}
      maxDate={this.state.maxDate}
      defaultDate={defaultValue}
      showYearSelector={true}
      disabled={!this.state.enable}
      style={{
        display: "inline-block",
      }}
      textFieldStyle={{
        width: "120px"
      }} />
  }

  applySetting() {
    this.props.model.startTime = this.startTime;
    this.props.model.endTime   = this.endTime;
  }

  get startTime() {
    return this.refs.startTime.getDate();
  }
  get endTime() {
    return this.refs.endTime.getDate();
  }
}
RangeSelector.propTypes = {
  model: React.PropTypes.object.isRequired
};
RangeSelector.defaultProps = {
};
