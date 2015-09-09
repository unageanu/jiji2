import React             from "react";
import MUI               from "material-ui"
import AbstractComponent from "../widgets/abstract-component";

const FlatButton   = MUI.FlatButton;

export default class LogViewer extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      items : [],
      pageSelectors: []
    };
  }

  componentWillMount() {
    this.registerPropertyChangeListener(this.props.model);
    this.setState({
      items :        this.props.model.items,
      pageSelectors: this.props.model.pageSelectors
    });
  }
  componentWillUnmount() {
    this.props.model.removeAllObservers(this);
  }

  render() {
    const pageSelectorElements = this.createPageselectorElements();
    const body = this.state.items && this.state.items.length > 0
      ? this.state.items[0].body : "";
    return (
      <div>
        <div>{pageSelectorElements}</div>
        <div>
          <pre>{body}</pre>
        </div>
      </div>
    );
  }

  createPageselectorElements() {
    return this.state.pageSelectors.map((selector)=> {
      return this.createPageselectorElement(selector);
    });
  }

  createPageselectorElement(selector) {
    if (selector.action) {
      const className = selector.selected ? "selected" : "";
      return (
        <FlatButton
            className={className}
            key={selector.label}
            label={selector.label}
            onClick={selector.action}
          />
      );
    } else {
      return <span className="separator">{selector.label}</span>;
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
