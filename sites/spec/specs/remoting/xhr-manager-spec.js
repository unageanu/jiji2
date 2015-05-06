import ContainerJS      from "container-js";
import Error            from "src/model/error";
import HTTPHeaderField  from "src/remoting/http-header-field";
import ContainerFactory from "../../utils/test-container-factory";

function createErrorResponse(status) {
  return {
    status: status
  };
}

describe("XhrManager", () => {

  var container;
  var d;

  beforeEach(() => {
    container = new ContainerFactory().createContainer();
    d = container.get("xhrManager");
  });

  describe("通常モード", () => {

    it("xhr()を呼び出すとリクエストが発行される", () => {

      let manager = ContainerJS.utils.Deferred.unpack(d);

      expect(manager.requests.length).toBe(0);
      expect(manager.isLoading()).toBe(false);

      // GETリクエストを発行
      manager.xhr("/test", "GET");

      expect(manager.isLoading()).toBe(true);
      expect(manager.requests.length).toBe(1);
      expect(manager.requests[0].ajaxRequests.length).toBe(1);

      let ajaxSettings = manager.requests[0].ajaxRequests[0].settings;
      expect(ajaxSettings.method).toBe("GET");
      expect(ajaxSettings.headers[HTTPHeaderField.AUTHORIZATION]).toBe(undefined);
      expect(ajaxSettings.data).toBe(undefined);
      expect(ajaxSettings.url).toBe("/test");

      // ログインしてPOSTリクエストを発行
      manager.sessionManager.setToken("dummyToken");
      manager.xhr("/test", "POST", ["a", "b"]);

      expect(manager.isLoading()).toBe(true);
      expect(manager.requests.length).toBe(2);
      expect(manager.requests[1].ajaxRequests.length).toBe(1);

      ajaxSettings = manager.requests[1].ajaxRequests[0].settings;
      expect(ajaxSettings.method).toBe("POST");
      expect(ajaxSettings.headers[HTTPHeaderField.AUTHORIZATION]).toBe("X-JIJI-AUTHENTICATE dummyToken");
      expect(ajaxSettings.data.length).toBe(2);
      expect(ajaxSettings.url).toBe("/test");
    });

    it("レスポンスをDeferredから取得できる。", () => {
      let manager = ContainerJS.utils.Deferred.unpack(d);

      expect(manager.isLoading()).toBe(false);

      let xhr = manager.xhr("/test", "GET");

      expect(manager.isLoading()).toBe(true);

      manager.requests[0].resolve({
        foo: "foo"
      });

      let xhrResult = ContainerJS.utils.Deferred.unpack(xhr);
      expect(xhrResult.foo).toBe("foo");
      expect(manager.isLoading()).toBe(false);
    });

    it("エラーレスポンスをDeferredから取得できる。", () => {
      let manager = ContainerJS.utils.Deferred.unpack(d);

      expect(manager.isLoading()).toBe(false);

      let xhr = manager.xhr("/test", "GET");

      expect(manager.isLoading()).toBe(true);

      manager.requests[0].ajaxRequests[0].d.reject(
        createErrorResponse(401));

      try {
        let x = ContainerJS.utils.Deferred.unpack(xhr);
        expect(true).toBe(false);
      } catch (error) {
        expect(error.code).toBe(Error.Code.UNAUTHORIZED);
      }
      expect(manager.isLoading()).toBe(false);
    });
  });

  describe("再ログインモード", () => {

    it("認証エラーを受けてブロックモードになる。start()でリクエストが再送される。", () => {

      let stopped = false;

      let manager = ContainerJS.utils.Deferred.unpack(d);
      manager.supportRelogin = true;
      manager.addObserver("startBlocking", () => stopped = true);

      let xhr1 = manager.xhr("/test", "GET");
      let xhr2 = manager.xhr("/test2", "GET");
      let xhr3 = manager.xhr("/test3", "GET");
      let xhr4 = manager.xhr("/test4", "GET");
      let xhr5 = manager.xhr("/test5", "GET");

      expect(manager.isLoading()).toBe(true);
      expect(manager.requests.length).toBe(5);
      expect(manager.requests[0].ajaxRequests.length).toBe(1);
      expect(manager.requests[1].ajaxRequests.length).toBe(1);
      expect(manager.requests[2].ajaxRequests.length).toBe(1);
      expect(manager.requests[3].ajaxRequests.length).toBe(1);
      expect(manager.requests[4].ajaxRequests.length).toBe(1);

      // xhr1に401応答が返される
      manager.requests[0].ajaxRequests[0].d.reject(
        createErrorResponse(401));

      // ブロックモードになる
      expect(stopped).toBe(true);

      // 結果はまだリクエスト元には通知されない
      expect(xhr1.fixed()).toBe(false);
      expect(xhr2.fixed()).toBe(false);
      expect(xhr3.fixed()).toBe(false);
      expect(xhr4.fixed()).toBe(false);
      expect(xhr5.fixed()).toBe(false);

      // ブロック中にリクエストを発行 / サーバーには送られない。
      let xhr10 = manager.xhr("/test10", "GET");
      let xhr11 = manager.xhr("/test11", "GET");

      expect(manager.requests.length).toBe(7);
      expect(manager.requests[0].ajaxRequests.length).toBe(1);
      expect(manager.requests[1].ajaxRequests.length).toBe(1);
      expect(manager.requests[2].ajaxRequests.length).toBe(1);
      expect(manager.requests[3].ajaxRequests.length).toBe(1);
      expect(manager.requests[4].ajaxRequests.length).toBe(1);
      expect(manager.requests[5].ajaxRequests.length).toBe(0);
      expect(manager.requests[6].ajaxRequests.length).toBe(0);

      // xhr2 も 401 でエラー
      manager.requests[1].ajaxRequests[0].d.reject(createErrorResponse(401));

      // xhr3 は 200 で成功 / 結果がクライアントに通知される
      manager.requests[2].ajaxRequests[0].d.resolve([{}]);
      expect(xhr3.resolved()).toBe(true);

      // xhr4 は 403 でエラー / 結果がクライアントに通知される
      manager.requests[3].ajaxRequests[0].d.reject(createErrorResponse(403));
      expect(xhr4.rejected()).toBe(true);


      // 1と2,5,10,11は未確定
      expect(xhr1.fixed()).toBe(false);
      expect(xhr2.fixed()).toBe(false);
      expect(xhr5.fixed()).toBe(false);
      expect(xhr10.fixed()).toBe(false);
      expect(xhr11.fixed()).toBe(false);

      // 1と2と5があるのでまだローディング中
      expect(manager.isLoading()).toBe(true);

      // 通信を再開 / 401となっていたリクエスト,ブロック後に送付されたリクエストが再送される
      manager.restart();
      expect(manager.requests.length).toBe(7);
      expect(manager.requests[0].ajaxRequests.length).toBe(2);
      expect(manager.requests[1].ajaxRequests.length).toBe(2);
      expect(manager.requests[2].ajaxRequests.length).toBe(1);
      expect(manager.requests[3].ajaxRequests.length).toBe(1);
      expect(manager.requests[4].ajaxRequests.length).toBe(1);
      expect(manager.requests[5].ajaxRequests.length).toBe(1);
      expect(manager.requests[6].ajaxRequests.length).toBe(1);

      // すべてのリクエストが完了
      manager.requests[0].ajaxRequests[1].d.resolve([{}]);
      expect(xhr1.resolved()).toBe(true);
      expect(manager.isLoading()).toBe(true);

      manager.requests[1].ajaxRequests[1].d.reject(createErrorResponse(403));
      expect(xhr2.rejected()).toBe(true);
      expect(manager.isLoading()).toBe(true);

      manager.requests[4].ajaxRequests[0].d.resolve([{}]);
      expect(xhr5.resolved()).toBe(true);
      expect(manager.isLoading()).toBe(true);

      manager.requests[5].ajaxRequests[0].d.resolve([{}]);
      expect(xhr10.resolved()).toBe(true);
      expect(manager.isLoading()).toBe(true);

      manager.requests[6].ajaxRequests[0].d.reject(createErrorResponse(403));
      expect(xhr11.rejected()).toBe(true);

      // 最後のリクエストが終わるとローディングも終了
      expect(manager.isLoading()).toBe(false);
    });

    it("cancel()でリクエストがキャンセルされる。", () => {
      let stopped = false;

      let manager = ContainerJS.utils.Deferred.unpack(d);
      manager.supportRelogin = true;
      manager.addObserver("startBlocking", () => stopped = true);

      let xhr1 = manager.xhr("/test", "GET");
      let xhr2 = manager.xhr("/test2", "GET");
      let xhr3 = manager.xhr("/test3", "GET");

      expect(manager.isLoading()).toBe(true);
      expect(manager.requests.length).toBe(3);
      expect(manager.requests[0].ajaxRequests.length).toBe(1);
      expect(manager.requests[1].ajaxRequests.length).toBe(1);
      expect(manager.requests[2].ajaxRequests.length).toBe(1);

      // xhr1,xh2に401応答が返される
      manager.requests[0].ajaxRequests[0].d.reject(
        createErrorResponse(401));
      manager.requests[1].ajaxRequests[0].d.reject(
        createErrorResponse(401));

      // ブロックモードになる
      expect(stopped).toBe(true);

      // 結果はまだリクエスト元には通知されない
      expect(xhr1.fixed()).toBe(false);
      expect(xhr2.fixed()).toBe(false);
      expect(xhr3.fixed()).toBe(false);

      // ブロック中にリクエストを発行 / サーバーには送られない。
      let xhr10 = manager.xhr("/test10", "GET");

      expect(manager.requests.length).toBe(4);
      expect(manager.requests[0].ajaxRequests.length).toBe(1);
      expect(manager.requests[1].ajaxRequests.length).toBe(1);
      expect(manager.requests[2].ajaxRequests.length).toBe(1);
      expect(manager.requests[3].ajaxRequests.length).toBe(0);

      // キャンセル
      // 再送待ちのリクエストはすべてキャンセル
      manager.cancel();

      expect(xhr1.rejected()).toBe(true);
      expect(xhr2.rejected()).toBe(true);
      expect(xhr3.fixed()).toBe(false); // これは再送待ちではないのでキャンセルされない
      expect(xhr10.rejected()).toBe(true);

      // リクエストは再送されていない
      expect(manager.requests.length).toBe(4);
      expect(manager.requests[0].ajaxRequests.length).toBe(1);
      expect(manager.requests[1].ajaxRequests.length).toBe(1);
      expect(manager.requests[2].ajaxRequests.length).toBe(1);
      expect(manager.requests[3].ajaxRequests.length).toBe(0);

      // xhr3があるのでローディング中
      expect(manager.isLoading()).toBe(true);

      // xhr3が完了
      manager.requests[2].ajaxRequests[0].d.resolve([{}]);
      expect(xhr3.resolved()).toBe(true);

      // 最後のリクエストが終わるとローディングも終了
      expect(manager.isLoading()).toBe(false);
    });

    it("start()を呼び出してもGET以外のリクエストは再送されず、キャンセルとされる。", () => {

      let stopped = false;

      let manager = ContainerJS.utils.Deferred.unpack(d);
      manager.supportRelogin = true;
      manager.addObserver("startBlocking", () => stopped = true);

      let xhr1 = manager.xhr("/test", "PUT");
      let xhr2 = manager.xhr("/test2", "GET");
      let xhr3 = manager.xhr("/test3", "POST");
      let xhr4 = manager.xhr("/test4", "POST");

      expect(manager.isLoading()).toBe(true);
      expect(manager.requests.length).toBe(4);
      expect(manager.requests[0].ajaxRequests.length).toBe(1);
      expect(manager.requests[1].ajaxRequests.length).toBe(1);
      expect(manager.requests[2].ajaxRequests.length).toBe(1);
      expect(manager.requests[3].ajaxRequests.length).toBe(1);

      // xhr1に401応答が返される
      manager.requests[0].ajaxRequests[0].d.reject(
        createErrorResponse(401));

      // ブロックモードになる
      expect(stopped).toBe(true);

      // 結果はまだリクエスト元には通知されない
      expect(xhr1.fixed()).toBe(false);
      expect(xhr2.fixed()).toBe(false);
      expect(xhr3.fixed()).toBe(false);
      expect(xhr4.fixed()).toBe(false);

      // ブロック中にリクエストを発行 / サーバーには送られない。
      let xhr10 = manager.xhr("/test10", "DELETE");

      expect(manager.requests.length).toBe(5);
      expect(manager.requests[0].ajaxRequests.length).toBe(1);
      expect(manager.requests[1].ajaxRequests.length).toBe(1);
      expect(manager.requests[2].ajaxRequests.length).toBe(1);
      expect(manager.requests[3].ajaxRequests.length).toBe(1);
      expect(manager.requests[4].ajaxRequests.length).toBe(0);

      // xhr2,xhr3 も 401 でエラー
      manager.requests[1].ajaxRequests[0].d.reject(createErrorResponse(401));
      manager.requests[2].ajaxRequests[0].d.reject(createErrorResponse(401));

      // xhr4 は 200 で成功 / 結果がクライアントに通知される
      manager.requests[3].ajaxRequests[0].d.resolve([{}]);
      expect(xhr4.resolved()).toBe(true);

      // 1と2,3,10は未確定
      expect(xhr1.fixed()).toBe(false);
      expect(xhr2.fixed()).toBe(false);
      expect(xhr3.fixed()).toBe(false);
      expect(xhr10.fixed()).toBe(false);

      // すべてのリクエストが待ち状態になったので、一旦ローディングは完了
      expect(manager.isLoading()).toBe(false);

      // 通信を再開
      // 401となっていたGETリクエスト,ブロック後に送付されたGETリクエストが再送される
      // GET以外のリクエストは再送されずキャンセルとなる
      manager.restart();
      expect(manager.requests.length).toBe(5);
      expect(manager.requests[0].ajaxRequests.length).toBe(1);
      expect(manager.requests[1].ajaxRequests.length).toBe(2);
      expect(manager.requests[2].ajaxRequests.length).toBe(1);
      expect(manager.requests[3].ajaxRequests.length).toBe(1);
      expect(manager.requests[4].ajaxRequests.length).toBe(0);

      // 1と3,10が確定
      expect(xhr1.rejected()).toBe(true);
      expect(xhr2.fixed()).toBe(false);
      expect(xhr3.rejected()).toBe(true);
      expect(xhr10.rejected()).toBe(true);

      // xhr2があるのでローディング中
      expect(manager.isLoading()).toBe(true);

      // xhr2が完了
      manager.requests[1].ajaxRequests[1].d.resolve([{}]);
      expect(xhr2.resolved()).toBe(true);

      // 最後のリクエストが終わるとローディングも終了
      expect(manager.isLoading()).toBe(false);
    });
  });
});
