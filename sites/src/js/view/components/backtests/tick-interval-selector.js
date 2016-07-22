import React              from "react"

import Theme              from "../../theme"
import AbstractComponent  from "../widgets/abstract-component"
import DropDownMenu       from "material-ui/DropDownMenu"
import MenuItem           from 'material-ui/MenuItem'

const emptyItems   = [{text:""}];

export default class TickIntervalSelector extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      selected: props.model.tickIntervalId
    };
  }

  render() {
    return (
      <DropDownMenu
        className="tick-interval-selector"
        value={this.state.selected}
        iconStyle={Object.assign({right:"8px"}, this.props.iconStyle)}
        underlineStyle={{margin: "0px"}}
        autoWidth={true}
        onChange={this.onChange.bind(this)}>
        <MenuItem key="fifteen_seconds"
          value="fifteen_seconds" primaryText="15秒" />
        <MenuItem key="one_minute" value="one_minute" primaryText="1分" />
        <MenuItem key="fifteen_minutes"
          value="fifteen_minutes" primaryText="15分" />
        <MenuItem key="thirty_minutes"
          value="thirty_minutes" primaryText="30分" />
        <MenuItem key="one_hour" value="one_hour" primaryText="1時間" />
        <MenuItem key="six_hours" value="six_hours" primaryText="6時間" />
        <MenuItem key="one_day" value="one_day" primaryText="1日" />
      </DropDownMenu>
    );
  }

  onChange(e, selectedIndex, payload) {
    this.props.model.tickIntervalId = payload;
    this.setState({selected: payload});
  }

}
