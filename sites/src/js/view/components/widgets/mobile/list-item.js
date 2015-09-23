import React               from "react"
import MUI                 from "material-ui"

export default class ListItem extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <div
        className={"list-item darken " + (this.state.tapped ? " on" : "" )}
        style={{
          cursor: this.props.onTouchTap ? "pointer" : "auto"
        }}
        onTouchTap={this.createAction()}>
        <MUI.ListItem
          disabled={true}
          {...this.props} />
      </div>
    );
  }
  createAction() {
    if (!this.props.onTouchTap) return () => {};
    return (ev) => {
      this.setState({tapped:true});
      ev.preventDefault();
      setTimeout(()=> {
        this.setState({tapped:false});
        this.props.onTouchTap(ev);
      }, 200);
    };
  }
}
