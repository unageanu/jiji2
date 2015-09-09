import React                  from "react"
import MUI                    from "material-ui"
import Base                   from "../settings/securities-setting-view"

const RaisedButton = MUI.RaisedButton;

export default class SecuritiesSettingView extends Base {

  constructor(props) {
    super(props);
  }

  render() {
    const securitiesSelector = this.creattSecuritiesSelector();
    const activeSecuritiesConfigurator = this.createConfigurator();
    return (
      <div>
        <h3>証券会社の設定</h3>
        <div>
          利用する証券会社を選択して、アクセストークンを設定してください。
        </div>
        <ul>
          <li>
            <a href="http://www.oanda.jp/">OANDA JAPAN</a>の取引口座、
            およびデモ取引口座が利用できます。
          </li>
          <li>
            ご利用には「パーソナルアクセストークン」の入力が必要です。
            アクセストークンの発行手順は、<a href="">こちら</a>をご覧ください。
          </li>
        </ul>
        {securitiesSelector}
        <div>
          {activeSecuritiesConfigurator}
        </div>
        <br/>
        <br/><br/>
        <RaisedButton
          label="次へ"
          disabled={!this.state.availableSecurities.length > 0}
          onClick={this.next.bind(this)}
        />
        <div className="error">{this.state.error}</div>
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
