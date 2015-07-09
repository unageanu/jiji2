import React         from "react"
import MUI           from "material-ui"
import DateFormatter from "../../../viewmodel/utils/date-formatter"

export default class RangeView extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      range: {}
    };
  }
  componentWillMount() {
    this.props.chartModel.slider.addObserver("propertyChanged", (n, e) => {
      if (e.key !== "currentRange"
       && e.key !== "temporaryCurrentRange" ) {
        return;
      }
      this.setState({
        range: e.newValue || {}
      });
    }, this);
    this.setState({
      range: this.props.chartModel.slider.currentRange || {}
    });
  }
  componentWillUnmount() {
    this.props.chartModel.slider.removeAllObservers(this);
  }

  render() {
    const displayRange = this.format(this.state.range.start)
              + " ～ " + this.format(this.state.range.end);
    return (
      <div className="range">{displayRange}</div>
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
