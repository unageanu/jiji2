import React          from "react"
import { injectIntl } from 'react-intl';

import AbstractList         from "../widgets/abstract-list"
import PositionListItem     from "./position-list-item"


class PositionList extends AbstractList {

  constructor(props) {
    super(props);
    this.state = {};
  }

  get className() {
    return "position-list";
  }
  get emptyLabel() {
    const { formatMessage } = this.props.intl;
    return formatMessage({ id: 'positions.PositionList.noItems' });
  }
  createListItem(position, index) {
    return <PositionListItem
      key={index}
      position={position}
      onTouchTap={this.createAction(position)}
      selected={
        this.state.selectedId === position.id
      } />;
  }
  createAction(position) {
    return (ev) => {
      this.context.router.push({
        pathname: "/rmt/positions/"+position.id
      });
      ev.preventDefault();
    };
  }
}
PositionList.propTypes = {
  model: React.PropTypes.object.isRequired,
  selectionModel: React.PropTypes.object,
  emptyLabel:  React.PropTypes.string,
  autoFill: React.PropTypes.bool
};
PositionList.defaultProps = {
  selectionModel: null,
  emptyLabel: "",
  autoFill: false
};
PositionList.contextTypes = {
  router: React.PropTypes.object,
  windowResizeManager: React.PropTypes.object
};

export default injectIntl(PositionList);
