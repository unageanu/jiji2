import React                  from "react"
import MUI                    from "material-ui"
import AbstractComponent      from "../widgets/abstract-component"

const RaisedButton = MUI.RaisedButton;

export default class WelcomeView extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
    };
  }

  render() {
    return (
      <div>
        <div>
        ようこそ。
        </div>
        <RaisedButton
          label="初期設定を開始"
          onClick={() => this.props.model.startSetting()}
        />
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
