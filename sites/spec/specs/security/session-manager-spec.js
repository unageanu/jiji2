import ContainerJS      from "container-js"
import ContainerFactory from "../../utils/test-container-factory"

describe("SessionManager", () => {

  var manager;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("sessionManager");
    manager = ContainerJS.utils.Deferred.unpack(d);
  });

  describe("初期状態", () => {
    it("トークンは未設定", () => {
      expect(manager.getToken()).toEqual(null);
    });
    it("isLoggedInもfalseを返す", () => {
      expect(manager.isLoggedIn).toEqual(false);
    });
  });

  describe("トークンが設定されている場合", () => {
    beforeEach(() => {
      manager.setToken("aaaa");
    });
    it("トークンを取得できる", () => {
      expect(manager.getToken()).toEqual("aaaa");
    });
    it("ログイン済みになる", () => {
      expect(manager.isLoggedIn).toEqual(true);
    });
  });

  describe("トークンを削除した場合", () => {
    beforeEach(() => {
      manager.setToken("aaaa");
      manager.deleteToken();
    });
    it("トークンは未設定", () => {
      expect(manager.getToken()).toEqual(null);
    });
    it("ログイン済み状態も解除される", () => {
      expect(manager.isLoggedIn).toEqual(false);
    });
  });

});
