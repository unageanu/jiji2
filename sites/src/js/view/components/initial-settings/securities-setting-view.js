import React                  from "react"

import Base                   from "../settings/securities-setting-view"
import LoadingImage           from "../widgets/loading-image"

import RaisedButton from "material-ui/RaisedButton"

export default class SecuritiesSettingView extends Base {

  constructor(props) {
    super(props);
  }

  render() {
    const securitiesSelector = this.creattSecuritiesSelector();
    const activeSecuritiesConfigurator = this.createConfigurator();
    return (
      <div className="securities-setting-view">
        <h3>証券会社の設定</h3>
        <div className="description">
          利用する証券会社を選択して、アクセストークンを設定してください。
        </div>
        <ul className="description">
          <li>
            <a onClick={ () => window.open('http://www.oanda.jp/', '_blank') } >OANDA Japan</a>の取引口座、
            およびデモ取引口座が利用できます。
          </li>
          <li>
            ご利用には「パーソナルアクセストークン」の入力が必要です。
            アクセストークンの発行手順は、<a onClick={ () => window.open('http://jiji2.unageanu.net/install/010000_prepare_account.html', '_blank') } >こちら</a>をご覧ください。
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
              label="次へ"
              disabled={this.state.isSaving}
              onClick={this.next.bind(this)}
              primary={true}
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
    this.props.model.setSecurities( configurations );
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
