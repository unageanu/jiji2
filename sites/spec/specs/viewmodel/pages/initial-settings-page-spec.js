import ContainerJS      from "container-js"
import ContainerFactory from "../../../utils/test-container-factory"

describe("InitialSettingsPageModel", () => {

  var model;
  var xhrManager;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("initialSettingsPageModel");
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
      expect(model.sessionManager.getToken()).toEqual(null);
    });
    it("未初期化の場合", () => {
      model.initialize();
      xhrManager.requests[0].resolve({
        initialized: false
      });
      expect(model.isInitialized).toEqual(false);
      expect(model.phase).toEqual("welcome");
      expect(model.error).toEqual(null);
      expect(model.sessionManager.getToken()).toEqual(null);
    });
  });

  describe("startSetting", () => {
    beforeEach(() => {
      model.initialize();
      xhrManager.requests[0].resolve({
        initialized: false
      });
      xhrManager.requests = [];
    });

    it("メールアドレス、パスワード設定画面に移動できる", () => {
      model.startSetting();
      expect(model.isInitialized).toEqual(false);
      expect(model.phase).toEqual("mailAddressAndPassword");
      expect(model.error).toEqual(null);
      expect(model.mailAddressSetting.mailAddress).toEqual(undefined);
      expect(model.sessionManager.getToken()).toEqual(null);
    });
  });

  describe("setMailAddressAndPassword", () => {
    beforeEach(() => {
      model.initialize();
      xhrManager.requests[0].resolve({
        initialized: false
      });
      model.startSetting();
      xhrManager.requests = [];
    });

    it("メールアドレス、パスワードを設定できる", () => {
      model.setMailAddressAndPassword("foo@var.com", "11111", "11111");
      xhrManager.requests[0].resolve({
        token: "abcdef"
      });
      xhrManager.requests[1].resolve([
        { securitiesId: "aa", name:"aaa" },
        { securitiesId: "bb", name:"bbb" }
      ]);
      xhrManager.requests[2].resolve(
        {securitiesId: null }
      );
      xhrManager.requests[3].resolve([
        { id: "config1", description: "config1" },
        { id: "config2", description: "config2" }
      ]);
      xhrManager.requests[4].resolve({});

      expect(model.isInitialized).toEqual(true);
      expect(model.phase).toEqual("securities");
      expect(model.error).toEqual(null);
      expect(model.sessionManager.getToken()).toEqual("abcdef");
      expect(model.securitiesSetting.availableSecurities).toEqual([
        { securitiesId: "aa", name:"aaa", id: "aa", text:"aaa" },
        { securitiesId: "bb", name:"bbb", id: "bb", text:"bbb" }
      ]);
      expect(model.securitiesSetting.activeSecuritiesId).toEqual("aa");
      expect(model.securitiesSetting.activeSecuritiesConfiguration).toEqual([
        { id: "config1", description: "config1", value: null },
        { id: "config2", description: "config2", value: null }
      ]);
    });

    it("入力値が不正な場合、エラーが表示される", () => {
      model.setMailAddressAndPassword("foovar.com", "11111", "11111");

      expect(model.isInitialized).toEqual(false);
      expect(model.phase).toEqual("mailAddressAndPassword");
      expect(model.error).toEqual(null);
      expect(model.sessionManager.getToken()).toEqual(null);
      expect(model.mailAddressSetting.error).toEqual("メールアドレスの形式が不正です");
      expect(model.passwordSetting.error).toEqual(null);

      model.setMailAddressAndPassword("foo@var.com", "11112", "11111");

      expect(model.isInitialized).toEqual(false);
      expect(model.phase).toEqual("mailAddressAndPassword");
      expect(model.error).toEqual(null);
      expect(model.sessionManager.getToken()).toEqual(null);
      expect(model.mailAddressSetting.error).toEqual(null);
      expect(model.passwordSetting.error).toEqual("パスワードが一致していません");

      model.setMailAddressAndPassword("", "", "");

      expect(model.isInitialized).toEqual(false);
      expect(model.phase).toEqual("mailAddressAndPassword");
      expect(model.error).toEqual(null);
      expect(model.sessionManager.getToken()).toEqual(null);
      expect(model.mailAddressSetting.error).toEqual("メールアドレスを入力してください");
      expect(model.passwordSetting.error).toEqual("パスワードを入力してください");
    });
    it("通信エラーの場合、エラーが表示される", () => {
      model.setMailAddressAndPassword("foo@var.com", "11111", "11111");
      xhrManager.requests[0].reject({
        statusCode: 400
      });
      expect(model.isInitialized).toEqual(false);
      expect(model.phase).toEqual("mailAddressAndPassword");
      expect(model.error).toEqual("値が正しく入力されていません");
      expect(model.sessionManager.getToken()).toEqual(null);
      expect(model.mailAddressSetting.error).toEqual(null);
      expect(model.passwordSetting.error).toEqual(null);
    });
  });

  describe("setSecurities", () => {
    beforeEach(() => {
      model.initialize();
      xhrManager.requests[0].resolve({
        initialized: false
      });
      model.startSetting();
      model.setMailAddressAndPassword("foo@var.com", "11111", "11111");
      xhrManager.requests[1].resolve({
        token: "abcdef"
      });
      xhrManager.requests[2].resolve([
        { securitiesId: "aa", name:"aaa" },
        { securitiesId: "bb", name:"bbb" }
      ]);
      xhrManager.requests[3].resolve(
        {securitiesId: null }
      );
      xhrManager.requests[4].resolve([
        { id: "config1", description: "config1" },
        { id: "config2", description: "config2" }
      ]);
      xhrManager.requests[5].resolve({});
      xhrManager.requests = [];
    });

    it("利用する証券会社を設定できる", () => {
      model.securitiesSetting.activeSecuritiesId = "bb";
      xhrManager.requests[0].resolve([
        { id: "config1", description: "config1" },
        { id: "config2", description: "config2" }
      ]);
      xhrManager.requests[1].resolve({});

      model.setSecurities({config1: "yyy"});
      xhrManager.requests[2].resolve({});
      xhrManager.requests[3].resolve({
        enablePostmark : false
      });
      xhrManager.requests[4].resolve({
        smtpHost: null,
        smtpPort: null,
        userName: null,
        password: null
      });

      expect(xhrManager.requests[2].body).toEqual({
        "securities_id": "bb",
        configurations: {config1: "yyy"}
      });
      expect(model.isInitialized).toEqual(true);
      expect(model.phase).toEqual("smtpServer");
      expect(model.error).toEqual(null);
      expect(model.smtpServerSetting.enablePostmark).toEqual(false);
      expect(model.smtpServerSetting.setting).toEqual({
        smtpHost: null,
        smtpPort: null,
        userName: null,
        password: null
      });
      expect(model.smtpServerSetting.error).toEqual(null);
      expect(model.smtpServerSetting.hostError).toEqual(null);
      expect(model.smtpServerSetting.portError).toEqual(null);
      expect(model.smtpServerSetting.userNameError).toEqual(null);
      expect(model.smtpServerSetting.passwordError).toEqual(null);
    });
    it("メールサーバーの設定が不要な場合、設定完了画面に進む", () => {
      model.securitiesSetting.activeSecuritiesId = "aa";
      model.setSecurities({});
      xhrManager.requests[0].resolve({});
      xhrManager.requests[1].resolve({
        enablePostmark : true
      });
      xhrManager.requests[2].resolve({
        smtpHost: "example.com",
        smtpPort: null,
        userName: null,
        password: null
      });

      expect(xhrManager.requests[0].body).toEqual({
        "securities_id": "aa",
        configurations: {}
      });
      expect(model.isInitialized).toEqual(true);
      expect(model.phase).toEqual("finished");
      expect(model.error).toEqual(null);
      expect(model.smtpServerSetting.enablePostmark).toEqual(true);
      expect(model.smtpServerSetting.setting).toEqual({
        smtpHost: "example.com",
        smtpPort: null,
        userName: null,
        password: null
      });
      expect(model.smtpServerSetting.error).toEqual(null);
      expect(model.smtpServerSetting.hostError).toEqual(null);
      expect(model.smtpServerSetting.portError).toEqual(null);
      expect(model.smtpServerSetting.userNameError).toEqual(null);
      expect(model.smtpServerSetting.passwordError).toEqual(null);
    });
    it("通信エラーの場合、エラーが表示される", () => {
      model.securitiesSetting.activeSecuritiesId = "aa";
      model.setSecurities({});
      xhrManager.requests[0].reject({
        statusCode: 400
      });

      expect(model.isInitialized).toEqual(true);
      expect(model.phase).toEqual("securities");
      expect(model.error).toEqual(null);
      expect(model.securitiesSetting.error).toEqual(
        "証券会社に接続できませんでした。<br/>アクセストークンを確認してください。");
      expect(model.securitiesSetting.message).toEqual(null);
    });
  });

  describe("setSMTPServerSetting", () => {
    beforeEach(() => {
      model.initialize();
      xhrManager.requests[0].resolve({
        initialized: false
      });
      model.startSetting();
      model.setMailAddressAndPassword("foo@var.com", "11111", "11111");
      xhrManager.requests[1].resolve({
        token: "abcdef"
      });
      xhrManager.requests[2].resolve([
        { securitiesId: "aa", name:"aaa" },
        { securitiesId: "bb", name:"bbb" }
      ]);
      xhrManager.requests[3].resolve(
        {securitiesId: null }
      );
      xhrManager.requests[4].resolve([
        { id: "config1", description: "config1" },
        { id: "config2", description: "config2" }
      ]);
      xhrManager.requests[5].resolve({});

      model.securitiesSetting.activeSecuritiesId = "bb";
      xhrManager.requests[6].resolve([
        { id: "config1", description: "config1" },
        { id: "config2", description: "config2" }
      ]);
      xhrManager.requests[7].resolve({});

      model.setSecurities({config1: "yyy"});
      xhrManager.requests[8].resolve({});
      xhrManager.requests[9].resolve({
        enablePostmark : false
      });
      xhrManager.requests[10].resolve({
        smtpHost: null,
        smtpPort: null,
        userName: null,
        password: null
      });
      xhrManager.requests = [];
    });

    it("SMTPサーバーを設定できる", () => {
      model.setSMTPServerSetting({
        smtpHost: "smtp.example.com2",
        smtpPort: 587,
        userName: "test",
        password: "password"
      });
      xhrManager.requests[0].resolve({});

      expect(model.isInitialized).toEqual(true);
      expect(model.phase).toEqual("finished");
      expect(model.error).toEqual(null);
      expect(model.smtpServerSetting.setting).toEqual({
        smtpHost: "smtp.example.com2",
        smtpPort: 587,
        userName: "test",
        password: "password"
      });
      expect(model.smtpServerSetting.error).toEqual(null);
      expect(model.smtpServerSetting.hostError).toEqual(null);
      expect(model.smtpServerSetting.portError).toEqual(null);
      expect(model.smtpServerSetting.userNameError).toEqual(null);
      expect(model.smtpServerSetting.passwordError).toEqual(null);
      expect(model.smtpServerSetting.message).toEqual("設定を変更しました");
    });
    it("入力値が不正な場合、エラーが表示される", () => {
      model.setSMTPServerSetting({
        smtpHost: "",
        smtpPort: "aaa",
        userName: "tes\x7ft",
        password: "\x7fpassword"
      });

      expect(model.isInitialized).toEqual(true);
      expect(model.phase).toEqual("smtpServer");
      expect(model.error).toEqual(null);
      expect(model.smtpServerSetting.setting).toEqual({
        smtpHost: null,
        smtpPort: null,
        userName: null,
        password: null
      });
      expect(model.smtpServerSetting.error).toEqual(null);
      expect(model.smtpServerSetting.hostError)
        .toEqual("SMTPサーバーを入力してください");
      expect(model.smtpServerSetting.portError)
        .toEqual("SMTPポートは半角数字で入力してください");
      expect(model.smtpServerSetting.userNameError)
        .toEqual("ユーザー名に不正な文字が含まれています");
      expect(model.smtpServerSetting.passwordError)
        .toEqual("パスワードに不正な文字が含まれています");
      expect(model.smtpServerSetting.message).toEqual(null);
    });
    it("通信エラーの場合、エラーが表示される", () => {
      model.setSMTPServerSetting({
        smtpHost: "smtp.example.com2",
        smtpPort: 587,
        userName: "test",
        password: "password"
      });
      xhrManager.requests[0].reject({
        statusCode: 500
      });

      expect(model.isInitialized).toEqual(true);
      expect(model.phase).toEqual("smtpServer");
      expect(model.error).toEqual(null);
      expect(model.smtpServerSetting.setting).toEqual({
        smtpHost: null,
        smtpPort: null,
        userName: null,
        password: null
      });
      expect(model.smtpServerSetting.error).toEqual(
        "サーバーが混雑しています。しばらく待ってからやり直してください");
      expect(model.smtpServerSetting.hostError).toEqual(null);
      expect(model.smtpServerSetting.portError).toEqual(null);
      expect(model.smtpServerSetting.userNameError).toEqual(null);
      expect(model.smtpServerSetting.passwordError).toEqual(null);
      expect(model.smtpServerSetting.message).toEqual(null);
    });
  });

  describe("exit", () => {
    beforeEach(() => {
      model.initialize();
      xhrManager.requests[0].resolve({
        initialized: false
      });
      model.startSetting();
      model.setMailAddressAndPassword("foo@var.com", "11111", "11111");
      xhrManager.requests[1].resolve({
        token: "abcdef"
      });
      xhrManager.requests[2].resolve([
        { securitiesId: "aa", name:"aaa" },
        { securitiesId: "bb", name:"bbb" }
      ]);
      xhrManager.requests[3].resolve(
        {securitiesId: null }
      );
      xhrManager.requests[4].resolve([
        { id: "config1", description: "config1" },
        { id: "config2", description: "config2" }
      ]);
      xhrManager.requests[5].resolve({});

      model.securitiesSetting.activeSecuritiesId = "bb";
      xhrManager.requests[6].resolve([
        { id: "config1", description: "config1" },
        { id: "config2", description: "config2" }
      ]);
      xhrManager.requests[7].resolve({});

      model.setSecurities({config1: "yyy"});
      xhrManager.requests[8].resolve({});
      xhrManager.requests[9].resolve({
        enablePostmark : false
      });
      xhrManager.requests[10].resolve({
        smtpHost: null,
        smtpPort: null,
        userName: null,
        password: null
      });
      model.setSMTPServerSetting({
        smtpHost: "smtp.example.com2",
        smtpPort: 587,
        userName: "test",
        password: "password"
      });
      xhrManager.requests[11].resolve({});
      xhrManager.requests = [];
    });

    it("設定を完了できる", () => {
      model.exit();

      expect(model.isInitialized).toEqual(true);
      expect(model.phase).toEqual("none");
      expect(model.error).toEqual(null);
      expect(model.eventQueue.queue).toEqual([
        { type: "routing", route: "/" }
      ]);
    });
  });

});
