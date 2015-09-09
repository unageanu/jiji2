import React               from "react"
import MUI                 from "material-ui"
import AbstractComponent   from "../widgets/abstract-component"

const RaisedButton = MUI.RaisedButton;
const TextField    = MUI.TextField;
const DropDownMenu = MUI.DropDownMenu;

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
    this.registerPropertyChangeListener(model);
    const selectedIndex = this.getSelectedSecuritiesIndex(
      model.activeSecuritiesId, model.availableSecurities);
    this.setState({
      availableSecurities:            model.availableSecurities,
      activeSecuritiesConfiguration:  model.activeSecuritiesConfiguration,
      error:                          model.error,
      message:                        model.message,
      selectedSecuritiesIndex:        selectedIndex
    });
  }
  componentWillUnmount() {
    this.model().removeAllObservers(this);
  }

  render() {
    const securitiesSelector = this.creattSecuritiesSelector();
    const activeSecuritiesConfigurator = this.createConfigurator();
    return (
      <div className="securities-setting">
        <h3>証券会社の設定</h3>
        {securitiesSelector}
        <div>
          {activeSecuritiesConfigurator}
        </div>
        <br/>
        <RaisedButton
          label="設定"
          disabled={!this.state.availableSecurities.length > 0}
          onClick={this.save.bind(this)}
        />
        <div className="message">{this.state.message}</div>
        <div className="error">{this.state.error}</div>
      </div>
    );
  }

  creattSecuritiesSelector() {
    if (this.state.availableSecurities.length <= 0) return null;
    return <DropDownMenu
      menuItems={this.state.availableSecurities}
      selectedIndex={this.state.selectedSecuritiesIndex}
      onChange={this.onChangeSecurities.bind(this)}/>;
  }
  createConfigurator() {
    if (this.state.availableSecurities.length <= 0) return null;
    if (!this.state.activeSecuritiesConfiguration) return null;
    return this.state.activeSecuritiesConfiguration.map((c) => {
      return  <TextField
          ref={"securities_configuration_" + c.id}
          floatingLabelText={c.description}
          defaultValue={c.value} />;
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
