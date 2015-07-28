import ContainerJS      from "container-js"
import ContainerFactory from "../../../utils/test-container-factory"

describe("SecuritiesSettingModel", () => {

  var model;
  var xhrManager;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("viewModelFactory");
    const factory = ContainerJS.utils.Deferred.unpack(d);
    model = factory.createSecuritiesSettingModel();
    xhrManager = model.securitiesSettingService.xhrManager;
  });

  describe("initialize", () => {
    it("選択されている証券会社がない場合、先頭が選択された状態になる", () => {
      model.initialize();
      xhrManager.requests[0].resolve([
        { securitiesId: "aa", name:"aaa" },
        { securitiesId: "bb", name:"bbb" }
      ]);
      xhrManager.requests[1].reject({
        status: 404
      });
      xhrManager.requests[2].resolve([
        { id: "config1", description: "config1" },
        { id: "config2", description: "config2" }
      ]);
      xhrManager.requests[3].resolve({});

      expect(model.availableSecurities).toEqual([
        { securitiesId: "aa", name:"aaa", id: "aa", text:"aaa" },
        { securitiesId: "bb", name:"bbb", id: "bb", text:"bbb" }
      ]);
      expect(model.activeSecuritiesId).toEqual("aa");
      expect(model.activeSecuritiesConfiguration).toEqual([
        { id: "config1", description: "config1", value: null },
        { id: "config2", description: "config2", value: null }
      ]);
    });

    it("選択されている証券会社がある場合、それが選択された状態になる", () => {
      model.initialize();
      xhrManager.requests[0].resolve([
        { securitiesId: "aa", name:"aaa" },
        { securitiesId: "bb", name:"bbb" }
      ]);
      xhrManager.requests[1].resolve(
        {securitiesId: "bb" }
      );
      xhrManager.requests[2].resolve([
        { id: "config_a", description: "config1" },
        { id: "config_b", description: "config2" }
      ]);
      xhrManager.requests[3].resolve({
        configA: "xxx"
      });

      expect(model.availableSecurities).toEqual([
        { securitiesId: "aa", name:"aaa", id: "aa", text:"aaa" },
        { securitiesId: "bb", name:"bbb", id: "bb", text:"bbb" }
      ]);
      expect(model.activeSecuritiesId).toEqual("bb");
      expect(model.activeSecuritiesConfiguration).toEqual([
        { id: "config_a", description: "config1", value: "xxx" },
        { id: "config_b", description: "config2", value: null }
      ]);
    });


    it("再初期化できる", () => {
      model.initialize();
      xhrManager.requests[0].resolve([
        { securitiesId: "aa", name:"aaa" },
        { securitiesId: "bb", name:"bbb" }
      ]);
      xhrManager.requests[1].resolve(
        {securitiesId: "bb" }
      );
      xhrManager.requests[2].resolve([
        { id: "config_a", description: "config1" },
        { id: "config_b", description: "config2" }
      ]);
      xhrManager.requests[3].resolve({
        configA: "xxx"
      });


      model.initialize();
      expect(model.availableSecurities).toEqual([]);
      expect(model.activeSecuritiesId).toEqual(null);
      expect(model.activeSecuritiesConfiguration).toEqual([]);

      xhrManager.requests[4].resolve([
        { securitiesId: "aa", name:"aax" },
        { securitiesId: "bb", name:"bbx" }
      ]);
      xhrManager.requests[5].resolve(
        {securitiesId: "bb" }
      );
      xhrManager.requests[6].resolve([
        { id: "config_a", description: "config1" },
        { id: "config_b", description: "config2" }
      ]);
      xhrManager.requests[7].resolve({
        configA: "xxx"
      });

      expect(model.availableSecurities).toEqual([
        { securitiesId: "aa", name:"aax", id: "aa", text:"aax" },
        { securitiesId: "bb", name:"bbx", id: "bb", text:"bbx" }
      ]);
      expect(model.activeSecuritiesId).toEqual("bb");
      expect(model.activeSecuritiesConfiguration).toEqual([
        { id: "config_a", description: "config1", value: "xxx" },
        { id: "config_b", description: "config2", value: null }
      ]);
    });
  });

  it("選択されている証券会社を変更できる", () => {
    model.initialize();
    xhrManager.requests[0].resolve([
      { securitiesId: "aa", name:"aaa" },
      { securitiesId: "bb", name:"bbb" }
    ]);
    xhrManager.requests[1].resolve(
      {securitiesId: null }
    );
    xhrManager.requests[2].resolve([]);
    xhrManager.requests[3].resolve({});

    expect(model.availableSecurities).toEqual([
      { securitiesId: "aa", name:"aaa", id: "aa", text:"aaa" },
      { securitiesId: "bb", name:"bbb", id: "bb", text:"bbb" }
    ]);
    expect(model.activeSecuritiesId).toEqual("aa");
    expect(model.activeSecuritiesConfiguration).toEqual([]);


    model.activeSecuritiesId = "bb";
    xhrManager.requests[4].resolve([
      { id: "config1", description: "config1" },
      { id: "config2", description: "config2" }
    ]);
    xhrManager.requests[5].resolve({
      config1: "xxx"
    });

    expect(model.availableSecurities).toEqual([
      { securitiesId: "aa", name:"aaa", id: "aa", text:"aaa" },
      { securitiesId: "bb", name:"bbb", id: "bb", text:"bbb" }
    ]);
    expect(model.activeSecuritiesId).toEqual("bb");
    expect(model.activeSecuritiesConfiguration).toEqual([
      { id: "config1", description: "config1", value: "xxx" },
      { id: "config2", description: "config2", value: null }
    ]);


    model.activeSecuritiesId = "aa";
    xhrManager.requests[6].resolve([
      { id: "config1", description: "config1" }
    ]);
    xhrManager.requests[7].resolve({
      config1: "xxx"
    });

    expect(model.availableSecurities).toEqual([
      { securitiesId: "aa", name:"aaa", id: "aa", text:"aaa" },
      { securitiesId: "bb", name:"bbb", id: "bb", text:"bbb" }
    ]);
    expect(model.activeSecuritiesId).toEqual("aa");
    expect(model.activeSecuritiesConfiguration).toEqual([
      { id: "config1", description: "config1", value: "xxx" }
    ]);
  });

  describe("#save", () => {
    it("Saveで設定を永続化できる", () => {
      model.initialize();
      xhrManager.requests[0].resolve([
        { securitiesId: "aa", name:"aaa" },
        { securitiesId: "bb", name:"bbb" }
      ]);
      xhrManager.requests[1].resolve(
        {securitiesId: null }
      );
      xhrManager.requests[2].resolve([]);
      xhrManager.requests[3].resolve({});

      model.activeSecuritiesId = "bb";
      xhrManager.requests[4].resolve([
        { id: "config1", description: "config1" },
        { id: "config2", description: "config2" }
      ]);
      xhrManager.requests[5].resolve({
        config1: "xxx"
      });

      model.save({config1: "yyy"});
      xhrManager.requests[6].resolve({});
      expect(xhrManager.requests[6].body).toEqual({
        "securities_id": "bb",
        configurations: {config1: "yyy"}
      });
      expect(model.error).toEqual(null);
      expect(model.message).toEqual("証券会社の設定を変更しました");
    });
    it("設定でエラーになった場合、メッセージが表示される", () => {
      model.initialize();
      xhrManager.requests[0].resolve([
        { securitiesId: "aa", name:"aaa" },
        { securitiesId: "bb", name:"bbb" }
      ]);
      xhrManager.requests[1].resolve(
        {securitiesId: null }
      );
      xhrManager.requests[2].resolve([]);
      xhrManager.requests[3].resolve({});

      model.activeSecuritiesId = "bb";
      xhrManager.requests[4].resolve([
        { id: "config1", description: "config1" },
        { id: "config2", description: "config2" }
      ]);
      xhrManager.requests[5].resolve({
        config1: "xxx"
      });

      model.save({config1: "yyy"});
      xhrManager.requests[6].reject({
        status: 400
      });
      expect(model.error).toEqual(
        "証券会社に接続できませんでした。<br/>アクセストークンを確認してください。");
      expect(model.message).toEqual(null);

      model.save({config1: "yyy2"});
      xhrManager.requests[7].reject({
        status: 500
      });
      expect(model.error).toEqual(
        "サーバーが混雑しています。しばらく待ってからやり直してください");
      expect(model.message).toEqual(null);
    });
  });
});
