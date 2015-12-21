import ContainerJS      from "container-js"
import ContainerFactory from "../../utils/test-container-factory"

describe("Application", () => {

  var application;
  var xhrManager;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("application");
    application = ContainerJS.utils.Deferred.unpack(d);
    xhrManager = application.xhrManager;
  });

  describe("initialize", () => {
    it("初期化済みの場合", () => {
      const d = application.initialize();
      expect(application.googleAnalytics.version).toEqual("unknown");

      xhrManager.requests[0].resolve({
        initialized: true
      });
      xhrManager.requests[1].resolve({
        version: "1.0.0"
      });

      expect(ContainerJS.utils.Deferred.unpack(d)).toEqual(null);
      expect(application.googleAnalytics.version).toEqual("1.0.0");
    });
    it("未初期化の場合", () => {
      const d = application.initialize();
      xhrManager.requests[0].resolve({
        initialized: false
      });
      expect(ContainerJS.utils.Deferred.unpack(d)).toEqual("/initial-settings");
    });
    it("通信エラーの場合、ホームページに飛ばす", () => {
      const d = application.initialize();
      xhrManager.requests[0].reject({
        code: 500
      });
      expect(ContainerJS.utils.Deferred.unpack(d)).toEqual(null);
    });
    it("バージョン情報の取得でエラーになった場合", () => {
      const d = application.initialize();
      expect(application.googleAnalytics.version).toEqual("unknown");

      xhrManager.requests[0].reject({
        code: 500
      });
      xhrManager.requests[1].reject({
        code: 404
      });

      expect(ContainerJS.utils.Deferred.unpack(d)).toEqual(null);
      expect(application.googleAnalytics.version).toEqual("unknown");
    });
  });

});
