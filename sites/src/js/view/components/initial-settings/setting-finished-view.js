import React                  from "react"

import AbstractComponent      from "../widgets/abstract-component"

import RaisedButton from "material-ui/RaisedButton"

export default class SettingFinishedView extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
    };
  }

  render() {
    return (
      <div className="setting-finished-view">
        <h3>完了</h3>
        <div className="description">
          すべての設定が完了しました。
        </div>
        <ul className="description">
          <li>システムの詳しい使い方は<a onClick={ () => window.open('http://jiji2.unageanu.net/usage/', '_blank') } >こちら</a>をご覧ください。</li>
          <li className="push_description">
            スマホアプリも、ぜひご利用ください!
          </li>
        </ul>

        <div className="push">
          <h2>スマホアプリでできること</h2>
          <div className="boxes">
            <div className="box box2">
              <h3>Push通知で、取引のタイミングを逃さない!</h3>
              <img src="../images/app_future_01.png" />
              <div>
                スマホアプリを使うと、取引アルゴリズムからのPush通知を受信できます。取引のポイントでPush通知を送ることで、売買のタイミングをリアルタイムに受け取ることができます。
               </div>
            </div>
            <div className="box box2">
              <h3>取引状況の確認・システムの管理を、いつでもどこでも。</h3>
              <img src="../images/app_future_02.png" />
              <div>
                シンプルなUIで、取引状況をさっと把握。<br/>
                システムの管理もできるので、相場が急に動いても、どこでもすぐに対応できます。
              </div>
            </div>
          </div>
          <div className="text">
            スマホアプリは、<b>月額450円(税抜)の有料ソフトウェア</b>です。<br/>
            まずはお試し。いまなら、購入後<b>30日間無料</b>でご利用いただけます。
          </div>
          <div className="android_badge">
            <a id="install_app" target="_blank"  href="https://play.google.com/store/apps/details?id=net.unageanu.jiji&utm_source=global_co&utm_medium=prtnr&utm_content=Mar2515&utm_campaign=PartBadge&pcampaignid=MKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1">
              <img alt="Get it on Google Play" src="https://play.google.com/intl/en_us/badges/images/generic/en-play-badge.png" />
            </a>
            <div className="info">※iOS版は準備中です。</div>
          </div>
        </div>


        <div className="buttons">
          <span className="button">
            <RaisedButton
              label="利用を開始する"
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
