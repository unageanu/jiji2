import ContainerJS      from "container-js";
import ContainerFactory from "../../../utils/test-container-factory";

describe("AgentClasses", () => {

  var target;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("agentClasses");
    target = ContainerJS.utils.Deferred.unpack(d);

    target.load();
    target.agentService.xhrManager.requests[0].resolve([
      {name:"a", description:"aaa"},
      {name:"c", description:"bbb"},
      {name:"b", description:"ccc"}
    ]);
    target.agentService.xhrManager.clear();
  });

  it("loadでソース一覧をロードできる", () => {
    expect(target.classes).toEqual([
      {name:"a", description:"aaa"},
      {name:"b", description:"ccc"},
      {name:"c", description:"bbb"}
    ]);
  });

  it("getで名前に対応するクラスを取得できる", () => {
    expect(target.get("a")).toEqual({name:"a", description:"aaa"});
    expect(target.get("b")).toEqual({name:"b", description:"ccc"});
  });

});
