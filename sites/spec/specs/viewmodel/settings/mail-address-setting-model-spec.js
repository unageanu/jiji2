import ContainerJS      from "container-js"
import ContainerFactory from "../../../utils/test-container-factory"

describe("MailAddressSettingModel", () => {

  var model;
  var xhrManager;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("viewModelFactory");
    const factory = ContainerJS.utils.Deferred.unpack(d);
    model = factory.createMailAddressSettingModel();
    xhrManager = model.userSettingService.xhrManager;
  });

  describe("initialize", () => {
    it("アドレスが未設定の場合", () => {
      model.initialize();
      xhrManager.requests[0].resolve({
        mailAddress: null
      });

      expect(model.mailAddress).toEqual(null);
      expect(model.error).toEqual(null);
      expect(model.message).toEqual(null);
    });
    it("アドレス設定済みの場合", () => {
      model.initialize();
      xhrManager.requests[0].resolve({
        mailAddress: "foo@var.com"
      });

      expect(model.mailAddress).toEqual("foo@var.com");
      expect(model.error).toEqual(null);
      expect(model.message).toEqual(null);
    });
  });

  it("テストメールを送信できる", () => {
    model.initialize();
    xhrManager.requests[0].resolve({
      mailAddress: null
    });

    model.composeTestMail("foo@var.com");

    expect(xhrManager.requests[1].body).toEqual({
      mailAddress: "foo@var.com"
    });
  });

  describe("#save", () => {
    it("Saveで設定を永続化できる", () => {
      model.initialize();
      xhrManager.requests[0].resolve({
        mailAddress: null
      });

      model.save( "foo@var.com" );
      xhrManager.requests[1].resolve();

      expect(model.mailAddress).toEqual("foo@var.com");
      expect(model.error).toEqual(null);
      expect(model.message).toEqual("メールアドレスを変更しました");
    });
    it("メールアドレスが不正な場合、エラーが表示される", () => {
      model.initialize();
      xhrManager.requests[0].resolve({
        mailAddress: "foo@var.com"
      });

      model.save( "foo" );
      expect(model.mailAddress).toEqual("foo@var.com");
      expect(model.error).toEqual("メールアドレスの形式が不正です");
      expect(model.message).toEqual(null);

      model.save( "" );
      expect(model.mailAddress).toEqual("foo@var.com");
      expect(model.error).toEqual("メールアドレスを入力してください");
      expect(model.message).toEqual(null);

      model.save( "foo$@bat.com" );
      expect(model.mailAddress).toEqual("foo@var.com");
      expect(model.error).toEqual(
        "メールアドレスに使用できない文字「$」が含まれています");
      expect(model.message).toEqual(null);
    });
    it("通信エラーの場合、エラーが表示される", () => {
      model.initialize();
      xhrManager.requests[0].resolve({
        mailAddress: "foo@var.com"
      });

      model.save( "foo2@var.com" );
      xhrManager.requests[1].reject({
        statusCode: 500
      });
      expect(model.mailAddress).toEqual("foo@var.com");
      expect(model.error).toEqual(
        "サーバーが混雑しています。しばらく待ってからやり直してください");
      expect(model.message).toEqual(null);
    });
  });
});
