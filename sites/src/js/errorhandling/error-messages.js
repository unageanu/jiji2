import _             from "underscore"

const messages = {
  NETWORK_ERROR: "validation.messages.networkError",
  SERVER_ERROR: "validation.messages.serverError",

  OPERATION_NOT_ALLOWED: "validation.messages.operationNotAllowed",
  SERVER_BUSY : "validation.messages.serverBusy",


  NOT_FOUND : "validation.messages.notFound",
  IS_EMPTY :  "validation.messages.isEmpty",
  LOGIN_FAILED : "validation.messages.loginFailed",
  PASSWORDS_ARE_NOT_EQUAL : "validation.messages.mismatchPassword",

  EXPIRED : "validation.messages.expired",

  NOT_NULL : "validation.messages.notNull",
  NOT_EMPTY : "validation.messages.notEmpty",
  MAX_LENGTH : "validation.messages.maxLength",
  MIN_LENGTH : "validation.messages.minLength",
  PATTERN :    "validation.messages.pattern",
  PROHIBITED_CHARACTER : "validation.messages.prohibitedCharacter",
  CONTROL_CODE : "validation.messages.controlCode",
  NOT_NUMBER : "validation.messages.notNumber",
  NOT_NUMBER_OR_HYPHEN : "validation.messages.notNumberOrHyphen",
  NOT_ALPHABET : "validation.messages.notAlphabet",
  NOT_KATAKANA : "validation.messages.notKatakana",
  NOT_HIRAGANA : "validation.messages.notHiragana",
  MAX : "validation.messages.max",
  MIN : "validation.messages.min",
  RANGE : "validation.messages.range",
  SIZE : "validation.messages.size",
  INVALID_VALUE : "validation.messages.invalidValue"
};

export default class ErrorMessages {

  static getMessageFor(formatMessage, error, param={}) {
    return formatMessage({id: this.getMessageTemplateFor(error)},
      this.getMessageParams(error, param, formatMessage));
  }

  static getMessageTemplateFor(error) {
    if (error.code === "CANCELED") return "";
    return error.message
        || messages[error.code]
        || messages.SERVER_ERROR;
  }

  static getMessageParams(error, param, formatMessage) {
    return this.defaults(param, error, error.detail || {}, {
      field: formatMessage({id: 'validation.fields.value'}),
      entity: formatMessage({id: 'validation.fields.data'})
    });
  }
  static defaults(...args) {
    return args.reduce((r, n) => _.defaults(r, n), {});
  }
}
