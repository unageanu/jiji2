import React               from "react"
import MUI                 from "material-ui"
import AbstractComponent   from "../widgets/abstract-component"
import LoadingImage        from "../widgets/loading-image"

const RaisedButton = MUI.RaisedButton;
const TextField    = MUI.TextField;
const DropDownMenu = MUI.DropDownMenu;

const keys = new Set([
  "availableSecurities", "activeSecuritiesConfiguration",
  "activeSecuritiesId", "error", "message", "isSaving"
]);

export default class SecuritiesSettingView extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      availableSecurities: [],
      selectedSecuritiesIndex: 0,
      activeSecuritiesConfiguration: [],
      error:   null,
      message: null
    };
  }

  componentWillMount() {
    const model = this.model();
    this.registerPropertyChangeListener(model, keys);
    let state = this.collectInitialState(model, keys);
    state.selectedSecuritiesIndex = this.getSelectedSecuritiesIndex(
      model.activeSecuritiesId, model.availableSecurities);
    this.setState(state);
  }

  render() {
    const securitiesSelector = this.creattSecuritiesSelector();
    const activeSecuritiesConfigurator = this.createConfigurator();
    return (
      <div className="securities-setting setting">
        <h3>証券会社の設定</h3>
        <ul className="description">
          <li>使用する証券会社を設定します。</li>
          <li>
            アクセストークンの取得方法は<a href="/">こちら</a>をご覧ください。
          </li>
        </ul>
        <div className="setting-body">
          {securitiesSelector}
          <div className="securities">
            {activeSecuritiesConfigurator}
          </div>
          <div className="buttons">
            {this.createErrorContent(this.state.error)}
            <RaisedButton
              label="設定"
              primary={true}
              disabled={this.state.availableSecurities.length == 0 || this.state.isSaving}
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

  creattSecuritiesSelector() {
    if (this.state.availableSecurities.length <= 0) return null;
    return <DropDownMenu
      menuItems={this.state.availableSecurities}
      selectedIndex={this.state.selectedSecuritiesIndex}
      onChange={this.onChangeSecurities.bind(this)}
      labelStyle={{
        padding: "0px"
      }}
      underlineStyle={{margin: "0px"}} />;
  }
  createConfigurator() {
    if (this.state.availableSecurities.length <= 0) return null;
    if (!this.state.activeSecuritiesConfiguration) return null;
    return this.state.activeSecuritiesConfiguration.map((c) => {
      return  <TextField
          ref={"securities_configuration_" + c.id}
          floatingLabelText={c.description}
          defaultValue={c.value}
          style={{ width: "100%" }} />;
    });
  }

  save() {
    this.model().save(this.collectConfigurations());
  }

  onPropertyChanged(k, ev) {
    if (ev.key === "activeSecuritiesId") {
      this.setState({
        selectedSecuritiesIndex:
          this.getSelectedSecuritiesIndex(ev.newValue)
      });
    } else {
      super.onPropertyChanged(k, ev);
    }
  }
  onChangeSecurities(e, selectedIndex, menuItem) {
    this.model().activeSecuritiesId =
      this.state.availableSecurities[selectedIndex].id;
    this.setState({selectedSecuritiesIndex: selectedIndex});
  }

  collectConfigurations() {
    return this.state.activeSecuritiesConfiguration.reduce((r, c) => {
      r[c.id] = this.refs["securities_configuration_" + c.id].getValue();
      return r;
    }, {});
  }
  getSelectedSecuritiesIndex(id, securities=this.state.availableSecurities) {
    let index = 0;
    securities.forEach((item, i) => {
      if (item.id === id) index = i;
    });
    return index;
  }

  model() {
    return this.props.model;
  }
}
SecuritiesSettingView.propTypes = {
  model: React.PropTypes.object
};
SecuritiesSettingView.defaultProps = {
  model: null
};
