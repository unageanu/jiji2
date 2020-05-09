import Error           from "../../model/error"
import ErrorMessages   from "../../errorhandling/error-messages"

export default class ValidationUtils {

  static validate(validator, value,
      errorMessageOption, errorHandler, formatMessage) {
    errorHandler(null);
    try {
      validator.validate(value);
      return true;
    } catch (error) {
      errorHandler(ErrorMessages.getMessageFor(formatMessage, error, errorMessageOption));
      return false;
    }
  }

}
