import React               from "react"

import {List, ListItem} from "material-ui/List"

export default class WebEnvironment {
  createListItem(props) {
    return <ListItem {...props} />;
  }
}
