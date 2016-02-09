import ContainerJS      from "container-js"
import ContainerFactory from "../../../utils/test-container-factory"

describe("SMTPServerSettingModel", () => {

  var model;
  var xhrManager;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("viewModelFactory");
    const factory = ContainerJS.utils.Deferred.unpack(d);
    model = factory.createSMTPServerSettingModel();
    xhrManager = model.smtpServerSettingService.xhrManager;
    factory.timeSource.now = new Date(2015, 9, 10, 12, 4, 23);
  });

  describe("initialize", () => {
    it("サーバーが未設定の場合", () => {
      model.initialize();
      xhrManager.requests[0].resolve({
        enablePostmark : false
      });
      xhrManager.requests[1].resolve({
        smtpHost: null,
        smtpPort: null,
        userName: null,
        password: null
      });

      expect(model.enablePostmark).toEqual(false);
      expect(model.setting).toEqual({
        smtpHost: null,
        smtpPort: null,
        userName: null,
        password: null
      });
      expect(model.error).toEqual(null);
      expect(model.hostError).toEqual(null);
      expect(model.portError).toEqual(null);
      expect(model.userNameError).toEqual(null);
      expect(model.passwordError).toEqual(null);
      expect(model.message).toEqual(null);
      expect(model.testMailMessage).toEqual(null);
      expect(model.isSaving).toEqual(false);
    });
    it("設定済みの場合", () => {
      model.initialize();
      xhrManager.requests[0].resolve({
        enablePostmark : true
      });
      xhrManager.requests[1].resolve({
        smtpHost: "smtp.example.com",
        smtpPort: 587,
        userName: "test",
        password: "password"
      });

      expect(model.enablePostmark).toEqual(true);
      expect(model.setting).toEqual({
        smtpHost: "smtp.example.com",
        smtpPort: 587,
        userName: "test",
        password: "password"
      });
      expect(model.error).toEqual(null);
      expect(model.hostError).toEqual(null);
      expect(model.portError).toEqual(null);
      expect(model.userNameError).toEqual(null);
      expect(model.passwordError).toEqual(null);
      expect(model.message).toEqual(null);
      expect(model.testMailMessage).toEqual(null);
      expect(model.isSaving).toEqual(false);
    });
    it("設定取得時にエラーになった場合", () => {
      model.initialize();
      xhrManager.requests[0].resolve({
        enablePostmark : true
      });
      xhrManager.requests[1].reject({});

      expect(model.enablePostmark).toEqual(false);
      expect(model.setting).toEqual({});
      expect(model.error).toEqual(null);
      expect(model.hostError).toEqual(null);
      expect(model.portError).toEqual(null);
      expect(model.userNameError).toEqual(null);
      expect(model.passwordError).toEqual(null);
      expect(model.message).toEqual(null);
      expect(model.testMailMessage).toEqual(null);
      expect(model.isSaving).toEqual(false);
    });
  });

  describe("composeTestMail", () => {
    it("テストメールを送信できる", () => {
      model.initialize();
      xhrManager.requests[0].resolve({
        enablePostmark : true
      });
      xhrManager.requests[1].resolve({
        smtpHost: "smtp.example.com",
        smtpPort: 587,
        userName: "test",
        password: "password"
      });

      model.composeTestMail({
        smtpHost: "smtp.example.com",
        smtpPort: 587,
        userName: "test",
        password: "password"
      });
      expect(model.isSaving).toEqual(true);
      xhrManager.requests[2].resolve({});

      expect(model.error).toEqual(null);
      expect(model.hostError).toEqual(null);
      expect(model.portError).toEqual(null);
      expect(model.userNameError).toEqual(null);
      expect(model.passwordError).toEqual(null);
      expect(model.message).toEqual(null);
      expect(model.testMailMessage).toEqual("登録されているメールアドレスにテストメールを送信しました。ご確認ください。 (2015-10-10 12:04:23)");
      expect(model.isSaving).toEqual(false);
    });

    it("入力内容に不備がある場合、メッセージが表示される", () => {
      model.initialize();
      xhrManager.requests[0].resolve({
        enablePostmark : true
      });
      xhrManager.requests[1].resolve({
        smtpHost: "smtp.example.com",
        smtpPort: 587,
        userName: "test",
        password: "password"
      });

      model.composeTestMail({
        smtpHost: "",
        smtpPort: 587,
        userName: "test",
        password: "password"
      });

      expect(model.error).toEqual(null);
      expect(model.hostError).toEqual("SMTPサーバーを入力してください");
      expect(model.portError).toEqual(null);
      expect(model.userNameError).toEqual(null);
      expect(model.passwordError).toEqual(null);
      expect(model.message).toEqual(null);
      expect(model.testMailMessage).toEqual(null);
      expect(model.isSaving).toEqual(false);
    });

    it("エラーの場合、メッセージが表示される", () => {
      model.initialize();
      xhrManager.requests[0].resolve({
        enablePostmark : true
      });
      xhrManager.requests[1].resolve({
        smtpHost: "smtp.example.com",
        smtpPort: 587,
        userName: "test",
        password: "password"
      });

      model.composeTestMail({
        smtpHost: "smtp.example.com",
        smtpPort: 587,
        userName: "test",
        password: "password"
      });
      expect(model.isSaving).toEqual(true);
      xhrManager.requests[2].reject({});

      expect(model.error).toEqual("メールの送信でエラーが発生しました。接続先SMTPサーバーの設定を確認してください");
      expect(model.hostError).toEqual(null);
      expect(model.portError).toEqual(null);
      expect(model.userNameError).toEqual(null);
      expect(model.passwordError).toEqual(null);
      expect(model.message).toEqual(null);
      expect(model.testMailMessage).toEqual(null);
      expect(model.isSaving).toEqual(false);
    });
  });

  describe("#save", () => {
    it("Saveで設定を永続化できる", () => {
      model.initialize();
      xhrManager.requests[0].resolve({
        enablePostmark : true
      });
      xhrManager.requests[1].resolve({
        smtpHost: "smtp.example.com",
        smtpPort: 587,
        userName: "test",
        password: "password"
      });

      model.save({
        smtpHost: "smtp.example.com2",
        smtpPort: 587,
        userName: "test",
        password: "password"
      });
      expect(model.isSaving).toEqual(true);
      xhrManager.requests[2].resolve({});

      expect(model.setting).toEqual({
        smtpHost: "smtp.example.com2",
        smtpPort: 587,
        userName: "test",
        password: "password"
      });
      expect(model.error).toEqual(null);
      expect(model.hostError).toEqual(null);
      expect(model.portError).toEqual(null);
      expect(model.userNameError).toEqual(null);
      expect(model.passwordError).toEqual(null);
      expect(model.message).toEqual("設定を変更しました。 (2015-10-10 12:04:23)");
      expect(model.testMailMessage).toEqual(null);
      expect(model.isSaving).toEqual(false);
    });
    it("入力値が不正な場合、エラーが表示される", () => {
      model.initialize();
      xhrManager.requests[0].resolve({
        enablePostmark : true
      });
      xhrManager.requests[1].resolve({
        smtpHost: "smtp.example.com",
        smtpPort: 587,
        userName: "test",
        password: "password"
      });

      model.save({
        smtpHost: "",
        smtpPort: "-100",
        userName: "\x7f",
        password: "\x7f"
      });

      expect(model.setting).toEqual({
        smtpHost: "smtp.example.com",
        smtpPort: 587,
        userName: "test",
        password: "password"
      });
      expect(model.error).toEqual(null);
      expect(model.hostError).toEqual("SMTPサーバーを入力してください");
      expect(model.portError).toEqual("SMTPポートは半角数字で入力してください");
      expect(model.userNameError).toEqual("ユーザー名に不正な文字が含まれています");
      expect(model.passwordError).toEqual("パスワードに不正な文字が含まれています");
      expect(model.message).toEqual(null);
      expect(model.testMailMessage).toEqual(null);
      expect(model.isSaving).toEqual(false);
    });
    it("通信エラーの場合、エラーが表示される", () => {
      model.initialize();
      xhrManager.requests[0].resolve({
        enablePostmark : true
      });
      xhrManager.requests[1].resolve({
        smtpHost: "smtp.example.com",
        smtpPort: 587,
        userName: "test",
        password: "password"
      });

      model.save({
        smtpHost: "smtp.example.com2",
        smtpPort: 587,
        userName: "test",
        password: "password"
      });
      expect(model.isSaving).toEqual(true);
      xhrManager.requests[2].reject({
        statusCode: 500
      });
      expect(model.setting).toEqual({
        smtpHost: "smtp.example.com",
        smtpPort: 587,
        userName: "test",
        password: "password"
      });
      expect(model.error).toEqual(
        "サーバーが混雑しています。しばらく待ってからやり直してください");
      expect(model.hostError).toEqual(null);
      expect(model.portError).toEqual(null);
      expect(model.userNameError).toEqual(null);
      expect(model.passwordError).toEqual(null);
      expect(model.message).toEqual(null);
      expect(model.testMailMessage).toEqual(null);
      expect(model.isSaving).toEqual(false);
    });
  });
});
