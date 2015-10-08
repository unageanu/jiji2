import React              from "react"
import MUI                from "material-ui"
import AgentClassSelector from "./agent-class-selector"
import Theme              from "../../theme"

const Dialog       = MUI.Dialog;

export default class AgentSelectorDialog extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <Dialog
        ref="dialog"
        title=""
        actions={[{text: "キャンセル"}]}
        modal={true}
        className="dialog"
        contentStyle={Theme.dialog.contentStyle}>
        <div className="dialog-content">
          <div className="dialog-description">追加するエージェントを選択してください。</div>
          <AgentClassSelector
            classes={this.props.availableAgents}
            onSelect={this.props.onSelect}
          />
        </div>
      </Dialog>
    );
  }

  show() {
    this.refs.dialog.show();
  }
  dismiss(agent) {
    this.refs.dialog.dismiss();
  }
}
AgentSelectorDialog.propTypes = {
  availableAgents : React.PropTypes.array,
  onSelect : React.PropTypes.func
};
AgentClassSelector.defaultProps = {
  availableAgents: [],
  onSelect: (agentClass) => {}
};
