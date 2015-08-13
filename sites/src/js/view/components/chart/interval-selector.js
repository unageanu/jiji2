import React     from "react"
import MUI       from "material-ui"
import Intervals from "../../../model/trading/intervals"

const DropDownMenu = MUI.DropDownMenu;

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
        style={{width:"100px"}}
        labelStyle={{padding: "0px 0px 0px 16px"}}
        iconStyle={{right:"8px"}}
        underlineStyle={{margin: "0px 8px"}}
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
  model: React.PropTypes.object.isRequired
};
