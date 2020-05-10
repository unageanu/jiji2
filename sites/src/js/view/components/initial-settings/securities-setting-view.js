import React                            from "react"
import { injectIntl, FormattedMessage } from 'react-intl';

import { SecuritiesSettingView as Base } from "../settings/securities-setting-view"
import LoadingImage                      from "../widgets/loading-image"

import RaisedButton from "material-ui/RaisedButton"

class SecuritiesSettingView extends Base {

  constructor(props) {
    super(props);
  }

  render() {
    const { formatMessage } = this.props.intl;
    const securitiesSelector = this.creattSecuritiesSelector();
    const activeSecuritiesConfigurator = this.createConfigurator();
    return (
      <div className="securities-setting-view">
        <h3><FormattedMessage id='initialSettings.SecuritiesSettingView.title'/></h3>
        <div className="description">
          <FormattedMessage id='initialSettings.SecuritiesSettingView.description.part1'/>
        </div>
        <ul className="description">
          <li>
            <a onClick={ () => window.open('http://www.oanda.jp/', '_blank') } ><FormattedMessage id='initialSettings.SecuritiesSettingView.description.part2'/></a>
            <FormattedMessage id='initialSettings.SecuritiesSettingView.description.part3'/>
          </li>
          <li>
            <FormattedMessage id='initialSettings.SecuritiesSettingView.description.part4'/>
            <a onClick={ () => window.open('http://jiji2.unageanu.net/install/010000_prepare_account.html', '_blank') } >
              <FormattedMessage id='initialSettings.SecuritiesSettingView.description.part5'/>
            </a>
            <FormattedMessage id='initialSettings.SecuritiesSettingView.description.part6'/>
          </li>
        </ul>
        <div className="inputs">
          {securitiesSelector}
          <div>
            {activeSecuritiesConfigurator}
          </div>
        </div>
        {this.createErrorContent(this.state.error)}
        <div className="buttons">
          <span className="button">
            <RaisedButton
              label={formatMessage({ id: 'common.button.next' })}
              disabled={this.state.isSaving}
              onClick={this.next.bind(this)}
              primary={true}
              labelStyle={{lineHeight: "50px"}}
              style={{width:"100%", height: "50px"}}
            />
          </span>
          <span className="loading-for-button-action">
            {this.state.isSaving ? <LoadingImage size={20} /> : null}
          </span>
        </div>
      </div>
    );
  }

  next() {
    const configurations = this.collectConfigurations();
    this.props.model.setSecurities( configurations, this.props.intl.formatMessage );
  }

  model() {
    return this.props.model.securitiesSetting;
  }
}
SecuritiesSettingView.propTypes = {
  model: React.PropTypes.object
};
SecuritiesSettingView.defaultProps = {
  model: null
};
export default injectIntl(SecuritiesSettingView);
