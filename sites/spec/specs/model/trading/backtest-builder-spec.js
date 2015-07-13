import ContainerJS      from "container-js";
import ContainerFactory from "../../../utils/test-container-factory";

describe("BacktestBuiler", () => {

  var target;
  var xhrManager;
  var timeSource;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("backtestBuilder");
    target = ContainerJS.utils.Deferred.unpack(d);
    xhrManager = target.agentClasses.agentService.xhrManager;
    timeSource = target.timeSource;
    timeSource.now = new Date(2015, 5, 3);

    target.initialize();
    xhrManager.requests[0].resolve([
      {name:"TestClassA@あ", description:"aaa"},
      {name:"TestClassB@あ", description:"bbb"},
      {name:"TestClassC@い", description:"ccc"}
    ]);
    xhrManager.requests[1].resolve([
      {name: "EURJPY", internalId: "EUR_JPY"},
      {name: "USDJPY", internalId: "USD_JPY"},
      {name: "EURUSD", internalId: "EUR_USD"}
    ]);
    xhrManager.requests[2].resolve({
      start: new Date(2015, 4, 1,  10, 0,  0),
      end:   new Date(2015, 6, 10, 21, 0, 10)
    });
    xhrManager.clear();
  });

  it("initializeで状態を初期化できる", () => {
    expect(target.name).toEqual("");
    expect(target.memo).toEqual("");
    expect(target.startTime).toEqual(new Date(2015, 4, 27));
    expect(target.endTime).toEqual(new Date(2015, 5, 3));
    expect(target.agentSetting).toEqual([]);
    expect(target.pairNames).toEqual([]);
    expect(target.balance).toEqual(1000000);

    expect(target.pairs.pairs.length).toEqual(3);
    expect(target.rates.range).toEqual({
      start: new Date(2015, 4, 1,  10, 0,  0),
      end:   new Date(2015, 6, 10, 21, 0, 10)
    });
    expect(target.agentClasses.classes.length).toEqual(3);

    expect( () => target.build() ).toThrowError();
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

  it("必要な値を一通り設定した状態でbuildすると、バックテストを作成できる", () => {
    target.name = "テスト";
    target.addAgent("TestClassA@あ");
    target.pairNames = ["EURJPY", "USDJPY"];
    target.build();
    expect(xhrManager.requests[0].body).toEqual({
      name:         "テスト",
      memo:         "",
      startTime:    new Date(2015, 4, 27),
      endTime:      new Date(2015, 5, 3),
      agentSetting: [
        {agentClass:"TestClassA@あ", agentName:"TestClassA@あ", properties: {}}
      ],
      pairNames:    ["EURJPY", "USDJPY"],
      balance:      1000000
    });

    target.memo = "テストメモ";
    target.startTime = new Date(2015, 3, 17);
    target.addAgent("TestClassA@あ", {a:"aa"});
    target.addAgent("TestClassC@い", {b:"bb"});
    target.removeAgent(1);
    target.updateAgentConfiguration(1, "テスト", {c:"cc"});
    target.pairNames = ["EURJPY", "USDJPY", "EURUSD", "AUDJPY", "CADJPY"];
    target.balance   = 2000000;
    target.build();
    expect(xhrManager.requests[1].body).toEqual({
      name:         "テスト",
      memo:         "テストメモ",
      startTime:    new Date(2015, 3, 17),
      endTime:      new Date(2015, 5, 3),
      agentSetting: [
        {agentClass:"TestClassA@あ", agentName: "TestClassA@あ", properties: {}},
        {agentClass:"TestClassC@い", agentName: "テスト", properties: {c:"cc"}}
      ],
      pairNames:    ["EURJPY", "USDJPY", "EURUSD", "AUDJPY", "CADJPY"],
      balance:      2000000
    });
  });

  it("getAgentClassでエージェントの定義を取得できる", () => {
    expect(target.addAgent("TestClassA@あ")).toEqual(0);
    expect(target.addAgent("TestClassC@い", {b:"bb"})).toEqual(1);

    expect(target.getAgentClass(0)).toEqual(
      {name:"TestClassA@あ", description:"aaa"});
    expect(target.getAgentClass(1)).toEqual(
      {name:"TestClassC@い", description:"ccc"});
  });

  it("エージェントが未登録の場合、build時にエラーになる。", () => {
    target.name = "テスト";
    target.pairNames = ["EURJPY", "USDJPY"];
    expect( () => target.build() ).toThrowError();
  });
  it("通貨ペアが未設定の場合、build時にエラーになる。", () => {
    target.name = "テスト";
    target.addAgent("TestClassA@あ", {a:"aa"});
    expect( () => target.build() ).toThrowError();
  });
});
