import ContainerJS         from "container-js"
import Observable          from "../../utils/observable"
import ValidationUtils     from "../utils/validation-utils"

export default class PairSelectorModel extends Observable {

  constructor(validator) {
    super();
    this.validator = validator;

    this.pairNamesError = null;
  }

  initialize(availablePairs, defaultSelectedPairNames=[]) {
    this.pairNamesError = null;
    this.availablePairs = availablePairs;
    this.pairNames = defaultSelectedPairNames;
  }

  validate(formatMessage) {
    return ValidationUtils.validate(this.validator, this.pairNames,
      {field: formatMessage({id:'validation.fields.pair'})}, (error) => this.pairNamesError = error, formatMessage );
  }

  update(checked, pair) {
    const pairNames = this.pairNames;
    if (checked) {
      if (!pairNames.find((p) => p == pair.name)) {
        pairNames.push(pair.name);
        this.setProperty("pairNames", pairNames, () => false);
      }
    } else {
      this.setProperty("pairNames",
        pairNames.filter((p) => p != pair.name), () => false);
    }
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
