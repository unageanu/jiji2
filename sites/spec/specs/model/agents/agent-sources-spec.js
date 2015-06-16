import ContainerJS      from "container-js";
import ContainerFactory from "../../../utils/test-container-factory";

describe("Pairs", () => {

  var target;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("agentSources");
    target = ContainerJS.utils.Deferred.unpack(d);

    target.load();
    target.agentService.xhrManager.requests[0].resolve([
      {id: "1", name:"aaa"},
      {id: "2", name:"ccc"},
      {id: "3", name:"bbb"}
    ]);
    target.agentService.xhrManager.clear();
  });

  it("loadでソース一覧をロードできる", () => {
    expect(target.sources).toEqual([
      {id: "1", name:"aaa"},
      {id: "3", name:"bbb"},
      {id: "2", name:"ccc"}
    ]);
  });

  it("getBodyで本文を取得できる", () => {
    let d = target.getBody("2");
    target.agentService.xhrManager.requests[0].resolve({
      id:   "2",
      name: "ccc",
      body: "body"
    });

    let body = ContainerJS.utils.Deferred.unpack(d);
    expect(body).toEqual("body");

    body = ContainerJS.utils.Deferred.unpack(target.getBody("2"));
    expect(body).toEqual("body");
  });

  it("addでソースを登録できる", () => {
    let d = target.add("ddd", "");
    target.agentService.xhrManager.requests[0].resolve({
      id:   "4",
      name: "axx",
      body: ""
    });
    expect(target.sources).toEqual([
      {id: "1", name:"aaa"},
      {id: "4", name:"axx", body: ""},
      {id: "3", name:"bbb"},
      {id: "2", name:"ccc"}
    ]);
  });

  it("updateでソースを更新できる", () => {
    let d = target.add("ddd", "");
    target.agentService.xhrManager.requests[0].resolve({
      id:   "4",
      name: "axx",
      body: ""
    });
    expect(target.sources).toEqual([
      {id: "1", name:"aaa"},
      {id: "4", name:"axx", body: ""},
      {id: "3", name:"bbb"},
      {id: "2", name:"ccc"}
    ]);

    d = target.update("4", "fff", "body2");
    target.agentService.xhrManager.requests[1].resolve({
      id:   "4",
      name: "fff",
      body: "body2"
    });
    expect(target.sources).toEqual([
      {id: "1", name:"aaa"},
      {id: "3", name:"bbb"},
      {id: "2", name:"ccc"},
      {id: "4", name:"fff", body: "body2"}
    ]);
  });

  it("removeでソースを削除できる", () => {
    let d = target.remove("3");
    target.agentService.xhrManager.requests[0].resolve({});

    expect(target.sources).toEqual([
      {id: "1", name:"aaa"},
      {id: "2", name:"ccc"}
    ]);
  });

});
