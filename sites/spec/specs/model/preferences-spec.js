import ContainerJS      from "container-js";
import ContainerFactory from "../../utils/test-container-factory";


describe("Preferences", () => {

  var preferences;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("preferences");
    preferences = ContainerJS.utils.Deferred.unpack(d);
  });

  it("初期値", () => {
    expect(preferences.preferredPairs.length).toBe(0);
    expect(preferences.chartInterval).toBe("one_minute");
  });

  it("最近見た通貨ペアを設定できる", () => {

    var pairs = null;
    preferences.addObserver("changed", (n, ev) => pairs = ev.value );

    preferences.preferredPair = "EURUSD";
    expect(preferences.preferredPairs.length).toBe(1);
    expect(pairs[0]).toBe("EURUSD");

    preferences.preferredPair = "EURJPY";
    expect(preferences.preferredPairs.length).toBe(2);
    expect(pairs[0]).toBe("EURJPY");
    expect(pairs[1]).toBe("EURUSD");

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
    expect(preferences.preferredPairs.length).toBe(2);
    expect(preferences.preferredPairs[0]).toBe("EURUSD");
    expect(preferences.preferredPairs[1]).toBe("EURJPY");
    expect(preferences.chartInterval).toBe("one_hours");
  });

});
