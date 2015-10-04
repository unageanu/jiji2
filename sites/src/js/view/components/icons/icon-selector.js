import React              from "react"
import MUI                from "material-ui"
import Dropzone           from "react-dropzone"
import AbstractComponent  from "../widgets/abstract-component"
import LoadingImage       from "../widgets/loading-image"
import AgentIcon          from "../widgets/agent-icon"
import Theme              from "../../theme"

const FlatButton = MUI.FlatButton;
const Dialog     = MUI.Dialog;

const keys = new Set([
  "icons"
]);
const modelKeys = new Set([
  "selectedId"
]);

export default class IconSelector extends AbstractComponent  {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentWillMount() {
    this.registerPropertyChangeListener(this.props.model, modelKeys);
    this.registerPropertyChangeListener(this.props.model.icons, keys);
    const state = Object.assign(
      this.collectInitialState(this.props.model, modelKeys),
      this.collectInitialState(this.props.model.icons, keys));
    this.setState(state);
  }

  render() {
    return (
      <div className="icon-selector">
        <div className="icon-and-action">
          <AgentIcon className="icon"
            iconId={this.state.selectedId}
            onTouchTap={this.showDialog.bind(this)}
            urlResolver={this.props.model.icons.iconService.urlResolver} />
          <a onTouchTap={this.showDialog.bind(this)}>変更...</a>
        </div>
        <Dialog
          ref="iconSelectorDialog"
          title=""
          actions={[{ text: 'キャンセル' }]}
          modal={true}
          className="dialog"
          contentStyle={Theme.dialog.contentStyle}>
          <div className="dialog-content">
            <div className="dialog-description">使用するアイコンを選択してください。</div>
            <div className="icons">
              {this.createIcons()}
            </div>
            {this.createDropzone()}
          </div>
        </Dialog>
      </div>
    );
  }

  createDropzone() {
    if (this.state.uploading) {
      return <div className="center-information loading">
        <LoadingImage left={-20}/>
      </div>;
    } else {
      const error = this.state.error
        ? <div className="error">{this.state.error}</div>: null
      return <Dropzone onDrop={this.onDrop.bind(this)} className="drop-area">
        {error}
        <div>アイコンを追加したい場合は、画像をここにドロップしてください。</div>
        <ul>
          <li>png/jpg/gif形式の画像を登録できます。</li>
          <li>画像のサイズは最大100KBまで。</li>
        </ul>
      </Dropzone>;
    }
  }

  showDialog(ev) {
    this.setState({ error: null});
    this.refs.iconSelectorDialog.show();
    ev.preventDefault();
  }

  createIcons() {
    return (this.state.icons||[]).map((icon, index) => {
      return <FlatButton
        className="icon"
        key={index}
        onTouchTap={(ev) => this.onIconSelected(ev, icon)}
        style={{
          lineHeight: "normal",
          minWidth: "56px",
          width: "56px",
          padding: "8px"
        }}
        labelStyle={{
          lineHeight: "normal"
        }}>
        <AgentIcon
          iconId={icon.id}
          urlResolver={this.props.model.icons.iconService.urlResolver} />
      </FlatButton>;
    });
  }

  onIconSelected(ev, icon) {
    this.props.model.selectedId = icon.id;
    this.refs.iconSelectorDialog.dismiss();
    ev.preventDefault();
  }

  onDrop(files) {
    this.setState({
      uploading:true,
      error: null
    });
    this.props.model.icons.add(files[0]).then(
      () => this.setState({uploading:false}),
      (error) => {
        this.setState({
          uploading:false,
          error: "アップロードに失敗しました。画像の形式/サイズをご確認ください。"
        });
        error.preventDefault = true;
      });
  }

}
IconSelector.propTypes = {
  model: React.PropTypes.object.isRequired,
  enableUpload: React.PropTypes.bool
};
IconSelector.defaultProps = {
  enableUpload: false
};
