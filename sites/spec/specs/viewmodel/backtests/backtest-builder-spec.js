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
      {id:1}
    ]);
    xhrManager.requests[1].resolve([
      {name:"TestClassA@あ", description:"aaa"},
      {name:"TestClassB@あ", description:"bbb"},
      {name:"TestClassC@い", description:"ccc"}
    ]);
    xhrManager.requests[2].resolve([
      {name: "EURJPY", internalId: "EUR_JPY"},
      {name: "USDJPY", internalId: "USD_JPY"},
      {name: "EURUSD", internalId: "EUR_USD"}
    ]);
    xhrManager.requests[3].resolve({
      start: new Date(2015, 4, 1,  10, 0,  0),
      end:   new Date(2015, 6, 10, 21, 0, 10)
    });
    xhrManager.clear();
  });

  it("initializeで状態を初期化できる", () => {
    expect(target.name).toEqual("");
    expect(target.memo).toEqual("");
    expect(target.rangeSelectorModel.startTime).toEqual(new Date(2015, 4, 27));
    expect(target.rangeSelectorModel.endTime).toEqual(new Date(2015, 5, 3));
    expect(target.agentSetting).toEqual([]);
    expect(target.pairSelectorModel.pairNames).toEqual([]);
    expect(target.balance).toEqual(1000000);

    expect(target.pairs.pairs.length).toEqual(3);
    expect(target.rates.range).toEqual({
      start: new Date(2015, 4, 1,  10, 0,  0),
      end:   new Date(2015, 6, 10, 21, 0, 10)
    });
    expect(target.agentClasses.classes.length).toEqual(3);

    expect( target.validate() ).toBe(false);
    expect( target.nameError ).toBe("テスト名を入力してください");
    expect( target.memoError ).toBe(null);
    expect( target.balanceError ).toBe(null);
    expect( target.agentSettingBuilder.agentSettingError ).toBe("エージェントが設定されていません");
    expect( target.rangeSelectorModel.startTimeError ).toBe(null);
    expect( target.rangeSelectorModel.endTimeError ).toBe(null);
    expect( target.pairSelectorModel.pairNamesError ).toBe("通貨ペアが設定されていません");
  });

  it("エージェントを追加できる", () => {
    target.addAgent("TestClassA@あ");
    target.addAgent("TestClassA@あ", {a:"aa"});
    target.addAgent("TestClassC@い", {b:"bb"});
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

    target.agentSettingBuilder.selectedAgent = target.agentSetting[1];
    target.removeSelectedAgent();
    expect(target.agentSetting).toEqual([
      {agentClass:"TestClassA@あ", agentName:"TestClassA@あ", properties: {}},
      {agentClass:"TestClassC@い", agentName:"TestClassC@い", properties: {b:"bb"}}
    ]);
    target.agentSettingBuilder.selectedAgent = target.agentSetting[1];
    target.removeSelectedAgent();
    expect(target.agentSetting).toEqual([
      {agentClass:"TestClassA@あ", agentName:"TestClassA@あ", properties: {}}
    ]);
    target.agentSettingBuilder.selectedAgent = target.agentSetting[0];
    target.removeSelectedAgent();
    expect(target.agentSetting).toEqual([]);
  });

  it("エージェントのプロパティを更新できる", () => {
    target.addAgent("TestClassA@あ");
    target.addAgent("TestClassA@あ", {a:"aa"});
    target.addAgent("TestClassC@い", {b:"bb"});

    target.agentSettingBuilder.selectedAgent = target.agentSetting[1];
    target.updateSelectedAgent( "テスト", "bbb", {c:"cc"});
    target.agentSettingBuilder.selectedAgent = target.agentSetting[0];
    target.updateSelectedAgent( "", null, {a:"aa"});
    expect(target.agentSetting).toEqual([
      {agentClass:"TestClassA@あ", agentName: "", iconId: null,properties: {a:"aa"}},
      {agentClass:"TestClassA@あ", agentName: "テスト", iconId: "bbb", properties: {c:"cc"}},
      {agentClass:"TestClassC@い", agentName: "TestClassC@い", properties: {b:"bb"}}
    ]);
  });

  it("必要な値を一通り設定した状態でbuildすると、バックテストを作成できる", () => {
    target.name = "テスト";
    target.addAgent("TestClassA@あ");
    target.pairSelectorModel.pairNames = ["EURJPY", "USDJPY"];

    expect( target.validate() ).toBe(true);
    expect( target.nameError ).toBe(null);
    expect( target.memoError ).toBe(null);
    expect( target.balanceError ).toBe(null);
    expect( target.agentSettingBuilder.agentSettingError ).toBe(null);
    expect( target.rangeSelectorModel.startTimeError ).toBe(null);
    expect( target.rangeSelectorModel.endTimeError ).toBe(null);
    expect( target.pairSelectorModel.pairNamesError ).toBe(null);

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
    target.rangeSelectorModel.startTime = new Date(2015, 3, 17);
    target.addAgent("TestClassA@あ", {a:"aa"});
    target.addAgent("TestClassC@い", {b:"bb"});
    target.agentSettingBuilder.selectedAgent = target.agentSetting[1];
    target.removeSelectedAgent();
    target.agentSettingBuilder.selectedAgent = target.agentSetting[1];
    target.updateSelectedAgent("テスト", "ccc", {c:"cc"});
    target.pairSelectorModel.pairNames = ["EURJPY", "USDJPY", "EURUSD", "AUDJPY", "CADJPY"];
    target.balance   = 2000000;

    expect( target.validate() ).toBe(true);
    expect( target.nameError ).toBe(null);
    expect( target.memoError ).toBe(null);
    expect( target.balanceError ).toBe(null);
    expect( target.agentSettingBuilder.agentSettingError ).toBe(null);
    expect( target.rangeSelectorModel.startTimeError ).toBe(null);
    expect( target.rangeSelectorModel.endTimeError ).toBe(null);
    expect( target.pairSelectorModel.pairNamesError ).toBe(null);

    target.build();
    expect(xhrManager.requests[1].body).toEqual({
      name:         "テスト",
      memo:         "テストメモ",
      startTime:    new Date(2015, 3, 17),
      endTime:      new Date(2015, 5, 3),
      agentSetting: [
        {agentClass:"TestClassA@あ", agentName: "TestClassA@あ", properties: {}},
        {agentClass:"TestClassC@い", agentName: "テスト", iconId: "ccc", properties: {c:"cc"}}
      ],
      pairNames:    ["EURJPY", "USDJPY", "EURUSD", "AUDJPY", "CADJPY"],
      balance:      2000000
    });
  });

  it("getAgentClassでエージェントの定義を取得できる", () => {
    target.addAgent("TestClassA@あ");
    target.addAgent("TestClassC@い", {b:"bb"});

    target.agentSettingBuilder.selectedAgent = target.agentSetting[0];
    expect(target.getAgentClassForSelected()).toEqual(
      {name:"TestClassA@あ", description:"aaa"});
    target.agentSettingBuilder.selectedAgent = target.agentSetting[1];
    expect(target.getAgentClassForSelected()).toEqual(
      {name:"TestClassC@い", description:"ccc"});
  });

  describe("#validate", () => {

    beforeEach(() => {
      target.name = "テスト";
      target.addAgent("TestClassA@あ");
      target.pairSelectorModel.pairNames = ["EURJPY", "USDJPY"];
    });

    it("テスト名が未設定の場合", () => {
      target.name = "";

      expect( target.validate() ).toBe(false);
      expect( target.nameError ).toBe("テスト名を入力してください");
      expect( target.memoError ).toBe(null);
      expect( target.balanceError ).toBe(null);
      expect( target.agentSettingBuilder.agentSettingError ).toBe(null);
      expect( target.rangeSelectorModel.startTimeError ).toBe(null);
      expect( target.rangeSelectorModel.endTimeError ).toBe(null);
      expect( target.pairSelectorModel.pairNamesError ).toBe(null);
    });

    it("エージェントが未登録の場合", () => {
      target.removeSelectedAgent();

      expect( target.validate() ).toBe(false);
      expect( target.nameError ).toBe(null);
      expect( target.memoError ).toBe(null);
      expect( target.balanceError ).toBe(null);
      expect( target.agentSettingBuilder.agentSettingError ).toBe("エージェントが設定されていません");
      expect( target.rangeSelectorModel.startTimeError ).toBe(null);
      expect( target.rangeSelectorModel.endTimeError ).toBe(null);
      expect( target.pairSelectorModel.pairNamesError ).toBe(null);
    });
    it("通貨ペアの選択肢が多すぎる場合", () => {
      target.pairSelectorModel.pairNames =
        ["EURJPY", "USDJPY", "EURUSD", "AUDJPY", "CADJPY", "CADUSD"];

      expect( target.validate() ).toBe(false);
      expect( target.nameError ).toBe(null);
      expect( target.memoError ).toBe(null);
      expect( target.balanceError ).toBe(null);
      expect( target.agentSettingBuilder.agentSettingError ).toBe(null);
      expect( target.rangeSelectorModel.startTimeError ).toBe(null);
      expect( target.rangeSelectorModel.endTimeError ).toBe(null);
      expect( target.pairSelectorModel.pairNamesError ).toBe(
        "通貨ペアは5つ以上選択できません");
    });

    it("初期資金が数値でない場合", () => {
      target.balance = "a"

      expect( target.validate() ).toBe(false);
      expect( target.nameError ).toBe(null);
      expect( target.memoError ).toBe(null);
      expect( target.balanceError ).toBe("初期資金は半角数字で入力してください");
      expect( target.agentSettingBuilder.agentSettingError ).toBe(null);
      expect( target.rangeSelectorModel.startTimeError ).toBe(null);
      expect( target.rangeSelectorModel.endTimeError ).toBe(null);
      expect( target.pairSelectorModel.pairNamesError ).toBe(null);
    });

    it("メモが長すぎる場合", () => {
      let str = "";
      for (let i=0;i<2001;i++) {
        str += "a";
      }
      target.memo = str;

      expect( target.validate() ).toBe(false);
      expect( target.nameError ).toBe(null);
      expect( target.memoError ).toBe("メモが長すぎます");
      expect( target.balanceError ).toBe(null);
      expect( target.agentSettingBuilder.agentSettingError ).toBe(null);
      expect( target.rangeSelectorModel.startTimeError ).toBe(null);
      expect( target.rangeSelectorModel.endTimeError ).toBe(null);
      expect( target.pairSelectorModel.pairNamesError ).toBe(null);
    });

    it("開始/終了期間が未設定の場合場合", () => {
      target.rangeSelectorModel.startTime = null;
      target.rangeSelectorModel.endTime   = null;

      expect( target.validate() ).toBe(false);
      expect( target.nameError ).toBe(null);
      expect( target.memoError ).toBe(null);
      expect( target.balanceError ).toBe(null);
      expect( target.agentSettingBuilder.agentSettingError ).toBe(null);
      expect( target.rangeSelectorModel.startTimeError ).toBe("開始日時を入力してください");
      expect( target.rangeSelectorModel.endTimeError ).toBe("終了日時を入力してください");
      expect( target.pairSelectorModel.pairNamesError ).toBe(null);
    });
  })
});
