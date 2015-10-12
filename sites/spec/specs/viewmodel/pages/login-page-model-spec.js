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
      expect(model.error).toEqual(null);
      expect(model.authenticating).toEqual(false);
      expect(eventQueue.queue).toEqual([]);
    });
  });

  describe("login", () => {
    it("正しいパスワードを指定してログインできる", () => {
      const d = model.login("test");
      expect(model.error).toEqual(null);
      expect(model.authenticating).toEqual(true);
      xhrManager.requests[0].resolve({ticket:"aaaa"});

      expect(model.error).toEqual(null);
      expect(model.authenticating).toEqual(false);
      expect(eventQueue.queue).toEqual([
        { type: "routing", route: "/" }
      ]);
      expect(Deferred.unpack(d)).not.toBe(null);
    });
    it("パスワードが入力されていない場合", () => {
      const d = model.login("");
      expect(model.error).toEqual("パスワードを入力してください");
      expect(model.authenticating).toEqual(false);
      expect(() => Deferred.unpack(d)).toThrow();
      expect(eventQueue.queue).toEqual([]);
    });
    it("認証エラーになった場合", () => {
      const d = model.login("test");
      expect(model.error).toEqual(null);
      expect(model.authenticating).toEqual(true);
      xhrManager.requests[0].reject({statusCode:401});

      expect(model.error).toEqual("パスワードが一致していません");
      expect(model.authenticating).toEqual(false);
      expect(() => Deferred.unpack(d)).toThrow();
      expect(eventQueue.queue).toEqual([]);
    });
    it("通信エラーになった場合", () => {
      const d = model.login("test");
      expect(model.error).toEqual(null);
      expect(model.authenticating).toEqual(true);
      xhrManager.requests[0].reject({statusCode:500});

      expect(model.error).toEqual(null);
      expect(model.authenticating).toEqual(false);
      expect(() => Deferred.unpack(d)).toThrow();
      expect(eventQueue.queue).toEqual([]);
    });
  });

});
