import ContainerJS          from "container-js"
import ContainerFactory     from "../../../utils/test-container-factory"
import  AgentSettingBuilder from "src/model/trading/agent-setting-builder"

describe("AgentSettingBuilder", () => {

  var target;
  var xhrManager;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("agentClasses");
    const agentClasses = ContainerJS.utils.Deferred.unpack(d);
    target = new AgentSettingBuilder(agentClasses);
    xhrManager = agentClasses.agentService.xhrManager;

    target.initialize();
    xhrManager.requests[0].resolve([
      {name:"TestClassA@あ", description:"aaa"},
      {name:"TestClassB@あ", description:"bbb"},
      {name:"TestClassC@い", description:"ccc"}
    ]);
    xhrManager.clear();
  });

  it("initializeで状態を初期化できる", () => {
    expect(target.agentSetting).toEqual([]);
    expect(target.agentClasses.classes.length).toEqual(3);
  });

  it("エージェントを追加できる", () => {
    expect(target.addAgent("TestClassA@あ")).toEqual(0);
    expect(target.addAgent("TestClassA@あ", {a:"aa"})).toEqual(1);
    expect(target.addAgent("TestClassC@い", {b:"bb"})).toEqual(2);
    expect(target.agentSetting).toEqual([
      {agentClass:"TestClassA@あ", agentName:"TestClassA@あ", properties: {}},
      {agentClass:"TestClassA@あ", agentName:"TestClassA@あ", properties: {a:"aa"}},
      {agentClass:"TestClassC@い", agentName:"TestClassC@い", properties: {b:"bb"}}
    ]);
  });

  it("エージェントを削除できる", () => {
    expect(target.addAgent("TestClassA@あ")).toEqual(0);
    expect(target.addAgent("TestClassA@あ", {a:"aa"})).toEqual(1);
    expect(target.addAgent("TestClassC@い", {b:"bb"})).toEqual(2);

    target.removeAgent(1);
    expect(target.agentSetting).toEqual([
      {agentClass:"TestClassA@あ", agentName:"TestClassA@あ", properties: {}},
      {agentClass:"TestClassC@い", agentName:"TestClassC@い", properties: {b:"bb"}}
    ]);
    target.removeAgent(1);
    expect(target.agentSetting).toEqual([
      {agentClass:"TestClassA@あ", agentName:"TestClassA@あ", properties: {}}
    ]);
    target.removeAgent(0);
    expect(target.agentSetting).toEqual([]);
  });

  it("エージェントのプロパティを更新できる", () => {
    expect(target.addAgent("TestClassA@あ")).toEqual(0);
    expect(target.addAgent("TestClassA@あ", {a:"aa"})).toEqual(1);
    expect(target.addAgent("TestClassC@い", {b:"bb"})).toEqual(2);

    target.updateAgentConfiguration(1, "テスト", {c:"cc"});
    target.updateAgentConfiguration(0, "", {a:"aa"});
    expect(target.agentSetting).toEqual([
      {agentClass:"TestClassA@あ", agentName: "", properties: {a:"aa"}},
      {agentClass:"TestClassA@あ", agentName: "テスト", properties: {c:"cc"}},
      {agentClass:"TestClassC@い", agentName: "TestClassC@い", properties: {b:"bb"}}
    ]);
  });

  it("getAgentClassでエージェントの定義を取得できる", () => {
    expect(target.addAgent("TestClassA@あ")).toEqual(0);
    expect(target.addAgent("TestClassC@い", {b:"bb"})).toEqual(1);

    expect(target.getAgentClass(0)).toEqual(
      {name:"TestClassA@あ", description:"aaa"});
    expect(target.getAgentClass(1)).toEqual(
      {name:"TestClassC@い", description:"ccc"});
  });

});
