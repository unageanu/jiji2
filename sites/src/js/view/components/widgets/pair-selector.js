import React              from "react"
import MUI                from "material-ui"
import AbstractComponent  from "../widgets/abstract-component"

const Checkbox     = MUI.Checkbox;

const keys = new Set([
  "availablePairs", "pairNames", "pairNamesError"
]);

export default class PairSelector extends AbstractComponent  {

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
    const error = this.state.pairNamesError
      ? <div className="error">{this.state.pairNamesError}</div>
      : null;
    return (
      <div className="pair-selector">
        {error}
        <div className="selector">
          {this.createSelectors()}
        </div>
      </div>
    );
  }

  createSelectors() {
    const selected = new Set(this.state.pairNames);
    return (this.state.availablePairs||[]).map((pair) => {
      return <Checkbox
        ref={pair.name}
        key={pair.name}
        defaultChecked={selected.has(pair.name)}
        name={pair.name}
        value={pair.name}
        label={pair.name}
        style={{
          width:   "120px",
          display: "inline-block"
        }} />;
    });
  }

  applySetting() {
    this.props.model.pairNames = this.selectedPairNames;
  }

  get selectedPairNames() {
    return this.state.availablePairs
      .filter((pair) => this.refs[pair.name].isChecked())
      .map((pair) => pair.name );
  }
}
PairSelector.propTypes = {
  model: React.PropTypes.object.isRequired
};
PairSelector.defaultProps = {
};
