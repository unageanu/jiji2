import React              from "react"
import { injectIntl }     from 'react-intl';

import Theme              from "../../theme"
import AbstractComponent  from "../widgets/abstract-component"
import DropDownMenu       from "material-ui/DropDownMenu"
import MenuItem           from 'material-ui/MenuItem'

const emptyItems   = [{text:""}];

class TickIntervalSelector extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {
      selected: props.model.tickIntervalId
    };
  }

  render() {
    const { formatMessage } = this.props.intl;
    return (
      <DropDownMenu
        className="tick-interval-selector"
        value={this.state.selected}
        iconStyle={Object.assign({right:"8px"}, this.props.iconStyle)}
        underlineStyle={{margin: "0px"}}
        autoWidth={true}
        onChange={this.onChange.bind(this)}>
        <MenuItem key="fifteen_seconds"
          value="fifteen_seconds" primaryText={formatMessage({ id: 'common.tickInterval.fifteenSeconds' })} />
        <MenuItem key="one_minute" value="one_minute" primaryText={formatMessage({ id: 'common.tickInterval.oneMinute' })} />
        <MenuItem key="fifteen_minutes"
          value="fifteen_minutes" primaryText={formatMessage({ id: 'common.tickInterval.fifteenMinutes' })} />
        <MenuItem key="thirty_minutes"
          value="thirty_minutes" primaryText={formatMessage({ id: 'common.tickInterval.thirtyMinutes' })} />
        <MenuItem key="one_hour" value="one_hour" primaryText={formatMessage({ id: 'common.tickInterval.oneHour' })} />
        <MenuItem key="six_hours" value="six_hours" primaryText={formatMessage({ id: 'common.tickInterval.sixHours' })} />
        <MenuItem key="one_day" value="one_day" primaryText={formatMessage({ id: 'common.tickInterval.oneDay' })} />
      </DropDownMenu>
    );
  }

  onChange(e, selectedIndex, payload) {
    this.props.model.tickIntervalId = payload;
    this.setState({selected: payload});
  }

}

export default injectIntl(TickIntervalSelector);
