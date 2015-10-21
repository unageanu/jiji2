import ContainerJS      from "container-js"
import ContainerFactory from "../../../utils/test-container-factory"

describe("PairSettingModel", () => {

  var model;
  var xhrManager;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("viewModelFactory");
    const factory = ContainerJS.utils.Deferred.unpack(d);
    model = factory.createPairSettingModel();
    xhrManager = model.pairSettingService.xhrManager;
    factory.timeSource.now = new Date(2015, 9, 10, 12, 4, 23);
  });

  describe("initialize", () => {
    it("必要な情報を取得できる", () => {
      model.initialize();
      xhrManager.requests[0].resolve([
        {"pair_id": 0, "name": "USDJPY"},
        {"pair_id": 1, "name": "EURJPY"}
      ]);
      xhrManager.requests[1].resolve([
        {"pair_id": 0, "name": "USDJPY"},
        {"pair_id": 1, "name": "EURJPY"},
        {"pair_id": 2, "name": "EURUSD"}
      ]);

      expect(model.pairNames).toEqual([
        "USDJPY", "EURJPY"
      ]);
      expect(model.availablePairs).toEqual([
        {"pair_id": 0, "name": "USDJPY"},
        {"pair_id": 1, "name": "EURJPY"},
        {"pair_id": 2, "name": "EURUSD"}
      ]);
      expect(model.pairNamesError).toEqual(null);
      expect(model.message).toEqual(null);
      expect(model.isSaving).toEqual(false);
    });
  });

  describe("#save", () => {
    it("Saveで設定を永続化できる", () => {
      model.initialize();
      xhrManager.requests[0].resolve([
        {"pair_id": 0, "name": "USDJPY"},
        {"pair_id": 1, "name": "EURJPY"}
      ]);
      xhrManager.requests[1].resolve([
        {"pair_id": 0, "name": "USDJPY"},
        {"pair_id": 1, "name": "EURJPY"},
        {"pair_id": 2, "name": "EURUSD"}
      ]);

      model.pairNames = ["USDJPY"];
      model.save();
      expect(model.isSaving).toEqual(true);
      xhrManager.requests[2].resolve({});

      expect(model.pairNames).toEqual(["USDJPY"]);
      expect(model.availablePairs).toEqual([
        {"pair_id": 0, "name": "USDJPY"},
        {"pair_id": 1, "name": "EURJPY"},
        {"pair_id": 2, "name": "EURUSD"}
      ]);
      expect(model.pairNamesError).toEqual(null);
      expect(model.message).toEqual("設定を変更しました。 (2015-10-10 12:04:23)");
      expect(model.isSaving).toEqual(false);
    });
    it("入力値が不正な場合、エラーが表示される", () => {
      model.initialize();
      xhrManager.requests[0].resolve([
        {"pair_id": 0, "name": "USDJPY"},
        {"pair_id": 1, "name": "EURJPY"}
      ]);
      xhrManager.requests[1].resolve([
        {"pair_id": 0, "name": "USDJPY"},
        {"pair_id": 1, "name": "EURJPY"},
        {"pair_id": 2, "name": "EURUSD"}
      ]);

      model.pairNames = [];
      model.save();

      expect(model.pairNames).toEqual([]);
      expect(model.availablePairs).toEqual([
        {"pair_id": 0, "name": "USDJPY"},
        {"pair_id": 1, "name": "EURJPY"},
        {"pair_id": 2, "name": "EURUSD"}
      ]);
      expect(model.pairNamesError).toEqual("通貨ペアが設定されていません");
      expect(model.message).toEqual(null);
      expect(model.isSaving).toEqual(false);
    });
    it("通信エラーの場合、エラーが表示される", () => {
      model.initialize();
      xhrManager.requests[0].resolve([
        {"pair_id": 0, "name": "USDJPY"},
        {"pair_id": 1, "name": "EURJPY"}
      ]);
      xhrManager.requests[1].resolve([
        {"pair_id": 0, "name": "USDJPY"},
        {"pair_id": 1, "name": "EURJPY"},
        {"pair_id": 2, "name": "EURUSD"}
      ]);

      model.pairNames = ["USDJPY"];
      model.save();
      expect(model.isSaving).toEqual(true);
      xhrManager.requests[2].reject({
        statusCode: 500
      });

      expect(model.pairNames).toEqual(["USDJPY"]);
      expect(model.availablePairs).toEqual([
        {"pair_id": 0, "name": "USDJPY"},
        {"pair_id": 1, "name": "EURJPY"},
        {"pair_id": 2, "name": "EURUSD"}
      ]);
      expect(model.pairNamesError).toEqual(
        "サーバーが混雑しています。しばらく待ってからやり直してください");
      expect(model.message).toEqual(null);
      expect(model.isSaving).toEqual(false);
    });
  });
});
