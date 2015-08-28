import React                from "react"
import MUI                  from "material-ui"
import AbstractComponent    from "../widgets/abstract-component"
import PositionListItem     from "./position-list-item"
import LoadingImage         from "../widgets/loading-image"

const List   = MUI.List;

const keys = new Set([
  "items", "selectedPosition"
]);

export default class PositionList extends AbstractComponent {

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
    if (this.state.items == null) {
      return <div className="info"><LoadingImage /></div>;
    }
    if (this.state.items.length <= 0) {
      return <div className="info">建玉はありません</div>;
    }
    return <List style={{paddingTop:0}}>{this.createListItems()}</List>;
  }
  createListItems() {
    if (this.state.items == null) return [];
    return this.state.items.map((position, index) => {
       return <PositionListItem
          key={index}
          position={position}
          innerDivStyle={this.props.innerDivStyle}
          selected={this.props.selectable && this.state.selectedIndex === index } /> ;
    });
  }

}
PositionList.propTypes = {
  model: React.PropTypes.object.isRequired,
  selectable: React.PropTypes.bool.isRequired,
    innerDivStyle: React.PropTypes.object
};
