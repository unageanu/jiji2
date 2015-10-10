import React             from "react"
import Router            from "react-router"
import MUI               from "material-ui"

export default class SummaryItem extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <div className="summary-item">
        <div className="label">{this.props.label}</div>
        <div className="primary-value">
          <span className="value">{this.props.value}</span>
        </div>
        <div className="sub-contents">
          {this.createSubContents()}
        </div>
      </div>
    );
  }

  createSubContents() {
    return this.props.subContents.map( (content, index) => {
      return <div className="item" key={index}>
        <div className="label">{content.label}</div>
        <div className="value">{content.value}</div>
      </div>
    });
  }
}

SummaryItem.propTypes = {
  label: React.PropTypes.string.isRequired,
  subContents: React.PropTypes.array
};
SummaryItem.defaultProps = {
  subContents: []
};
