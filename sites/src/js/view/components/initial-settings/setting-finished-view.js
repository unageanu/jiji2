import React                            from "react"
import { injectIntl, FormattedMessage, FormattedHTMLMessage } from 'react-intl';

import AbstractComponent      from "../widgets/abstract-component"

import RaisedButton from "material-ui/RaisedButton"

class SettingFinishedView extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
    };
  }

  render() {
    const { formatMessage } = this.props.intl;
    return (
      <div className="setting-finished-view">
        <h3><FormattedMessage id='initialSettings.SettingFinishedView.title'/></h3>
        <div className="description">
          <FormattedMessage id='initialSettings.SettingFinishedView.description.part1'/>
        </div>
        <ul className="description">
          <li>
            <FormattedMessage id='initialSettings.SettingFinishedView.description.part2'/>
            <a onClick={ () => window.open('http://jiji2.unageanu.net/usage/', '_blank') } >
              <FormattedMessage id='initialSettings.SettingFinishedView.description.part3'/>
            </a>
            <FormattedMessage id='initialSettings.SettingFinishedView.description.part4'/>
          </li>
          <li className="push_description">
            <FormattedMessage id='initialSettings.SettingFinishedView.description.part5'/>
          </li>
        </ul>

        <div className="push">
          <h2><FormattedMessage id='initialSettings.SettingFinishedView.app.title'/></h2>
          <div className="boxes">
            <div className="box box2">
              <h3><FormattedMessage id='initialSettings.SettingFinishedView.app.p.catch'/></h3>
              <img src="../images/app_future_01.png" />
              <div>
                <FormattedMessage id='initialSettings.SettingFinishedView.app.p.detail'/>
              </div>
            </div>
            <div className="box box2">
              <h3><FormattedMessage id='initialSettings.SettingFinishedView.app.p2.catch'/></h3>
              <img src="../images/app_future_02.png" />
              <div>
                <FormattedHTMLMessage id='initialSettings.SettingFinishedView.app.p2.detail'/>
              </div>
            </div>
          </div>
          <div className="text">
            <FormattedHTMLMessage id='initialSettings.SettingFinishedView.app.description'/>
          </div>
          <div className="android_badge">
            <a id="install_app" target="_blank"  href="https://play.google.com/store/apps/details?id=net.unageanu.jiji&utm_source=global_co&utm_medium=prtnr&utm_content=Mar2515&utm_campaign=PartBadge&pcampaignid=MKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1">
              <img alt="Get it on Google Play" src="https://play.google.com/intl/en_us/badges/images/generic/en-play-badge.png" />
            </a>
            <div className="info"><FormattedHTMLMessage id='initialSettings.SettingFinishedView.app.iOS'/></div>
          </div>
        </div>


        <div className="buttons">
          <span className="button">
            <RaisedButton
              label={formatMessage({ id: 'initialSettings.SettingFinishedView.start' })}
              onClick={() => this.props.model.exit()}
              primary={true}
              labelStyle={{lineHeight: "50px"}}
              style={{width:"100%", height: "50px"}}
            />
          </span>
        </div>
      </div>
    );
  }
}
SettingFinishedView.propTypes = {
  model: React.PropTypes.object
};
SettingFinishedView.defaultProps = {
  model: null
};
export default injectIntl(SettingFinishedView);
