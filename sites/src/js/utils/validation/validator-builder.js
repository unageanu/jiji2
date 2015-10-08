
import Validator           from "./validator"
import ValidationFunctions from "./validation-functions"

export default class ValidatorBuilder {

  build(restrictions) {
      const functions = this.createDefaultFunctions(restrictions);
      for ( let i in restrictions ) {
          const f = this.buildValidationFunction( i, restrictions[i] );
          if (f) functions.push( f );
      }
      return new Validator(functions);
  }

  createDefaultFunctions() {
    return [
      ValidationFunctions.controlCode // 制御文字は必ずチェックする。
    ];
  }
  buildValidationFunction(restrictionName, restriction){
    if ( ValidationFunctions[restrictionName] ) {
      const f = ValidationFunctions[restrictionName];
      return (value) => f(value, restriction);
    }
  }

}
