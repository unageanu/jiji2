import React   from "react"


import Avatar from "material-ui/Avatar"

export default class AgentIcon extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    const {className, iconId, urlResolver, ...others} = this.props;
    return  <Avatar src={this.createIconUrl()}
      className={(className || "") + " agent-icon"}
      {...others} />;
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
