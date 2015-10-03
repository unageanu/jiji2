import React               from "react"
import MUI                 from "material-ui"

const ListItem   = MUI.ListItem;

export default class WebEnvironment {
  createListItem(props) {
    return <ListItem {...props} />;
  }
}
