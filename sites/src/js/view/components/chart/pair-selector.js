import React              from "react"

import Theme              from "../../theme"
import AbstractComponent  from "../widgets/abstract-component"
import DropDownMenu       from "material-ui/DropDownMenu"
import MenuItem           from 'material-ui/MenuItem'

const keys = new Set([
  "availablePairs", "selectedPair"
]);


const emptyItems   = [{text:""}];

export default class PairSelector extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      selectedIndex: 0,
      items: emptyItems
    };
  }

  componentWillMount() {
    this.registerPropertyChangeListener( this.pairSelector(), keys);
    this.updateState();
  }

  onPropertyChanged(k, e) {
    this.updateState();
  }

  updateState() {
    const items = this.convertPairsToMenuItems(
      this.pairSelector().availablePairs);
    this.setState({
      items : items,
      selected: this.pairSelector().selectedPair
    });
  }

  convertPairsToMenuItems(pairs) {
    if (pairs.length <= 0) return emptyItems;
    return pairs.map((item) => {
      return {text:item.name, value:item.name };
    });
  }

  render() {
    return (
      <DropDownMenu
        className="pair-selector"
        value={this.state.selected}
        style={
          Object.assign(
            {width:Theme.chart.pairSelector.width}, this.props.style)
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
    return this.state.items.map((item, index) => {
      return <MenuItem key={index}
        value={item.value} primaryText={item.text} />
    });
  }

  onChange(e, selectedIndex, payload) {
    this.pairSelector().selectedPair = payload;
    this.setState({selected: payload});
  }

  pairSelector() {
    return this.props.model.pairSelector;
  }
}
PairSelector.propTypes = {
  model: React.PropTypes.object.isRequired,
  style: React.PropTypes.object,
  labelStyle: React.PropTypes.object,
  iconStyle: React.PropTypes.object
};
PairSelector.defaultProps = {
  style: {},
  labelStyle: {},
  iconStyle: {}
};
