import React               from "react"
import MUI                 from "material-ui"
import AbstractComponent   from "../widgets/abstract-component"
import LoadingImage        from "../widgets/loading-image"
import PairSelector        from "../widgets/pair-selector"

const RaisedButton = MUI.RaisedButton;
const TextField    = MUI.TextField;

const keys = new Set([
  "message", "isSaving"
]);

export default class PairSettingView extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentWillMount() {
    const model = this.model();
    this.registerPropertyChangeListener(model, keys);
    this.setState(this.collectInitialState(model, keys));
  }

  render() {
    return (
      <div className="pair-setting setting">
        <h3>通貨ペアの設定</h3>
        <ul className="description">
          <li>システムで利用する通貨ペアを設定します。</li>
          <li>通貨ペアは、最大10個まで選択できます。</li>
        </ul>
        <div className="setting-body">
          <PairSelector ref="pairSelector" model={this.model()}/>
          <div className="buttons">
            <RaisedButton
              label="設定"
              primary={true}
              disabled={this.state.isSaving}
              onClick={this.save.bind(this)}
            />
            <span className="loading">
              {this.state.isSaving ? <LoadingImage size={20} /> : null}
            </span>
          </div>
          <div className="message">{this.state.message}</div>
        </div>
      </div>
    );
  }

  save() {
    this.model().save();
  }
  model() {
    return this.props.model;
  }
}
PairSettingView.propTypes = {
  model: React.PropTypes.object
};
PairSettingView.defaultProps = {
  model: null
};
