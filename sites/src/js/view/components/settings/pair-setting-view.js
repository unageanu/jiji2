import React                            from "react"
import { injectIntl, FormattedMessage } from 'react-intl';

import AbstractComponent   from "../widgets/abstract-component"
import LoadingImage        from "../widgets/loading-image"
import PairSelector        from "../widgets/pair-selector"

import RaisedButton from "material-ui/RaisedButton"
import TextField from "material-ui/TextField"

const keys = new Set([
  "message", "isSaving"
]);

class PairSettingView extends AbstractComponent {

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
    const { formatMessage } = this.props.intl;
    return (
      <div className="pair-setting setting">
        <h3><FormattedMessage id='settings.PairSettingView.title'/></h3>
        <ul className="description">
          <li><FormattedMessage id='settings.PairSettingView.description.part1'/></li>
          <li><FormattedMessage id='settings.PairSettingView.description.part2'/></li>
        </ul>
        <div className="setting-body">
          <PairSelector ref="pairSelector" model={this.model()}/>
          <div className="buttons">
            <RaisedButton
              label={formatMessage({ id: 'settings.PairSettingView.save' })}
              primary={true}
              disabled={this.state.isSaving}
              onClick={this.save.bind(this)}
            />
            <span className="loading-for-button-action">
              {this.state.isSaving ? <LoadingImage size={20} /> : null}
            </span>
          </div>
          <div className="message">{this.state.message}</div>
        </div>
      </div>
    );
  }

  save() {
    this.model().save(this.props.intl.formatMessage);
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
export default injectIntl(PairSettingView);
