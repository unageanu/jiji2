import React                  from "react"
import { injectIntl, FormattedMessage, } from 'react-intl';

import AbstractComponent      from "../widgets/abstract-component"

import RaisedButton from "material-ui/RaisedButton"
import Checkbox from "material-ui/Checkbox"

const keys = new Set([
  "acceptLicense", "acceptionError"
]);

export class WelcomeView extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentWillMount() {
    const model = this.props.model;
    this.registerPropertyChangeListener(model, keys);
    this.setState(this.collectInitialState(model, keys));
  }

  render() {
    const { formatMessage } = this.props.intl;
    return (
      <div className="welcome-view">
        <div className="description">
          <FormattedMessage id='initialSettings.WelcomeView.description.part1'/><br/>
          <FormattedMessage id='initialSettings.WelcomeView.description.part2'/>
        </div>
        <div className="license inputs">
          <div className="license-link">
            <a onClick={ () => window.open('http://jiji2.unageanu.net/terms/', '_blank') } >
              <FormattedMessage id='initialSettings.WelcomeView.license'/>
            </a>
          </div>
          <div className="accept-license">
            <Checkbox
              checked={this.state.acceptLicense}
              onCheck={(ev, checked) => this.props.model.acceptLicense = checked }
              name={"accept"}
              value={"accept"}
              label={formatMessage({ id: 'initialSettings.WelcomeView.accept' })}
              />
          </div>
        </div>
        {this.createErrorContent(this.state.acceptionError)}
        <div className="buttons">
          <span className="button">
            <RaisedButton
              label={formatMessage({ id: 'initialSettings.WelcomeView.start' })}
              primary={true}
              style={{width:"100%", height: "50px"}}
              labelStyle={{lineHeight: "50px"}}
              onClick={() => this.props.model.startSetting(formatMessage)}
            />
          </span>
        </div>
      </div>
    );
  }
}
WelcomeView.propTypes = {
  model: React.PropTypes.object
};
WelcomeView.defaultProps = {
  model: null
};
export default injectIntl(WelcomeView);
