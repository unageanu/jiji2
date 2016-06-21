import React   from "react"


import Avatar from "material-ui/Avatar"

export default class AgentIcon extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return  <Avatar src={this.createIconUrl()} {...this.props} />;
  }

  createIconUrl() {
    return this.props.urlResolver.resolveServiceUrl(
        "icon-images/" + (this.props.iconId || "default"));
  }
}
AgentIcon.propTypes = {
  iconId: React.PropTypes.string,
  urlResolver: React.PropTypes.object.isRequired
};
AgentIcon.defaultProps = {
  iconId: null
};
