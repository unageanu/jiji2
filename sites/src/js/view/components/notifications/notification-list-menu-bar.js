import React                from "react"
import MUI                  from "material-ui"
import AbstractComponent    from "../widgets/abstract-component"
import NotificationListItem from "./notification-list-item"
import LoadingImage         from "../widgets/loading-image"

const List   = MUI.List;
const FlatButton   = MUI.FlatButton;
const DropDownMenu = MUI.DropDownMenu;
const IconButton   = MUI.IconButton;
const FontIcon     = MUI.FontIcon;

const keys = new Set([
  "hasNext", "hasPrev", "availableFilterConditions",
  "filterCondition", "selectedConditionIndex",
  "loading"
]);

export default class NotificationListMenuBar extends AbstractComponent {

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
    return <div className="app-bar">
      <DropDownMenu
        style={{width:"256px"}}
        menuItems={this.state.availableFilterConditions}
        selectedIndex={this.state.selectedConditionIndex}
        onChange={this.onChange.bind(this)}/>
      <div className="buttons">
        {this.createButtons()}
      </div>
    </div>;
  }

  createButtons() {
    const prev = () => this.props.model.prev();
    const next = () => this.props.model.next();
    return [
      <IconButton
        key="prev"
        tooltip="前の20件"
        disabled={this.state.loading || !this.state.hasPrev}
        onClick={prev}>
        <FontIcon className="md-navigate-before"/>
      </IconButton>,
      <IconButton
        key="next"
        tooltip="次の20件"
        disabled={this.state.loading || !this.state.hasNext}
        onClick={next}>
        <FontIcon className="md-navigate-next"/>
      </IconButton>
    ];
  }
  onChange(e, selectedIndex, menuItem) {
    const item = this.state.availableFilterConditions[selectedIndex];
    this.props.model.filter(item.condition);
    this.setState({selectedConditionIndex: selectedIndex});
  }
}
NotificationListMenuBar.propTypes = {
  model: React.PropTypes.object.isRequired
};
