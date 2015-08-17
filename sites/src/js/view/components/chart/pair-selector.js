import React     from "react"
import MUI       from "material-ui"
import Theme     from "../../theme"

const DropDownMenu = MUI.DropDownMenu;
const emptyItems   = [{text:""}];

export default class PairSelector extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      selectedIndex: 0,
      items: emptyItems
    };
  }

  componentWillMount() {
    this.pairs().addObserver("propertyChanged",
      this.onPairsPropertyChanged.bind(this), this);
    this.updateState();
  }
  componentWillUnmount() {
    this.pairs().removeAllObservers(this);
  }

  onPairsPropertyChanged(n, e) {
    if (e.key !== "pairs") return;
    this.updateState();
  }

  updateState() {
    const items = this.convertPairsToMenuItems(this.pairs().pairs);
    const selectedIndex = this.getSelectedIndex(this.preferences().preferredPair, items);
    this.setState({
      items : items,
      selectedIndex:selectedIndex
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
        displayMember="text"
        valueMember="value"
        menuItems={this.state.items}
        selectedIndex={this.state.selectedIndex}
        style={{width:"136px"}}
        labelStyle={{
          padding: "0px",
          fontSize: "24px",
          color: Theme.getPalette().textColorLight}}
        iconStyle={{right:"0px"}}
        underlineStyle={{margin: "0px"}}
        autoWidth={false}
        zDepth={5}
        onChange={this.onChange.bind(this)}/>
    );
  }

  onChange(e, selectedIndex, menuItem) {
    this.preferences().preferredPair = this.state.items[selectedIndex].payload;
    this.setState({selectedIndex: selectedIndex});
  }

  getSelectedIndex(pairName, items) {
    const index = items.findIndex((item)=>item.text === pairName);
    return index === -1 ? 0 : index;
  }

  preferences() {
    return this.props.model.preferences;
  }
  pairs() {
    return this.props.model.pairs;
  }
}
PairSelector.propTypes = {
  model: React.PropTypes.object.isRequired
};
