import ContainerJS      from "container-js";
import ContainerFactory from "../../../utils/test-container-factory";
import _                from "underscore";

describe("Pairs", () => {

  var pairs;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("pairs");
    pairs = ContainerJS.utils.Deferred.unpack(d);
  });

  it("初期値", () => {
    expect(pairs.pairs.length).toBe(0);
  });

  it("initializeで通貨ペアの一覧をロードできる", () => {

    pairs.initialize();
    pairs.rateService.xhrManager.requests[0].resolve([
      {"pair_id": 0, "name": "USDJPY"},
      {"pair_id": 1, "name": "EURJPY"},
      {"pair_id": 2, "name": "EURUSD"}
    ]);

    expect(_.isEqual(pairs.pairs, [
      {"pair_id": 0, "name": "USDJPY"},
      {"pair_id": 1, "name": "EURJPY"},
      {"pair_id": 2, "name": "EURUSD"}
    ])).toBe(true);

  });

  it("reloadで通貨ペアの一覧を再ロードできる", () => {

    pairs.initialize();
    pairs.rateService.xhrManager.requests[0].resolve([
      {"pair_id": 0, "name": "USDJPY"},
      {"pair_id": 1, "name": "EURJPY"},
      {"pair_id": 2, "name": "EURUSD"}
    ]);

    pairs.reload();
    pairs.rateService.xhrManager.requests[1].resolve([
      {"pair_id": 0, "name": "USDJPY"},
      {"pair_id": 1, "name": "EURJPY"}
    ]);

    expect(_.isEqual(pairs.pairs, [
      {"pair_id": 0, "name": "USDJPY"},
      {"pair_id": 1, "name": "EURJPY"}
    ])).toBe(true);

  });
});
