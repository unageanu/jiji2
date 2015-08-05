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
      <Card initiallyExpanded={true} className={this.getClassName()}>
        <CardTitle
          title={this.getTitle()}
          titleColor={Theme.getPalette().textColorLight}
        ></CardTitle>
        <CardText style={{padding: "0px 16px 16px 16px"}}>
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
  createBody() {
    return "";
  }
}
