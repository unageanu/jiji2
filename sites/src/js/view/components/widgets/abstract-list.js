import React                from "react"
import MUI                  from "material-ui"
import AbstractComponent    from "../widgets/abstract-component"
import LoadingImage         from "../widgets/loading-image"

const List   = MUI.List;

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
    if (this.state.items == null) {
      return <div className="center-information loading"><LoadingImage left={-20}/></div>;
    }
    if (this.state.items.length <= 0) {
      return <div className="center-information">{this.props.emptyLabel}</div>;
    }
    const filling = this.state.filling
      ? <div className="center-information "><LoadingImage top={-80} left={-20} /></div>
      : null;
    return <div>
      <List
        className={"list " + this.className}
        style={{
          paddingTop:0,
          backgroundColor: "rgba(0,0,0,0)"}}>
          {this.createListItems()}
      </List>
      {filling}
    </div>;
  }

  get className() {
    return "";
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
  innerDivStyle: React.PropTypes.object,
  emptyLabel:  React.PropTypes.string,
  autoFill: React.PropTypes.bool,
  mobile: React.PropTypes.bool
};
AbstractList.defaultProps = {
  selectionModel: null,
  innerDivStyle: {},
  emptyLabel: "",
  autoFill: false,
  mobile: false
};
AbstractList.contextTypes = {
  router: React.PropTypes.func,
  windowResizeManager: React.PropTypes.object
};
