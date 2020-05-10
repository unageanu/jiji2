import React                            from "react"
import { injectIntl, FormattedHTMLMessage } from 'react-intl';

import AbstractComponent from "../widgets/abstract-component"
import LoadingImage      from "../widgets/loading-image"
import Theme             from "../../theme"

import FlatButton from "material-ui/FlatButton"
import IconButton from "material-ui/IconButton"
import Card from "material-ui/Card"

const keys = new Set([
  "items", "pageSelectors", "loading"
]);

class LogViewer extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      items : [],
      pageSelectors: [],
      loading: true
    };
  }

  componentWillMount() {
    this.registerPropertyChangeListener(this.props.model, keys);
    const state = this.collectInitialState(this.props.model, keys);
    this.setState(state);
  }

  render() {
    const menu = this.createMenu();
    const body = this.createBodyContnet();
    return (
      <div className="log-viewer">
        {menu}
        <div className="body">
          {body}
        </div>
      </div>
    );
  }

  createMenu() {
    if (!this.existLog()) return null;
    const pageSelectorElements = this.createPageSelectorElements();
    const scroller = this.createScrollerElements();
    return <Card className="menu">
      <span className="page-selector">{pageSelectorElements}</span>
      <span className="scroller">{scroller}</span>
    </Card>;
  }

  createBodyContnet() {
    if (!this.state.items || this.state.loading) {
      return <div className="center-information loading">
        <LoadingImage left={-20}/>
      </div>;
    } else if (!this.existLog()) {
      return <div className="center-information">
        <FormattedHTMLMessage id='logs.LogViewer.noLogs'/>
      </div>;
    } else {
      return <pre>{this.state.items[0].body}</pre>;
    }
  }
  createScrollerElements() {
    const { formatMessage } = this.props.intl;
    const contentSize = this.context.windowResizeManager.contentSize;
    const windowSize  = this.context.windowResizeManager.windowSize;
    return [{
      icon:"expand-less",
      action: () => window.scrollTo(0, 0),
      tooltip: formatMessage({ id: 'logs.LogViewer.scrollToTop' })
    }, {
      icon:"expand-more",
      action: () => window.scrollTo(0, contentSize.h - windowSize.h),
      tooltip: formatMessage({ id: 'logs.LogViewer.scrollToBottom' })
    }].map((info, index)=> {
      return <IconButton
          key={info.icon}
          className="scroller-button"
          tooltip={info.tooltip}
          tooltipPosition="top-center"
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
      const palette = Theme.palette;
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

  existLog() {
    return this.state.items
        && this.state.items.length > 0
        && this.state.items[0].body;
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

export default injectIntl(LogViewer);
