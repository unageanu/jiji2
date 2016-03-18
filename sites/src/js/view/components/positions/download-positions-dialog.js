import React              from "react"
import MUI                from "material-ui"
import Theme              from "../../theme"
import RangeSelector      from "../widgets/range-selector"
import AbstractComponent  from "../widgets/abstract-component"

const Dialog            = MUI.Dialog;
const RadioButtonGroup  = MUI.RadioButtonGroup;
const RadioButton       = MUI.RadioButton;

const keys = new Set([
  "downloadType"
]);

export default class DownloadPositionsDialog extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentWillMount() {
    this.registerPropertyChangeListener(this.props.model, keys);
    const state = this.collectInitialState(this.props.model, keys);
    this.setState(state);
  }

  render() {
    const labelForAll = <span>
      すべての建玉をダウンロードする<br/>
      <span className="info">
        ※建玉が多いと時間がかかる場合があります。ご注意ください。
      </span>
    </span>;
    return (
      <Dialog
        ref="dialog"
        title=""
        actions={[
          { text: "ダウンロード", onTouchTap: () => this.downloadCSV()  },
          { text: "キャンセル"}
        ]}
        modal={true}
        contentClassName="dialog download-positions-dialog"
        contentStyle={Theme.dialog.contentStyle}>
        <div className="dialog-content">
          <div className="dialog-description">
            建玉データをCSV形式でダウンロードします。<br/>
            ダウンロードする範囲を選択して、[ダウンロード]をクリックしてください。
          </div>
          <div className="body">
            <RadioButtonGroup ref="downloadType" name="downloadType"
              valueSelected={this.state.downloadType}
              onChange={this.onDownloadTypeChanged.bind(this)}>
              <RadioButton
                value="all"
                label={labelForAll}>
              </RadioButton>
              <RadioButton
                value="filterd"
                label="エントリー日時で絞り込む">
              </RadioButton>
            </RadioButtonGroup>
            <RangeSelector
              ref="rangeSelector"
              model={this.props.model.rangeSelectorModel} />
          </div>
        </div>
      </Dialog>
    );
  }

  onDownloadTypeChanged(ev, newValue) {
    this.props.model.downloadType = newValue;
  }

  downloadCSV() {
    this.refs.rangeSelector.applySetting();
    this.props.model.createCSVDownloadUrl().then((url)=> {
      if (!url) return;
      this.refs.dialog.dismiss();
      setTimeout( () => { window.location.href = url }, 500 );
      // delay for avoiding dialog problem on IE.
    });
  }
  show() {
    this.props.model.prepare();
    this.refs.dialog.show();
  }
}
DownloadPositionsDialog.propTypes = {
  model : React.PropTypes.object
};
DownloadPositionsDialog.defaultProps = {
};
