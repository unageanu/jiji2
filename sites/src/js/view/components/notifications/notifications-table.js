import React               from "react"
import MUI                 from "material-ui"
import AbstractComponent   from "../widgets/abstract-component"

const FlatButton   = MUI.FlatButton;
const DropDownMenu = MUI.DropDownMenu;

export default class NotificationsTable extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      hasNext :                  false,
      hasPrev :                  false,
      items :                    [],
      selectedNotification:      null,
      availableFilterConditions: [],
      filterCondition:           {backtestId: null},
      selectedConditionIndex:    0
    };
  }

  componentWillMount() {
    this.registerPropertyChangeListener(this.props.model);
    this.setState({
      hasNext :                  this.props.model.hasNext,
      hasPrev :                  this.props.model.hasPrev,
      items :                    this.props.model.items,
      selectedNotification:      this.props.model.selectedNotification,
      availableFilterConditions: this.props.model.availableFilterConditions,
      filterCondition:           this.props.model.filterCondition
    });
  }
  componentWillUnmount() {
    this.props.model.removeAllObservers(this);
  }

  render() {
    const body          = this.createBodyContent();
    const actionContent = this.createActionContent();
    return (
      <div className="notifications-table">
        <div className="actions">
          <DropDownMenu
            menuItems={this.state.availableFilterConditions}
            selectedIndex={this.state.selectedConditionIndex}
            onChange={this.onChange.bind(this)}/>
          {actionContent}
        </div>
        <div className="notifications">
          {body}
        </div>
      </div>
    );
  }

  createActionContent() {
    const prev = () => this.props.model.prev();
    const next = () => this.props.model.next();
    return [
      <FlatButton
        key="prev"
        label="前の100件"
        disabled={!this.state.hasPrev}
        onClick={prev}
      />,
      <FlatButton
        key="next"
        label="次の100件"
        disabled={!this.state.hasNext}
        onClick={next}
      />
    ];
  }

  createBodyContent() {
    if (!this.state.items) return [];
    return this.state.items.map((item) => {
      const selected = this.state.selectedNotification
        && item.id === this.state.selectedNotification.id;
      return selected
        ? this.createSelectedItemContent(item)
        : this.createItemContent(item);
    });
  }

  createItemContent(item) {
    const onClick  = (ev) => this.onItemTapped(ev, item);
    return <div key={item.id} onClick={onClick}>
      <div className="body" onClick={onClick}>
        {item.message}
        <br/>
        {item.formatedTimestamp} {item.readAt ? "" : "未読" }
      </div>
    </div>;
  }
  createSelectedItemContent(item) {
    const actions = (item.actions || []).map(
      (action)=> this.createActionButtons(item, action));
    return <div key={item.id} className="selected">
      <div className="body">
        {item.message}
        <br/>
        {item.formatedTimestamp}
      </div>
      <div className="actions">
        {actions}
      </div>
    </div>;
  }
  createActionButtons(item, action) {
    const execute = () => this.props.model.executeAction(item, action.action);
    return <FlatButton
      label={action.label}
      onClick={execute}
    />;
  }

  onItemTapped(e, notification) {
    this.props.model.selectedNotification = notification;
  }
  onChange(e, selectedIndex, menuItem) {
    const item = this.state.availableFilterConditions[selectedIndex];
    this.props.model.filter(item.condition);
    this.setState({selectedConditionIndex: selectedIndex});
  }

}
NotificationsTable.propTypes = {
  model: React.PropTypes.object
};
NotificationsTable.defaultProp = {
  model: null
};
NotificationsTable.contextTypes = {
  application: React.PropTypes.object.isRequired
};
