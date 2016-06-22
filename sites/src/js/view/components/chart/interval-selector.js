import React     from "react"

import Intervals from "../../../model/trading/intervals"
import Theme     from "../../theme"

import DropDownMenu from "material-ui/DropDownMenu"

const items = Intervals.all().map(
  (item) => { return { id: item.id, text:item.name }; } );

export default class IntervalSelector extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      selectedIndex: 0
    };
  }

  componentWillMount() {
    const selectedIndex = this.getSelectedIndex(this.preferences().chartInterval);
    this.setState({selectedIndex:selectedIndex});
  }

  render() {
    return (
      <DropDownMenu
        className="interval-selector"
        menuItems={items}
        selectedIndex={this.state.selectedIndex}
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
        zDepth={5}
        onChange={this.onChange.bind(this)}/>
    );
  }

  onChange(e, selectedIndex, menuItem) {
    this.preferences().chartInterval = items[selectedIndex].id;
    this.setState({selectedIndex: selectedIndex});
  }

  getSelectedIndex(intervalId) {
    const index = items.findIndex((item)=>item.id === intervalId);
    return index === -1 ? 0 : index;
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
