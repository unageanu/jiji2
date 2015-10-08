import Error from "../../model/error"

export default class Validator {

  constructor(restrictions) {
    this.restrictions = restrictions;
  }

  validate(value) {
    const result = [];
    this.restrictions.forEach( (restriction) => {
      const error = restriction(value);
      if (error) result.push(error);
    });
    if ( result.length > 0 ) {
      Error.rise({
        code:   result[0].type,
        detail: result[0]
      });
    }
  }

}
