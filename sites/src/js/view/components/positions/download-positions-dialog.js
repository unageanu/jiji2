import React              from "react"

import Theme              from "../../theme"
import RangeSelector      from "../widgets/range-selector"
import AbstractComponent  from "../widgets/abstract-component"

import Dialog from "material-ui/Dialog"
import {RadioButton, RadioButtonGroup} from 'material-ui/RadioButton'
import FlatButton from "material-ui/FlatButton"

const keys = new Set([
  "downloadType"
]);

export default class DownloadPositionsDialog extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {open: false};
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
        actions={this.createActionButtons()}
        open={this.state.open}
        modal={true}
        contentClassName="dialog download-positions-dialog"
        contentStyle={Theme.dialog.contentStyle}
        onRequestClose={this.dismiss.bind(this)}>
        <div className="dialog-content">
          <div className="dialog-description">
            建玉データをCSV形式でダウンロードします。<br/>
            ダウンロードする範囲を選択して、[ダウンロード]をクリックしてください。
          </div>
          <div className="body">
            <RadioButtonGroup
              name="downloadType"
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
              ref={(ref) => this.rangeSelector = ref}
              model={this.props.model.rangeSelectorModel} />
          </div>
        </div>
      </Dialog>
    );
  }

  createActionButtons() {
    return [
      <FlatButton
        label="ダウンロード"
        primary={false}
        onTouchTap={this.downloadCSV.bind(this)}
      />, <FlatButton
        label="キャンセル"
        primary={false}
        onTouchTap={this.dismiss.bind(this)}
      />
    ];
  }

  onDownloadTypeChanged(ev, newValue) {
    this.props.model.downloadType = newValue;
  }

  downloadCSV() {
    this.rangeSelector.applySetting();
    this.props.model.createCSVDownloadUrl().then((url)=> {
      if (!url) return;
      this.dismiss();
      setTimeout( () => { window.location.href = url }, 500 );
      // delay for avoiding dialog problem on IE.
    });
  }
  show() {
    this.props.model.prepare();
    this.setState({open:true});
  }
  dismiss() {
    this.setState({open:false});
  }
}
DownloadPositionsDialog.propTypes = {
  model : React.PropTypes.object
};
DownloadPositionsDialog.defaultProps = {
};
