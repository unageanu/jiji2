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
    return this.state.loading ? <LoadingImage {...this.props} /> : null;
  }
}
LoadingView.propTypes = {
  xhrManager:  React.PropTypes.object.isRequired
};
