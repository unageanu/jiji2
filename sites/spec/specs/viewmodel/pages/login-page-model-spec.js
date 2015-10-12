import ContainerJS      from "container-js"
import ContainerFactory from "../../../utils/test-container-factory"
import Deferred         from "src/utils/deferred"

describe("LoginPageModel", () => {

  var model;
  var xhrManager;
  var eventQueue;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("loginPageModel");
    model = ContainerJS.utils.Deferred.unpack(d);
    xhrManager = model.xhrManager;
    eventQueue = model.eventQueue;
  });

  describe("initialize", () => {
    it("初期状態", () => {
      model.initialize();
      expect(model.error).toEqual(null);
      expect(model.isAuthenticating).toEqual(false);
      expect(model.resettinMailSendingError).toEqual(null);
      expect(model.resettinMailSentMessage).toEqual(null);
      expect(model.isSendingMail).toEqual(false);
      expect(model.tokenError).toEqual(null);
      expect(model.newPasswordError).toEqual(null);
      expect(model.passwordResettingError).toEqual(null);
      expect(model.passwordResettingMessage).toEqual(null);
      expect(model.isResettingPassword).toEqual(false);
      expect(eventQueue.queue).toEqual([]);
    });
  });

  describe("login", () => {
    it("正しいパスワードを指定してログインできる", () => {
      const d = model.login("test");
      expect(model.error).toEqual(null);
      expect(model.isAuthenticating).toEqual(true);
      xhrManager.requests[0].resolve({ticket:"aaaa"});

      expect(model.error).toEqual(null);
      expect(model.isAuthenticating).toEqual(false);
      expect(model.resettinMailSendingError).toEqual(null);
      expect(model.resettinMailSentMessage).toEqual(null);
      expect(model.isSendingMail).toEqual(false);
      expect(model.tokenError).toEqual(null);
      expect(model.newPasswordError).toEqual(null);
      expect(model.passwordResettingError).toEqual(null);
      expect(model.passwordResettingMessage).toEqual(null);
      expect(model.isResettingPassword).toEqual(false);
      expect(eventQueue.queue).toEqual([
        { type: "routing", route: "/" }
      ]);
      expect(Deferred.unpack(d)).not.toBe(null);
    });
    it("パスワードが入力されていない場合", () => {
      const d = model.login("");
      expect(model.error).toEqual("パスワードを入力してください");
      expect(model.isAuthenticating).toEqual(false);
      expect(model.resettinMailSendingError).toEqual(null);
      expect(model.resettinMailSentMessage).toEqual(null);
      expect(model.isSendingMail).toEqual(false);
      expect(model.tokenError).toEqual(null);
      expect(model.newPasswordError).toEqual(null);
      expect(model.passwordResettingError).toEqual(null);
      expect(model.passwordResettingMessage).toEqual(null);
      expect(model.isResettingPassword).toEqual(false);
      expect(() => Deferred.unpack(d)).toThrow();
      expect(eventQueue.queue).toEqual([]);
    });
    it("認証エラーになった場合", () => {
      const d = model.login("test");
      expect(model.error).toEqual(null);
      expect(model.isAuthenticating).toEqual(true);
      xhrManager.requests[0].reject({statusCode:401});

      expect(model.error).toEqual("パスワードが一致していません");
      expect(model.isAuthenticating).toEqual(false);
      expect(model.resettinMailSendingError).toEqual(null);
      expect(model.resettinMailSentMessage).toEqual(null);
      expect(model.isSendingMail).toEqual(false);
      expect(model.tokenError).toEqual(null);
      expect(model.newPasswordError).toEqual(null);
      expect(model.passwordResettingError).toEqual(null);
      expect(model.passwordResettingMessage).toEqual(null);
      expect(model.isResettingPassword).toEqual(false);
      expect(() => Deferred.unpack(d)).toThrow();
      expect(eventQueue.queue).toEqual([]);
    });
    it("通信エラーになった場合", () => {
      const d = model.login("test");
      expect(model.error).toEqual(null);
      expect(model.isAuthenticating).toEqual(true);
      xhrManager.requests[0].reject({statusCode:500});

      expect(model.error).toEqual(null);
      expect(model.isAuthenticating).toEqual(false);
      expect(model.resettinMailSendingError).toEqual(null);
      expect(model.resettinMailSentMessage).toEqual(null);
      expect(model.isSendingMail).toEqual(false);
      expect(model.tokenError).toEqual(null);
      expect(model.newPasswordError).toEqual(null);
      expect(model.passwordResettingError).toEqual(null);
      expect(model.passwordResettingMessage).toEqual(null);
      expect(model.isResettingPassword).toEqual(false);
      expect(() => Deferred.unpack(d)).toThrow();
      expect(eventQueue.queue).toEqual([]);
    });
  });

  describe("sendPasswordResettingMail", () => {
    it("パスワードリセットメールを送信できる", () => {
      const d = model.sendPasswordResettingMail("foo@example.com");
      expect(model.resettinMailSendingError).toEqual(null);
      expect(model.resettinMailSentMessage).toEqual(null);
      expect(model.isSendingMail).toEqual(true);
      xhrManager.requests[0].resolve({});

      expect(model.error).toEqual(null);
      expect(model.isAuthenticating).toEqual(false);
      expect(model.resettinMailSendingError).toEqual(null);
      expect(model.resettinMailSentMessage).toEqual(
        "登録されているメールアドレスにトークンを記載したメールを送信しました。");
      expect(model.isSendingMail).toEqual(false);
      expect(model.tokenError).toEqual(null);
      expect(model.newPasswordError).toEqual(null);
      expect(model.passwordResettingError).toEqual(null);
      expect(model.passwordResettingMessage).toEqual(null);
      expect(model.isResettingPassword).toEqual(false);
      expect(eventQueue.queue).toEqual([]);
      expect(Deferred.unpack(d)).not.toBe(null);
    });
    it("メールアドレスが不正な場合", () => {
      const d = model.sendPasswordResettingMail("foo");
      expect(model.error).toEqual(null);
      expect(model.isAuthenticating).toEqual(false);
      expect(model.resettinMailSendingError).toEqual(
        "メールアドレスの形式が不正です");
      expect(model.resettinMailSentMessage).toEqual(null);
      expect(model.isSendingMail).toEqual(false);
      expect(model.tokenError).toEqual(null);
      expect(model.newPasswordError).toEqual(null);
      expect(model.passwordResettingError).toEqual(null);
      expect(model.passwordResettingMessage).toEqual(null);
      expect(model.isResettingPassword).toEqual(false);
      expect(() => Deferred.unpack(d)).toThrow();
      expect(eventQueue.queue).toEqual([]);
    });
    it("メールアドレスが一致していない場合", () => {
      const d = model.sendPasswordResettingMail("foo@example.com");
      expect(model.resettinMailSendingError).toEqual(null);
      expect(model.resettinMailSentMessage).toEqual(null);
      expect(model.isSendingMail).toEqual(true);
      xhrManager.requests[0].reject({statusCode:400});

      expect(model.error).toEqual(null);
      expect(model.isAuthenticating).toEqual(false);
      expect(model.resettinMailSendingError).toEqual(
        "入力されたメールアドレスがシステムに登録されているものと一致しませんでした。"
        + "メールアドレスを確認してください。");
      expect(model.resettinMailSentMessage).toEqual(null);
      expect(model.isSendingMail).toEqual(false);
      expect(model.tokenError).toEqual(null);
      expect(model.newPasswordError).toEqual(null);
      expect(model.passwordResettingError).toEqual(null);
      expect(model.passwordResettingMessage).toEqual(null);
      expect(model.isResettingPassword).toEqual(false);
      expect(() => Deferred.unpack(d)).toThrow();
      expect(eventQueue.queue).toEqual([]);
    });
    it("通信エラーになった場合", () => {
      const d = model.sendPasswordResettingMail("foo@example.com");
      expect(model.resettinMailSendingError).toEqual(null);
      expect(model.resettinMailSentMessage).toEqual(null);
      expect(model.isSendingMail).toEqual(true);
      xhrManager.requests[0].reject({statusCode:500});

      expect(model.error).toEqual(null);
      expect(model.isAuthenticating).toEqual(false);
      expect(model.resettinMailSendingError).toEqual(null);
      expect(model.resettinMailSentMessage).toEqual(null);
      expect(model.isSendingMail).toEqual(false);
      expect(model.tokenError).toEqual(null);
      expect(model.newPasswordError).toEqual(null);
      expect(model.passwordResettingError).toEqual(null);
      expect(model.passwordResettingMessage).toEqual(null);
      expect(model.isResettingPassword).toEqual(false);
      expect(() => Deferred.unpack(d)).toThrow();
      expect(eventQueue.queue).toEqual([]);
    });
  });


  describe("resetPassword", () => {
    it("パスワードをリセットできる", () => {
      const d = model.resetPassword("token", "test");
      expect(model.tokenError).toEqual(null);
      expect(model.newPasswordError).toEqual(null);
      expect(model.passwordResettingError).toEqual(null);
      expect(model.passwordResettingMessage).toEqual(null);
      expect(model.isResettingPassword).toEqual(true);
      xhrManager.requests[0].resolve({});

      expect(model.error).toEqual(null);
      expect(model.isAuthenticating).toEqual(false);
      expect(model.resettinMailSendingError).toEqual(null);
      expect(model.resettinMailSentMessage).toEqual(null);
      expect(model.isSendingMail).toEqual(false);
      expect(model.tokenError).toEqual(null);
      expect(model.newPasswordError).toEqual(null);
      expect(model.passwordResettingError).toEqual(null);
      expect(model.passwordResettingMessage).toEqual(
        "パスワードを再設定しました。新しいパスワードでログインしてご利用ください。");
      expect(model.isResettingPassword).toEqual(false);
      expect(eventQueue.queue).toEqual([]);
      expect(Deferred.unpack(d)).not.toBe(null);
    });
    it("パスワード/トークンが不正な場合", () => {
      const d = model.resetPassword("", "tes");
      expect(model.error).toEqual(null);
      expect(model.isAuthenticating).toEqual(false);
      expect(model.resettinMailSendingError).toEqual(null);
      expect(model.resettinMailSentMessage).toEqual(null);
      expect(model.isSendingMail).toEqual(false);
      expect(model.tokenError).toEqual("トークンを入力してください");
      expect(model.newPasswordError).toEqual("パスワードが短すぎます");
      expect(model.passwordResettingError).toEqual(null);
      expect(model.passwordResettingMessage).toEqual(null);
      expect(model.isResettingPassword).toEqual(false);
      expect(() => Deferred.unpack(d)).toThrow();
      expect(eventQueue.queue).toEqual([]);
    });
    it("メールアドレスが一致していない場合", () => {
      const d = model.resetPassword("token", "test");
      expect(model.tokenError).toEqual(null);
      expect(model.newPasswordError).toEqual(null);
      expect(model.passwordResettingError).toEqual(null);
      expect(model.passwordResettingMessage).toEqual(null);
      expect(model.isResettingPassword).toEqual(true);
      xhrManager.requests[0].reject({statusCode:400});

      expect(model.error).toEqual(null);
      expect(model.isAuthenticating).toEqual(false);
      expect(model.resettinMailSendingError).toEqual(null);
      expect(model.resettinMailSentMessage).toEqual(null);
      expect(model.isSendingMail).toEqual(false);
      expect(model.tokenError).toEqual(null);
      expect(model.newPasswordError).toEqual(null);
      expect(model.passwordResettingError).toEqual(
        "パスワードの再設定に失敗しました。トークンを確認してください。");
      expect(model.passwordResettingMessage).toEqual(null);
      expect(model.isResettingPassword).toEqual(false);
      expect(() => Deferred.unpack(d)).toThrow();
      expect(eventQueue.queue).toEqual([]);
    });
    it("通信エラーになった場合", () => {
      const d = model.resetPassword("token", "test");
      expect(model.tokenError).toEqual(null);
      expect(model.newPasswordError).toEqual(null);
      expect(model.passwordResettingError).toEqual(null);
      expect(model.passwordResettingMessage).toEqual(null);
      expect(model.isResettingPassword).toEqual(true);
      xhrManager.requests[0].reject({statusCode:500});

      expect(model.error).toEqual(null);
      expect(model.isAuthenticating).toEqual(false);
      expect(model.resettinMailSendingError).toEqual(null);
      expect(model.resettinMailSentMessage).toEqual(null);
      expect(model.isSendingMail).toEqual(false);
      expect(model.tokenError).toEqual(null);
      expect(model.newPasswordError).toEqual(null);
      expect(model.passwordResettingError).toEqual(null);
      expect(model.passwordResettingMessage).toEqual(null);
      expect(model.isResettingPassword).toEqual(false);
      expect(() => Deferred.unpack(d)).toThrow();
      expect(eventQueue.queue).toEqual([]);
    });
  });

});
