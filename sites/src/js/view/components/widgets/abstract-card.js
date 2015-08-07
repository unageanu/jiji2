import React              from "react"
import Router             from "react-router"
import MUI                from "material-ui"
import AbstractComponent  from "../widgets/abstract-component"
import Theme              from "../../theme"

const Card       = MUI.Card;
const CardTitle  = MUI.CardTitle;
const CardText   = MUI.CardText;

export default class AbstractCard extends AbstractComponent {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <Card initiallyExpanded={true} className={"card " + this.getClassName()}>
        {this.createTitle()}
        <CardText style={this.getBodyContentStyle()}>
          {this.createBody()}
        </CardText>
      </Card>
    );
  }

  getClassName() {
    return "";
  }
  getTitle() {
    return "";
  }
  getBodyContentStyle() {
    return {padding: "0px 16px 16px 16px"};
  }
  createTitle() {
    const title = this.getTitle();
    if (!title) return null;
    return <CardTitle
      title={title}
      titleColor={Theme.getPalette().textColorLight}
    ></CardTitle>;
  }

  createBody() {
    return "";
  }
}
