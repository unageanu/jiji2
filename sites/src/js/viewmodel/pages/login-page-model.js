import ContainerJS         from "container-js"
import AbstractPageModel   from "./abstract-page-model"
import Deferred            from "../../utils/deferred"
import Validators          from "../../utils/validation/validators"
import ValidationUtils     from "../utils/validation-utils"
import Error               from "../../model/error"

export default class LoginPageModel extends AbstractPageModel {

  constructor() {
    super();
    this.authenticator            = ContainerJS.Inject;
    this.sessionManager           = ContainerJS.Inject;
    this.passwordResettingService = ContainerJS.Inject;
    this.xhrManager               = ContainerJS.Inject;
    this.eventQueue               = ContainerJS.Inject;

    this.error = null;
    this.isAuthenticating = false;
    this.resettinMailSendingError = null;
    this.resettinMailSentMessage  = null;
    this.isSendingMail = false;
    this.tokenError = null;
    this.newPasswordError = null;
    this.passwordResettingError   = null;
    this.passwordResettingMessage = null;
    this.isResettingPassword = false;
  }

  postCreate() {}

  initialize() {
    this.error = null;
    this.isAuthenticating = false;
    this.resettinMailSendingError = null;
    this.resettinMailSentMessage  = null;
    this.isSendingMail = false;
    this.tokenError = null;
    this.newPasswordError = null;
    this.passwordResettingError   = null;
    this.passwordResettingMessage = null;
    this.isResettingPassword = false;
  }

  login(password) {
    if (!this.validatePassword(password)) return Deferred.errorOf({});

    this.error = null;
    this.isAuthenticating = true;
    return this.authenticator.login( password ).then((result) => {
      this.xhrManager.restart();
      this.isAuthenticating = false;
      this.eventQueue.push({ type: "routing", route: "/" });
      return result;
    }, (error)  => {
      if (error.code == Error.Code.UNAUTHORIZED) {
        this.error = "パスワードが一致していません";
        error.preventDefault = true;
      }
      this.isAuthenticating = false;
      throw error;
    });
  }

  sendPasswordResettingMail(mailaddress) {
    if (!this.validateMailAddress(mailaddress)) return Deferred.errorOf({});

    this.resettinMailSendingError = null;
    this.resettinMailSentMessage  = null;
    this.isSendingMail = true;
    return this.passwordResettingService.sendPasswordResettingMail(
      mailaddress).then((result) => {
        this.resettinMailSentMessage =
          "登録されているメールアドレスにトークンを記載したメールを送信しました。";
        this.isSendingMail = false;
      return result;
    }, (error)  => {
      if (error.code == Error.Code.INVALID_VALUE) {
        this.resettinMailSendingError =
          "入力されたメールアドレスがシステムに登録されているものと一致しませんでした。"
          + "メールアドレスを確認してください。";
        error.preventDefault = true;
      }
      this.isSendingMail = false;
      throw error;
    });
  }

  resetPassword(token, newPasword, newPasword2) {
    if (!this.validateNewPasswordAndToken(token, newPasword, newPasword2)) {
      return Deferred.errorOf({});
    }
    this.newPasswordError = null;
    this.tokenError = null;
    this.passwordResettingError = null;
    this.passwordResettingMessage = null;
    this.isResettingPassword = true;
    return this.passwordResettingService.resetPassword(
      token, newPasword ).then((result) => {
      this.isResettingPassword = false;
      this.passwordResettingMessage =
        "パスワードを再設定しました。新しいパスワードでログインしてご利用ください。";
    }, (error)  => {
      if (error.code == Error.Code.INVALID_VALUE) {
        this.passwordResettingError =
          "パスワードの再設定に失敗しました。トークンを確認してください。";
        error.preventDefault = true;
      }
      this.isResettingPassword = false;
      throw error;
    });
  }

  validatePassword(password) {
    return ValidationUtils.validate(Validators.loginPassword, password,
      {field: "パスワード"}, (error) => this.error = error );
  }
  validateMailAddress(mailAddress) {
    return ValidationUtils.validate(Validators.mailAddress, mailAddress,
      {field: "メールアドレス"}, (error) => this.resettinMailSendingError = error );
  }
  validateNewPasswordAndToken(token, password, password2) {
    return Validators.all(
      this.validateNewPassword(password, password2),
      ValidationUtils.validate(Validators.token, token,
        {field: "トークン"}, (error) => this.tokenError = error )
    );
  }
  validateNewPassword(password, password2) {
    this.newPasswordError = null;
    if (password !== password2) {
      this.newPasswordError = "パスワードが一致していません";
      return false;
    }
    return  ValidationUtils.validate(Validators.password, password,
        {field: "パスワード"}, (error) => this.newPasswordError = error );
  }

  get error() {
    return this.getProperty("error");
  }
  set error(error) {
    this.setProperty("error", error);
  }

  get isAuthenticating() {
    return this.getProperty("isAuthenticating");
  }
  set isAuthenticating(isAuthenticating) {
    this.setProperty("isAuthenticating", isAuthenticating);
  }


  get resettinMailSendingError() {
    return this.getProperty("resettinMailSendingError");
  }
  set resettinMailSendingError(resettinMailSendingError) {
    this.setProperty("resettinMailSendingError", resettinMailSendingError);
  }
  get resettinMailSentMessage() {
    return this.getProperty("resettinMailSentMessage");
  }
  set resettinMailSentMessage(resettinMailSentMessage) {
    this.setProperty("resettinMailSentMessage", resettinMailSentMessage);
  }
  get isSendingMail() {
    return this.getProperty("isSendingMail");
  }
  set isSendingMail(isSendingMail) {
    this.setProperty("isSendingMail", isSendingMail);
  }


  get newPasswordError() {
    return this.getProperty("newPasswordError");
  }
  set newPasswordError(newPasswordError) {
    this.setProperty("newPasswordError", newPasswordError);
  }
  get tokenError() {
    return this.getProperty("tokenError");
  }
  set tokenError(tokenError) {
    this.setProperty("tokenError", tokenError);
  }

  get passwordResettingError() {
    return this.getProperty("passwordResettingError");
  }
  set passwordResettingError(passwordResettingError) {
    this.setProperty("passwordResettingError", passwordResettingError);
  }
  get passwordResettingMessage() {
    return this.getProperty("passwordResettingMessage");
  }
  set passwordResettingMessage(passwordResettingMessage) {
    this.setProperty("passwordResettingMessage", passwordResettingMessage);
  }
  get isResettingPassword() {
    return this.getProperty("isResettingPassword");
  }
  set isResettingPassword(isResettingPassword) {
    this.setProperty("isResettingPassword", isResettingPassword);
  }
}
