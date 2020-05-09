import React                from "react"

import AbstractComponent    from "../widgets/abstract-component"
import LoadingImage         from "../widgets/loading-image"

import {List, ListItem} from "material-ui/List"

const modelKeys = new Set([
  "items"
]);
const selectionModelKeys = new Set([
  "selected",  "selectedId"
]);

export default class AbstractList extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentWillMount() {
    this.registerPropertyChangeListener(this.props.model, modelKeys);
    let state = this.collectInitialState(this.props.model, modelKeys);

    if (this.props.selectionModel) {
      this.registerPropertyChangeListener(
        this.props.selectionModel, selectionModelKeys);
      state = Object.assign(
        state,
        this.collectInitialState(this.props.selectionModel, selectionModelKeys));
    }

    this.setState(state);

    if (this.props.autoFill) this.registerAutoFillHandler();
  }

  render() {
    const filling = this.state.filling
      ? <div key="filling" className="center-information "><LoadingImage top={-80} left={-20} /></div>
      : null;
    return <div className={"list " + this.className}>
      {this.createContnet()}
      {filling}
    </div>;
  }
  createContnet() {
    if (this.state.items == null) {
      return <div className="center-information loading"><LoadingImage left={-20}/></div>;
    }
    if (this.state.items.length <= 0) {
      return <div className="center-information">{this.emptyLabel}</div>;
    }
    return <List
        key="list"
        style={{
          paddingTop:0,
          backgroundColor: "rgba(0,0,0,0)"}}>
          {this.createListItems()}
      </List>;
  }

  get className() {
    return "";
  }

  get emptyLabel() {
    return this.props.emptyLabel;
  }

  createListItems() {
    return this.state.items.map(
      (item, index) => this.createListItem(item, index));
  }
  createListItem() {
    return null;
  }

  registerAutoFillHandler() {
    this.context.windowResizeManager.addObserver("scrolledBottom", () => {
      if ( this.filling || !this.props.model.hasNext ) return;
      this.setState({filling: true});
      this.filling = true;
      this.props.model.fillNext().always(() => {
        this.filling = false;
        this.setState({filling: false});
      });
    }, this);
    this.registerObservable(this.context.windowResizeManager);
  }

}
AbstractList.propTypes = {
  model: React.PropTypes.object.isRequired,
  selectionModel: React.PropTypes.object,
  emptyLabel:  React.PropTypes.string,
  autoFill: React.PropTypes.bool,
  mobile: React.PropTypes.bool
};
AbstractList.defaultProps = {
  selectionModel: null,
  emptyLabel: "",
  autoFill: false,
  mobile: false
};
AbstractList.contextTypes = {
  router: React.PropTypes.object,
  windowResizeManager: React.PropTypes.object
};
