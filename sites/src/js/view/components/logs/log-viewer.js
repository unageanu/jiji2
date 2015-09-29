import React             from "react";
import MUI               from "material-ui"
import AbstractComponent from "../widgets/abstract-component";
import LoadingImage      from "../widgets/loading-image"
import Theme             from "../../theme"

const FlatButton   = MUI.FlatButton;
const IconButton   = MUI.IconButton;
const Card         = MUI.Card;

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
    const scroller = this.createScrollerElements();
    const body = this.createBodyContnet();
    return (
      <div className="log-viewer">
        <Card className="menu">
          <span className="page-selector">{pageSelectorElements}</span>
          <span className="scroller">{scroller}</span>
        </Card>
        <div className="body">
          {body}
        </div>
      </div>
    );
  }

  createBodyContnet() {
    if (this.state.items && this.state.items.length > 0) {
      return <pre>{ this.state.items[0].body}</pre>;
    } else {
      return <div className="center-information loading">
        <LoadingImage left={-20}/>
      </div>;
    }
  }
  createScrollerElements() {
    const contentSize = this.context.windowResizeManager.contentSize;
    const windowSize  = this.context.windowResizeManager.windowSize;
    return [{
      icon:"expand-less",
      action: () => window.scrollTo(0, 0),
      tooltip: "一番上へ"
    }, {
      icon:"expand-more",
      action: () => window.scrollTo(0, contentSize.h - windowSize.h),
      tooltip: "一番下へ"
    }].map((info, index)=> {
      return <IconButton
          key={info.icon}
          className="scroller-button"
          tooltip={info.tooltip}
          iconClassName={"md-"+info.icon}
          onTouchTap={info.action}
        />;
    });
  }
  createPageSelectorElements() {
    return this.state.pageSelectors.map((selector, index)=> {
      return this.createPageSelectorElement(selector, index);
    });
  }

  createPageSelectorElement(selector, index) {
    if (selector.action) {
      const className = selector.selected ? "selected" : "";
      const palette = Theme.getPalette();
      return (
        <FlatButton
          className={"selector " + className}
          key={index}
          label={""+selector.label}
          onClick={selector.action}
          style={{
            minWidth: "36px",
            border: "1px solid " +
              (selector.selected ? palette.accent1Color : palette.borderColor),
            marginRight: "8px",
            borderRadius: "0px"
          }}
          labelStyle={{
            padding: "0px 8px",
            color: selector.selected ? palette.accent1Color : palette.textColor
          }}
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
  windowResizeManager: React.PropTypes.object.isRequired
};
