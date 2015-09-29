import React             from "react";
import MUI               from "material-ui"
import AbstractComponent from "../widgets/abstract-component";

const FlatButton   = MUI.FlatButton;

const keys = new Set([
  "items", "pageSelectors"
]);

export default class LogViewer extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      items : [],
      pageSelectors: []
    };
  }

  componentWillMount() {
    this.registerPropertyChangeListener(this.props.model, keys);
    const state = this.collectInitialState(this.props.model, keys);
    this.setState(state);
  }

  render() {
    const pageSelectorElements = this.createPageSelectorElements();
    const body = this.state.items && this.state.items.length > 0
      ? this.state.items[0].body : "";
    return (
      <div className="log-viewer">
        <div className="page-selector">{pageSelectorElements}</div>
        <div className="body">
          <pre>{body}</pre>
        </div>
      </div>
    );
  }

  createPageSelectorElements() {
    return this.state.pageSelectors.map((selector, index)=> {
      return this.createPageSelectorElement(selector, index);
    });
  }

  createPageSelectorElement(selector, index) {
    if (selector.action) {
      const className = selector.selected ? "selected" : "";
      return (
        <FlatButton
            className={className}
            key={index}
            label={""+selector.label}
            onClick={selector.action}
          />
      );
    } else {
      return <span
        key={index}
        className="separator">
        {selector.label}
      </span>;
    }
  }

}
LogViewer.propTypes = {
  model: React.PropTypes.object
};
LogViewer.defaultProps = {
  model: null
};
LogViewer.contextTypes = {
  application: React.PropTypes.object.isRequired
};
