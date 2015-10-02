import ContainerJS         from "container-js"
import Observable          from "../../utils/observable"
import ValidationUtils     from "../utils/validation-utils"

export default class PairSelectorModel extends Observable {

  constructor(validator) {
    super();
    this.validator = validator;
  }

  initialize(availablePairs, defaultSelectedPairNames=[]) {
    this.availablePairs = availablePairs;
    this.pairNames = defaultSelectedPairNames;
  }

  validate( ) {
    return ValidationUtils.validate(this.validator, this.pairNames,
      {field: "通貨ペア"}, (error) => this.pairNamesError = error );
  }

  get pairNames() {
    return this.getProperty("pairNames");
  }
  set pairNames(pairNames) {
    this.setProperty("pairNames", pairNames);
  }
  get pairNamesError() {
    return this.getProperty("pairNamesError");
  }
  set pairNamesError(error) {
    this.setProperty("pairNamesError", error);
  }

  get availablePairs() {
    return this.getProperty("availablePairs");
  }
  set availablePairs(availablePairs) {
    this.setProperty("availablePairs", availablePairs);
  }

}
