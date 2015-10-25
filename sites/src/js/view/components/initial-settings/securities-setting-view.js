import React                  from "react"
import MUI                    from "material-ui"
import Base                   from "../settings/securities-setting-view"
import LoadingImage           from "../widgets/loading-image"

const RaisedButton = MUI.RaisedButton;

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
            <a href="http://www.oanda.jp/">OANDA JAPAN</a>の取引口座、
            およびデモ取引口座が利用できます。
          </li>
          <li>
            ご利用には「パーソナルアクセストークン」の入力が必要です。
            アクセストークンの発行手順は、<a href="">こちら</a>をご覧ください。
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
          <RaisedButton
            label="次へ"
            disabled={this.state.isSaving}
            onClick={this.next.bind(this)}
            primary={true}
            style={{width:"300px", height: "50px"}}
          />
          <span className="loading">
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
