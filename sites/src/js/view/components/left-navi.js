import React  from "react"
import { Router } from 'react-router'

import {List, ListItem} from "material-ui/List"
import Divider          from "material-ui/Divider"
import Subheader        from 'material-ui/Subheader'

export default class LeftNavi extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    const currentRoute = this.getCurrntRoute();
    if (currentRoute && currentRoute.fullscreen) {
      return null;
    } else {
      const lists = this.createLists();
      return (
        <div className="left-navi">
          {lists}
        </div>
      );
    }
  }

  getCurrntRoute() {
    return this.navigator().menuItems().find(
      (item) => item.route && this.router().isActive(item.route));
  }

  createLists() {
    let lists  = [];
    let buffer = [];
    let label  = "";
    this.navigator().menuItems().forEach((item)=> {
      if (item.type === "header") {
        lists.push(this.createList( label, buffer, lists.length));
        lists.push(<Divider key={lists.length+"_divider"}/>);
        buffer = [];
        label  = item.text;
      } else{
        if (item.hidden !== true) buffer.push( this.createListItem(item) );
      }
    });
    lists.push(this.createList( label, buffer, lists.length));
    return lists;
  }

  createList(label, items, index) {
    return <List key={index} style={this.createListStyle(label)}>
      <Subheader>{label}</Subheader>
      {items}
    </List>;
  }

  createListStyle(hasLabel) {
    return hasLabel ? {} : { paddingTop: this.context.muiTheme.spacing.grid };
  }

  createListItem(item, index) {
    const selected = this.isActive(item.route);
    const action   = (e) => this.onLeftNavChange(e, null, item);
    const icon     = <div className={ "menu-icon " + item.iconClassName} />;
    return (
      <ListItem
        key={item.route}
        className={"mui-menu-item" + (selected ? " mui-is-selected" : "")}
        leftIcon={icon}
        primaryText={item.text}
        onTouchTap={action}>
      </ListItem>
    );
  }

  isActive(route) {
    const indexOnly = route === "/";
    return this.router().isActive({ pathname:route }, indexOnly);
  }

  onLeftNavChange(e, key, payload) {
    this.router().push({pathname: payload.route});
    this.googleAnalytics().sendEvent("view " + payload.route);
  }

  navigator() {
    return this.context.application.navigator;
  }
  googleAnalytics() {
    return this.context.application.googleAnalytics;
  }
  router() {
    return this.context.router;
  }
}
LeftNavi.contextTypes = {
  application: React.PropTypes.object.isRequired,
  router: React.PropTypes.object.isRequired,
  muiTheme: React.PropTypes.object.isRequired
};
