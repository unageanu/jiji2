import ContainerJS      from "container-js"
import ContainerFactory from "../../../utils/test-container-factory"

describe("InitialSettingsPageModel", () => {

  var model;
  var xhrManager;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("InitialSettingsPageModel");
    model = ContainerJS.utils.Deferred.unpack(d);
    xhrManager = model.initialSettingService.xhrManager;
  });

  describe("initialize", () => {
    it("初期化済みの場合", () => {
      model.initialize();
      xhrManager.requests[0].resolve({
        initialized: true
      });
      expect(model.isInitialized).toEqual(true);
      expect(model.phase).toEqual("none");
      expect(model.error).toEqual(null);
    });
    it("未初期化の場合", () => {
      model.initialize();
      xhrManager.requests[0].resolve({
        initialized: false
      });
      expect(model.isInitialized).toEqual(false);
      expect(model.phase).toEqual("welcome");
      expect(model.error).toEqual(null);
    });
  });

  describe("startEdit", () => {

    beforeEach(() => {
      model.initialize();
      xhrManager.requests[0].resolve({
        initialized: false
      });
      xhrManager.requests = [];
    });

    it("メールアドレス、パスワード設定画面に移動できる", () => {
      model.startEdit();
      expect(model.isInitialized).toEqual(false);
      expect(model.phase).toEqual("mailAddressAndPassword");
      expect(model.error).toEqual(null);
      expect(model.mailAddressSetting.mailAddress).toEqual(null);
    });
  });

  describe("setMailAddressAndPassword", () => {
    it("メールアドレス、パスワードを設定できる", () => {
      model.initialize();
      xhrManager.requests[0].resolve({
        mailAddress: null
      });

      expect(model.mailAddress).toEqual(null);
      expect(model.error).toEqual(null);
      expect(model.message).toEqual(null);
    });
    it("入力値が不正な場合、エラーが表示される", () => {
      model.initialize();
      xhrManager.requests[0].resolve({
        mailAddress: "foo@var.com"
      });

      expect(model.mailAddress).toEqual("foo@var.com");
      expect(model.error).toEqual(null);
      expect(model.message).toEqual(null);
    });
    it("通信エラーの場合、エラーが表示される", () => {});
  });

  describe("setSecurities", () => {
    it("利用する証券会社を設定できる", () => {
      model.initialize();
      xhrManager.requests[0].resolve({
        mailAddress: null
      });

      expect(model.mailAddress).toEqual(null);
      expect(model.error).toEqual(null);
      expect(model.message).toEqual(null);
    });
    it("メールサーバーの設定が不要な場合、設定完了画面に進む", () => {
      model.initialize();
      xhrManager.requests[0].resolve({
        mailAddress: null
      });

      expect(model.mailAddress).toEqual(null);
      expect(model.error).toEqual(null);
      expect(model.message).toEqual(null);
    });
    it("入力値が不正な場合、エラーが表示される", () => {
      model.initialize();
      xhrManager.requests[0].resolve({
        mailAddress: "foo@var.com"
      });

      expect(model.mailAddress).toEqual("foo@var.com");
      expect(model.error).toEqual(null);
      expect(model.message).toEqual(null);
    });
    it("通信エラーの場合、エラーが表示される", () => {});
  });

  describe("setSMTPServerSetting", () => {
    it("SMTPサーバーを設定できる", () => {
      model.initialize();
      xhrManager.requests[0].resolve({
        mailAddress: null
      });

      expect(model.mailAddress).toEqual(null);
      expect(model.error).toEqual(null);
      expect(model.message).toEqual(null);
    });
    it("入力値が不正な場合、エラーが表示される", () => {
      model.initialize();
      xhrManager.requests[0].resolve({
        mailAddress: "foo@var.com"
      });

      expect(model.mailAddress).toEqual("foo@var.com");
      expect(model.error).toEqual(null);
      expect(model.message).toEqual(null);
    });
    it("通信エラーの場合、エラーが表示される", () => {});
  });

  describe("exit", () => {
    it("設定を完了できる", () => {
      model.initialize();
      xhrManager.requests[0].resolve({
        mailAddress: null
      });

      expect(model.mailAddress).toEqual(null);
      expect(model.error).toEqual(null);
      expect(model.message).toEqual(null);
    });
  });

});
