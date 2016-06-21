import React              from "react"

import DateFormatter      from "../../../viewmodel/utils/date-formatter"
import AbstractComponent  from "../widgets/abstract-component"

const keys = new Set([
  "currentRange", "temporaryCurrentRange"
]);

export default class RangeView extends AbstractComponent {
  constructor(props) {
    super(props);
    this.state = {
      range: {}
    };
  }
  componentWillMount() {
    this.registerPropertyChangeListener( this.props.chartModel.slider, keys);
    this.setState({
      range: this.props.chartModel.slider.currentRange || {}
    });
  }
  onPropertyChanged(k, e) {
    if (e.key !== "currentRange"
     && e.key !== "temporaryCurrentRange" ) {
      return;
    }
    this.setState({
      range: e.newValue || {}
    });
  }

  render() {
    const displayRange = this.format(this.state.range.start)
              + " ～ " + this.format(this.state.range.end);
    return (
      <div className="range">
        <span className="label">表示期間:</span>
        {displayRange}</div>
    );
  }
  format(date) {
    return DateFormatter.formatDateYYYYMMDD(date)
       + " " + DateFormatter.formatTimeHHMM(date);
  }
}
RangeView.propTypes = {
  chartModel: React.PropTypes.object.isRequired
};
