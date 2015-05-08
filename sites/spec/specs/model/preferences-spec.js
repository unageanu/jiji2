import ContainerJS      from "container-js";
import ContainerFactory from "../../utils/test-container-factory";


describe("Preferences", () => {

  var preferences;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("preferences");
    preferences = ContainerJS.utils.Deferred.unpack(d);

    preferences.pairs.initialize();
    preferences.pairs.rateService.xhrManager.requests[0].resolve([
      {pairName:"USDJPY", pairId:1},
      {pairName:"EURUSD", pairId:2},
      {pairName:"EURJPY", pairId:3}
    ]);
  });

  it("初期値", () => {
    expect(preferences.preferredPairs.length).toBe(1);
    expect(preferences.preferredPairs[0]).toBe("USDJPY");
    expect(preferences.chartInterval).toBe("one_minute");
  });

  it("最近見た通貨ペアを設定できる", () => {

    var pairs = null;
    preferences.addObserver("propertyChanged", (n, ev) => pairs = ev.newValue );

    preferences.preferredPair = "EURUSD";
    expect(preferences.preferredPairs.length).toBe(2);
    expect(pairs[0]).toBe("EURUSD");
    expect(pairs[1]).toBe("USDJPY");

    preferences.preferredPair = "EURJPY";
    expect(preferences.preferredPairs.length).toBe(3);
    expect(pairs[0]).toBe("EURJPY");
    expect(pairs[1]).toBe("EURUSD");
    expect(pairs[2]).toBe("USDJPY");

    preferences.preferredPair = "USDJPY";
    expect(preferences.preferredPairs.length).toBe(3);
    expect(pairs[0]).toBe("USDJPY");
    expect(pairs[1]).toBe("EURJPY");
    expect(pairs[2]).toBe("EURUSD");

    preferences.preferredPair = "EURJPY";
    expect(preferences.preferredPairs.length).toBe(3);
    expect(pairs[0]).toBe("EURJPY");
    expect(pairs[1]).toBe("USDJPY");
    expect(pairs[2]).toBe("EURUSD");
  });

  it("チャートの集計期間を設定できる", () => {
    preferences.chartInterval = "one_hours";
    expect(preferences.chartInterval).toBe("one_hours");
  });

  it("設定値を永続化できる", () => {
    preferences.preferredPair = "EURUSD";
    preferences.preferredPair = "EURJPY";
    preferences.preferredPair = "EURUSD";
    preferences.chartInterval = "one_hours";

    preferences.restoreState();
    expect(preferences.preferredPairs.length).toBe(3);
    expect(preferences.preferredPairs[0]).toBe("EURUSD");
    expect(preferences.preferredPairs[1]).toBe("EURJPY");
    expect(preferences.preferredPairs[2]).toBe("USDJPY");
    expect(preferences.chartInterval).toBe("one_hours");
  });

  it("存在しない通貨ペアが使われていた場合、pairsの取得後に削除される", () => {
    preferences.preferredPair = "EURUSD";
    preferences.preferredPair = "UNKNOWN1";
    preferences.preferredPair = "EURJPY";
    preferences.preferredPair = "UNKNOWN2";
    preferences.chartInterval = "one_hours";
    expect(preferences.preferredPairs.length).toBe(5);

    preferences.pairs.reload();
    preferences.pairs.rateService.xhrManager.requests[1].resolve([
      {pairName:"USDJPY", pairId:1},
      {pairName:"EURUSD", pairId:2}
    ]);
    expect(preferences.preferredPairs.length).toBe(2);
    expect(preferences.preferredPairs[0]).toBe("EURUSD");
    expect(preferences.preferredPairs[1]).toBe("USDJPY");
    expect(preferences.chartInterval).toBe("one_hours");
  });

});
