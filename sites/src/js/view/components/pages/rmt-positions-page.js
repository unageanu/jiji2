import React            from "react"
import MUI              from "material-ui"
import AbstractPage     from "./abstract-page"
import PositionsTable   from "../positions/positions-table"

export default class RMTPositionsPage extends AbstractPage {

  constructor(props) {
    super(props);
    this.state = {};
  }

  componentWillMount() {
    const model = this.model();
    model.initialize(this.props.params.id);
  }

  componentWillReceiveProps(nextProps) {
    this.model().selection.selectedId = nextProps.params.id;
  }

  render() {
    return (
      <div className="rmt-positions-page">
        <PositionsTable
          model={this.model().positionTable}
          selectionModel={this.model().selection} />
      </div>
    );
  }

  model() {
    return this.context.application.rmtPositionsPageModel;
  }
}
RMTPositionsPage.contextTypes = {
  application: React.PropTypes.object.isRequired,
  router: React.PropTypes.func
};
