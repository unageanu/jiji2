import ContainerJS      from "container-js";
import ContainerFactory from "../../../utils/test-container-factory";

describe("AgentSourceEditor", () => {

  var target;
  var log = [];
  var xhrManager;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("agentSourceEditor");
    target = ContainerJS.utils.Deferred.unpack(d);
    xhrManager = target.agentSources.agentService.xhrManager;

    target.load();
    xhrManager.requests[0].resolve([
      {id: "1", name:"aaa"},
      {id: "2", name:"ccc"},
      {id: "3", name:"bbb"}
    ]);
    xhrManager.clear();

    log = [];
    target.addObserver("propertyChanged", (n, e) => log.push(e));
    target.timeSource.now = new Date(2015,10,3, 4, 5);
  });

  it("loadでソース一覧をロードできる", () => {
    target.load();
    xhrManager.requests[0].resolve([
      {id: "1", name:"aaa"},
      {id: "2", name:"ccc"},
      {id: "3", name:"ddd"}
    ]);

    expect(log.length).toEqual(1);
    expect(log[0].key).toEqual("sources");
    expect(log[0].newValue).toEqual([
      {id: "1", name:"aaa"},
      {id: "2", name:"ccc"},
      {id: "3", name:"ddd"}
    ]);
  });

  describe("#startEdit", () => {
    it("startEditで編集を開始できる", () => {
      target.startEdit("2");
      expect(target.editTarget).toEqual({id: "2", name:"ccc"});
      expect(target.targetBody).toEqual(null);

      xhrManager.requests[0].resolve({
        id:   "2",
        name: "ccc",
        body: "body"
      });

      expect(target.editTarget).toEqual({id: "2", name:"ccc", body: "body"});
      expect(target.targetBody).toEqual("body");
    });

    it("編集対象が存在しない場合、未編集状態になる", () => {
      target.startEdit("2");
      xhrManager.requests[0].resolve({
        id:   "2",
        name: "ccc",
        body: "body"
      });

      target.startEdit("notFound");
      expect(target.editTarget).toEqual(null);
      expect(target.targetBody).toEqual(null);
    });
  });

  it("newSourceFileで新しいファイルを作成して編集を開始できる", () => {
    target.newSourceFile();
    xhrManager.requests[0].resolve({
      id:   "4",
      name: "new_agent.rb",
      body: ""
    });

    expect(target.editTarget).toEqual({
      id:   "4",
      name: "new_agent.rb",
      body: ""
    });
    expect(target.targetBody).toEqual("");

    target.newSourceFile();
    xhrManager.requests[1].resolve({
      id:   "5",
      name: "new_agent1.rb",
      body: ""
    });

    expect(target.editTarget).toEqual({
      id:   "5",
      name: "new_agent1.rb",
      body: ""
    });
    expect(target.targetBody).toEqual("");
  });

  it("saveで変更を永続化できる", () => {
    target.newSourceFile();
    xhrManager.requests[0].resolve({
      id:   "4",
      name: "new_agent.rb",
      body: ""
    });

    target.save("axx", "body");
    expect(target.isSaving).toEqual(true);
    expect(target.savedLabel).toEqual(null);

    xhrManager.requests[1].resolve({
      id:   "4",
      name: "axx",
      body: "body"
    });

    expect(target.isSaving).toEqual(false);
    expect(target.savedLabel).toEqual('※保存しました。 ( 2015-11-03 04:05:00 )');
    expect(target.editTarget).toEqual({
      id:   "4",
      name: "axx",
      body: "body"
    });
    expect(target.targetBody).toEqual("body");

    target.save("axx", "body");
    expect(target.isSaving).toEqual(true);
    expect(target.savedLabel).toEqual(null);

    xhrManager.requests[2].reject({
      status: 500
    });
    expect(target.isSaving).toEqual(false);
    expect(target.savedLabel).toEqual(null);
  });

  it("removeでソースを削除できる", () => {

    target.startEdit("2");
    expect(target.editTarget).toEqual({id: "2", name:"ccc"});
    expect(target.targetBody).toEqual(null);

    xhrManager.requests[0].resolve({
      id:   "2",
      name: "ccc",
      body: "body"
    });

    expect(target.editTarget).toEqual({id: "2", name:"ccc", body: "body"});
    expect(target.targetBody).toEqual("body");

    target.remove();
    xhrManager.requests[1].resolve({});

    expect(target.agentSources.sources).toEqual([
      {id: "1", name:"aaa"},
      {id: "3", name:"bbb"}
    ]);
    expect(target.editTarget).toEqual(null);
    expect(target.targetBody).toEqual(null);

  });

});
