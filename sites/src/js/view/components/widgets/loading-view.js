import React        from "react"
import LoadingImage from "./loading-image"

export default class LoadingView extends React.Component {

  constructor(props) {
    super(props);
    this.state = {loading:false};
  }

  componentWillMount() {
    this.props.xhrManager.addObserver("startLoading",
      () => this.setState({loading:true}), this);
    this.props.xhrManager.addObserver("endLoading",
      () => this.setState({loading:false}), this);
  }
  componentWillUnmount() {
    this.props.xhrManager.removeAllObservers(this);
  }

  render() {
    return <LoadingImage 
      status={this.state.loading ? "loading" : "hide"}
      {...this.props} />;
  }
}
LoadingView.propTypes = {
  xhrManager:  React.PropTypes.object.isRequired
};
