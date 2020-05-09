import React          from "react"
import { injectIntl } from 'react-intl';

import Intervals from "../../../model/trading/intervals"
import Theme     from "../../theme"

import DropDownMenu from "material-ui/DropDownMenu"
import MenuItem     from 'material-ui/MenuItem'

class IntervalSelector extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      selected: null
    };
  }

  componentWillMount() {
    this.setState({
      selected: this.preferences().chartInterval
    });
  }

  render() {
    return (
      <DropDownMenu
        className="interval-selector"
        value={this.state.selected}
        style={
          Object.assign(
            {width:Theme.chart.intervalSelector.width}, this.props.style)
        }
        labelStyle={
          Object.assign({
            padding: "0px",
            color: Theme.palette.textColorLight
          }, Theme.chart.selector, this.props.labelStyle)
        }
        iconStyle={Object.assign({right:"8px"}, this.props.iconStyle)}
        underlineStyle={{margin: "0px"}}
        autoWidth={false}
        onChange={this.onChange.bind(this)}>
        {this.createMenuItems()}
      </DropDownMenu>
    );
  }

  createMenuItems() {
    const { formatMessage } = this.props.intl;
    return Intervals.all().map((item) => {
      return <MenuItem key={item.id}
        value={item.id} primaryText={formatMessage({ id: `common.chartIntervals.${item.labelId}` })} />
    });
  }

  onChange(e, selectedIndex, payload) {
    this.preferences().chartInterval = payload;
    this.setState({selected: payload});
  }

  preferences() {
    return this.props.model.preferences;
  }
}

IntervalSelector.propTypes = {
  model: React.PropTypes.object.isRequired,
  style: React.PropTypes.object,
  labelStyle: React.PropTypes.object,
  iconStyle: React.PropTypes.object
};
IntervalSelector.defaultProps = {
  style: {},
  labelStyle: {},
  iconStyle: {}
};
export default injectIntl(IntervalSelector)
