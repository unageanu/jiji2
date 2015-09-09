import React                  from "react"
import MUI                    from "material-ui"
import AbstractComponent      from "../widgets/abstract-component"

const RaisedButton = MUI.RaisedButton;

export default class SettingFinishedView extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
    };
  }

  render() {
    return (
      <div>
        <div>
          設定が完了しました。お疲れ様でした。
          詳しい使い方はこちらをご覧ください。
        </div>
        <RaisedButton
          label="利用を開始する"
          onClick={() => this.props.model.exit()}
        />
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
