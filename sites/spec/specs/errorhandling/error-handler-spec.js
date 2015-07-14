import ContainerJS      from "container-js";
import ContainerFactory from "../../utils/test-container-factory";

describe("ErrorHandler", () => {

  var errorHandler;
  var xhrManager;
  var errorEventQueue;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("errorHandler");
    errorHandler      = ContainerJS.utils.Deferred.unpack(d);
    xhrManager        = errorHandler.xhrManager;
    errorEventQueue   = errorHandler.errorEventQueue;
  });

  it("handle(error)でerrorに対応するメッセージが、queueに積まれる", () => {
    errorHandler.handle({
      code: "NOT_EMPTY",
      field: "ファイル名"
    });
    expect(errorEventQueue.queue).toEqual([{
      message: "ファイル名を入力してください"
    }]);
  });

  it("通信エラーが発生すると、queueにイベントが積まれる", () => {
    xhrManager.fire("error", {
      code: "NOT_FOUND"
    });
    expect(errorEventQueue.queue).toEqual([{
      message:"データが見つかりません<br/>画面を再読み込みして最新の情報に更新してください"
    }]);
  });

  it("処理済みのエラーは無視される", () => {
    xhrManager.fire("error", {
      code: "NOT_FOUND",
      preventDefault: true
    });
    expect(errorEventQueue.queue).toEqual([]);

    errorHandler.handle({
      code: "NOT_EMPTY",
      field: "ファイル名",
      preventDefault: true
    });
    expect(errorEventQueue.queue).toEqual([]);
  });

  it("認証エラーが発生すると、queueにログイン画面への遷移イベントが積まれる", () => {
    xhrManager.fire("startBlocking", {});
    expect(errorEventQueue.queue).toEqual([{route:"/login"}]);
  });

});
