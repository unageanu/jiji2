import ContainerJS      from "container-js"
import ContainerFactory from "../../../utils/test-container-factory"

describe("PasswordSettingModel", () => {

  var model;
  var xhrManager;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("viewModelFactory");
    const factory = ContainerJS.utils.Deferred.unpack(d);
    model = factory.createPasswordSettingModel();
    xhrManager = model.userSettingService.xhrManager;
    factory.timeSource.now = new Date(2015, 9, 10, 12, 4, 23);
  });

  describe("#save", () => {
    it("パスワードを変更できる", () => {
      expect(model.isSaving).toEqual(false);

      model.save( "11111", "11111", "22222" );
      expect(model.isSaving).toEqual(true);
      xhrManager.requests[0].resolve({});

      expect(model.error).toEqual(null);
      expect(model.message).toEqual("パスワードを変更しました。 (2015-10-10 12:04:23)");
      expect(model.isSaving).toEqual(false);
    });
    it("パスワードが一致しない場合、エラーが表示される", () => {
      model.save( "11111", "11112", "22222" );
      expect(model.error).toEqual("新しいパスワードが一致していません");
      expect(model.message).toEqual(null);
      expect(model.isSaving).toEqual(false);
    });
    it("パスワードが不正な場合、エラーが表示される", () => {
      model.save( "aaa", "aaa", "22222" );
      expect(model.error).toEqual("新しいパスワードが短すぎます");
      expect(model.message).toEqual(null);
      expect(model.isSaving).toEqual(false);

      model.save( "", "", "" );
      expect(model.error).toEqual("新しいパスワードを入力してください");
      expect(model.message).toEqual(null);
      expect(model.isSaving).toEqual(false);
    });
    it("旧パスワードが不正な場合、エラーが表示される", () => {
      model.save( "11111", "11111", "22222" );
      expect(model.isSaving).toEqual(true);
      xhrManager.requests[0].reject({
        statusCode: 401
      });
      expect(model.error).toEqual(
        "現在のパスワードが一致していません。入力した値をご確認ください");
      expect(model.message).toEqual(null);
      expect(model.isSaving).toEqual(false);
    });
    it("通信エラーの場合、エラーが表示される", () => {
      model.save( "11111", "11111", "22222" );
      expect(model.isSaving).toEqual(true);
      xhrManager.requests[0].reject({
        statusCode: 500
      });
      expect(model.error).toEqual(
        "サーバーが混雑しています。しばらく待ってからやり直してください");
      expect(model.message).toEqual(null);
      expect(model.isSaving).toEqual(false);
    });
  });
});
