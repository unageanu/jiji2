import ContainerJS      from "container-js"
import ContainerFactory from "../../../utils/test-container-factory"
import Deferred         from "src/utils/deferred"

describe("Icons", () => {

  var model;
  var xhrManager;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("icons");
    model = Deferred.unpack(d);
    xhrManager = model.iconService.xhrManager;
  });

  it("初期値", () => {
    expect(model.icons).toBe(null);
  });

  it("initializeで一覧をロードできる", () => {

    model.initialize();
    xhrManager.requests[0].resolve([
      {"id": 0 },
      {"id": 1 },
      {"id": 2 }
    ]);

    expect(model.icons).toEqual([
      {"id": 0 },
      {"id": 1 },
      {"id": 2 }
    ]);

  });

  it("initializeの結果はキャッシュされる。", () => {
    const d1 = model.initialize();
    const d2 = model.initialize();
    xhrManager.requests[0].resolve([
      {"id": 0 },
      {"id": 1 },
      {"id": 2 }
    ]);

    expect(Deferred.unpack(d1)).toEqual([
      {"id": 0 },
      {"id": 1 },
      {"id": 2 }
    ]);
    expect(Deferred.unpack(d2)).toEqual([
      {"id": 0 },
      {"id": 1 },
      {"id": 2 }
    ]);

    const d3 = model.initialize();
    expect(Deferred.unpack(d3)).toEqual([
      {"id": 0 },
      {"id": 1 },
      {"id": 2 }
    ]);
  });

  it("initializeでエラーとなった場合、結果はキャッシュされない。", () => {
    const d1 = model.initialize();
    const d2 = model.initialize();
    xhrManager.requests[0].reject({});

    expect(() => {
      Deferred.unpack(d1);
    }).toThrowError();
    expect(() => {
      Deferred.unpack(d2);
    }).toThrowError();

    const d3 = model.initialize();
    xhrManager.requests[1].resolve([
      {"id": 0 },
      {"id": 1 },
      {"id": 2 }
    ]);
    expect(Deferred.unpack(d3)).toEqual([
      {"id": 0 },
      {"id": 1 },
      {"id": 2 }
    ]);
  });

  it("reloadで通貨ペアの一覧を再ロードできる", () => {

    model.initialize();
    xhrManager.requests[0].resolve([
      {"id": 0 },
      {"id": 1 },
      {"id": 2 }
    ]);

    model.reload();
    xhrManager.requests[1].resolve([
      {"id": 0 },
      {"id": 1 }
    ]);

    expect(model.icons).toEqual([
      {"id": 0 },
      {"id": 1 }
    ]);

  });
});
