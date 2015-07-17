import ContainerJS      from "container-js";
import ContainerFactory from "../../../utils/test-container-factory";

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

    expect(pairs.pairs).toEqual([
      {"pair_id": 0, "name": "USDJPY"},
      {"pair_id": 1, "name": "EURJPY"},
      {"pair_id": 2, "name": "EURUSD"}
    ]);

  });

  it("initializeの結果はキャッシュされる。", () => {
    const d1 = pairs.initialize();
    const d2 = pairs.initialize();
    pairs.rateService.xhrManager.requests[0].resolve([
      {"pair_id": 0, "name": "USDJPY"},
      {"pair_id": 1, "name": "EURJPY"},
      {"pair_id": 2, "name": "EURUSD"}
    ]);

    expect(ContainerJS.utils.Deferred.unpack(d1)).toEqual([
      {"pair_id": 0, "name": "USDJPY"},
      {"pair_id": 1, "name": "EURJPY"},
      {"pair_id": 2, "name": "EURUSD"}
    ]);
    expect(ContainerJS.utils.Deferred.unpack(d2)).toEqual([
      {"pair_id": 0, "name": "USDJPY"},
      {"pair_id": 1, "name": "EURJPY"},
      {"pair_id": 2, "name": "EURUSD"}
    ]);

    const d3 = pairs.initialize();
    expect(ContainerJS.utils.Deferred.unpack(d3)).toEqual([
      {"pair_id": 0, "name": "USDJPY"},
      {"pair_id": 1, "name": "EURJPY"},
      {"pair_id": 2, "name": "EURUSD"}
    ]);
  });

  it("initializeでエラーとなった場合、結果はキャッシュされない。", () => {
    const d1 = pairs.initialize();
    const d2 = pairs.initialize();
    pairs.rateService.xhrManager.requests[0].reject({});

    expect(() => {
      ContainerJS.utils.Deferred.unpack(d1);
    }).toThrowError();
    expect(() => {
      ContainerJS.utils.Deferred.unpack(d2);
    }).toThrowError();

    const d3 = pairs.initialize();
    pairs.rateService.xhrManager.requests[1].resolve([
      {"pair_id": 0, "name": "USDJPY"},
      {"pair_id": 1, "name": "EURJPY"}
    ]);
    expect(ContainerJS.utils.Deferred.unpack(d3)).toEqual([
      {"pair_id": 0, "name": "USDJPY"},
      {"pair_id": 1, "name": "EURJPY"}
    ]);
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

    expect(pairs.pairs).toEqual([
      {"pair_id": 0, "name": "USDJPY"},
      {"pair_id": 1, "name": "EURJPY"}
    ]);

  });
});
