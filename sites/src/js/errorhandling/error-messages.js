import ContainerJS   from "container-js"
import _             from "underscore"
import Error         from "../model/error"


const messages = {
  NETWORK_ERROR: "サーバーに接続できませんでした。ネットワーク接続を確認してください",
  SERVER_ERROR: "サーバーでエラーが発生しました",

  OPERATION_NOT_ALLOWED: "操作が許可されていません",
  SERVER_BUSY : "サーバーが混雑しています。しばらく待ってからやり直してください",


  NOT_FOUND : "<%- entity %>が見つかりません。"
              + "画面を再読み込みして最新の情報に更新してください",
  IS_EMPTY :  "<%- field %>を入力してください",
  LOGIN_FAILED : "メールアドレスとパスワードが一致しません",
  PASSWORDS_ARE_NOT_EQUAL : "パスワードが一致していません",

  EXPIRED : "入力された<%- field %>は有効期限が切れているため、ご利用頂けません",

  NOT_NULL : "<%- field %>を入力してください",
  NOT_EMPTY : "<%- field %>が設定されていません",
  MAX_LENGTH : "<%- field %>が長すぎます",
  MIN_LENGTH : "<%- field %>が短すぎます",
  PATTERN :    "<%- field %>の形式が不正です",
  PROHIBITED_CHARACTER : "<%- field %>に使用できない文字"
                         + "「<%- character %>」が含まれています",
  CONTROL_CODE : "<%- field %>に不正な文字が含まれています",
  NOT_NUMBER : "<%- field %>は半角数字で入力してください",
  NOT_NUMBER_OR_HYPHEN : "<%- field %>は半角数字またはハイフン(-)で入力してください",
  NOT_ALPHABET : "<%- field %>は半角英数字、または記号で入力してください",
  NOT_KATAKANA : "<%- field %>は全角カタカナで入力してください",
  NOT_HIRAGANA : "<%- field %>は全角ひらがなで入力してください",
  MAX : "<%- field %>に最大値より大きい値が設定されています",
  MIN : "<%- field %>に最小値より小さい値が設定されています",
  RANGE : "<%- field %>の値が範囲外です",
  SIZE : "<%- field %>は<%- size%>つ以上選択できません",
  INVALID_VALUE : "<%- field %>が正しく入力されていません"
};

export default class ErrorMessages {

  static getMessageFor(error, param={}) {
    const template = _.template(this.getMessageTemplateFor(error));
    return template(this.getMessageParams(error, param));
  }

  static getMessageTemplateFor(error) {
    if (error.code === "CANCELED") return "";
    return error.message
        || messages[error.code]
        || messages.SERVER_ERROR;
  }

  static getMessageParams(error, param) {
    return this.defaults(param, error, error.detail || {}, {
      field: "値",
      entity: "データ"
    });
  }
  static defaults(...args) {
    return args.reduce((r, n) => _.defaults(r, n), {});
  }
}
