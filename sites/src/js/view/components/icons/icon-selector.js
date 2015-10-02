import React              from "react"
import MUI                from "material-ui"
import Dropzone           from "react-dropzone"
import AbstractComponent  from "../widgets/abstract-component"
import LoadingImage       from "../widgets/loading-image"
import AgentIcon          from "../widgets/agent-icon"

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
        <div className="icon">
          <AgentIcon
            iconId={this.state.selectedId}
            urlResolver={this.props.model.icons.iconService.urlResolver} />
        </div>
        <div className="action">
          <a onTouchTap={this.showDialog.bind(this)}>変更...</a>
        </div>
        <Dialog
          ref="iconSelectorDialog"
          title=""
          actions={[{ text: 'キャンセル' }]}
          modal={true}
        >
          <div className="contnet">
            <div className="">
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
        return <Dropzone onDrop={this.onDrop.bind(this)} className="drop-area">
        <div className="error">{this.state.error}</div>
        <div>アイコンを追加したい場合は、画像をここにドロップしてください。</div>
        <ul>
          <li>png/jpg/gif形式の画像を登録できます。</li>
          <li>画像のサイズは100KBまで。</li>
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
        onTouchTap={(ev) => this.onIconSelected(ev, icon)} >
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
