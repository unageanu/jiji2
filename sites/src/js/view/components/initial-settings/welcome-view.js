import React                  from "react"
import MUI                    from "material-ui"
import AbstractComponent      from "../widgets/abstract-component"

const RaisedButton = MUI.RaisedButton;
const Checkbox = MUI.Checkbox;

const keys = new Set([
  "acceptLicense", "acceptionError"
]);

export default class WelcomeView extends AbstractComponent {

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
    return (
      <div className="welcome-view">
        <div className="description">
          Jijiへようこそ。<br/>
          利用規約をご確認のうえ、初期設定を開始してください。
        </div>
        <div className="license inputs">
          <div className="license-link">
            <a href="" target="_blank">Jiji利用規約</a>
          </div>
          <div className="accept-license">
            <Checkbox
              checked={this.state.acceptLicense}
              onCheck={(ev, checked) => this.props.model.acceptLicense = checked }
              name={"accept"}
              value={"accept"}
              label={"利用規約に同意する"}
              />
          </div>
        </div>
        {this.createErrorContent(this.state.acceptionError)}
        <div className="buttons">
          <span className="button">
            <RaisedButton
              label="初期設定を開始"
              primary={true}
              style={{width:"100%", height: "50px"}}
              onClick={() => this.props.model.startSetting()}
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
