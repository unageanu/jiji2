import ContainerJS          from "container-js"
import ContainerFactory     from "../../../utils/test-container-factory"
import AgentSettingBuilder from "src/viewmodel/agents/agent-setting-builder"

describe("AgentSettingBuilder", () => {

  var target;
  var xhrManager;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d  = container.get("agentClasses");
    const agentClasses = ContainerJS.utils.Deferred.unpack(d);
    let d2 = container.get("icons");
    const icons = ContainerJS.utils.Deferred.unpack(d2);
    target = new AgentSettingBuilder(agentClasses, icons);
    xhrManager = agentClasses.agentService.xhrManager;

    target.initialize();
    xhrManager.requests[0].resolve([
      {id:1}
    ]);
    xhrManager.requests[1].resolve([
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
    target.addAgent("TestClassA@あ");
    expect(target.selectedAgent).toEqual(
      {agentClass:"TestClassA@あ", agentName:"TestClassA@あ", properties: {}});
    target.addAgent("TestClassA@あ", {a:"aa"});
    expect(target.selectedAgent).toEqual(
      {agentClass:"TestClassA@あ", agentName:"TestClassA@あ", properties: {a:"aa"}});
    target.addAgent("TestClassC@い", {b:"bb"});
    expect(target.selectedAgent).toEqual(
      {agentClass:"TestClassC@い", agentName:"TestClassC@い", properties: {b:"bb"}});

    expect(target.agentSetting).toEqual([
      {agentClass:"TestClassA@あ", agentName:"TestClassA@あ", properties: {}},
      {agentClass:"TestClassA@あ", agentName:"TestClassA@あ", properties: {a:"aa"}},
      {agentClass:"TestClassC@い", agentName:"TestClassC@い", properties: {b:"bb"}}
    ]);
  });

  it("エージェントを削除できる", () => {
    target.addAgent("TestClassA@あ");
    target.addAgent("TestClassA@あ", {a:"aa"});
    target.addAgent("TestClassC@い", {b:"bb"});

    target.selectedAgent = target.agentSetting[1];
    target.removeSelectedAgent();
    expect(target.agentSetting).toEqual([
      {agentClass:"TestClassA@あ", agentName:"TestClassA@あ", properties: {}},
      {agentClass:"TestClassC@い", agentName:"TestClassC@い", properties: {b:"bb"}}
    ]);
    expect(target.selectedAgent).toEqual(
      {agentClass:"TestClassA@あ", agentName:"TestClassA@あ", properties: {}});

    target.removeSelectedAgent();
    expect(target.agentSetting).toEqual([
      {agentClass:"TestClassC@い", agentName:"TestClassC@い", properties: {b:"bb"}}
    ]);
    expect(target.selectedAgent).toEqual(
      {agentClass:"TestClassC@い", agentName:"TestClassC@い", properties: {b:"bb"}});

    target.removeSelectedAgent();
    expect(target.selectedAgent).toEqual(null);
  });

  it("エージェントのプロパティを更新できる", () => {
    target.addAgent("TestClassA@あ");
    target.addAgent("TestClassA@あ", {a:"aa"});
    target.addAgent("TestClassC@い", {b:"bb"});

    target.selectedAgent = target.agentSetting[1];
    target.updateSelectedAgent("テスト", "aaa", {c:"cc"});

    target.selectedAgent = target.agentSetting[0];
    target.updateSelectedAgent("", null, {a:"aa"});
    expect(target.agentSetting).toEqual([
      {agentClass:"TestClassA@あ", agentName: "",  iconId: null, properties: {a:"aa"}},
      {agentClass:"TestClassA@あ", agentName: "テスト", iconId: "aaa", properties: {c:"cc"}},
      {agentClass:"TestClassC@い", agentName: "TestClassC@い", properties: {b:"bb"}}
    ]);
  });

  it("getAgentClassでエージェントの定義を取得できる", () => {
    target.addAgent("TestClassA@あ");
    target.addAgent("TestClassC@い", {b:"bb"});

    target.selectedAgent = target.agentSetting[0];
    expect(target.getAgentClassForSelected()).toEqual(
      {name:"TestClassA@あ", description:"aaa"});
    target.selectedAgent = target.agentSetting[1];
    expect(target.getAgentClassForSelected()).toEqual(
      {name:"TestClassC@い", description:"ccc"});
  });

});
