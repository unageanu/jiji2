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
        {id: "aa", name:"aaa" },
        {id: "bb", name:"bbb" }
      ]);
      xhrManager.requests[1].resolve(
        {securitiesId: null }
      );
      xhrManager.requests[2].resolve([
        { id: "config1", description: "config1" },
        { id: "config2", description: "config2" }
      ]);
      xhrManager.requests[3].resolve({});

      expect(model.availableSecurities).toEqual([
        {id: "aa", name:"aaa" },
        {id: "bb", name:"bbb" }
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
        {id: "aa", name:"aaa" },
        {id: "bb", name:"bbb" }
      ]);
      xhrManager.requests[1].resolve(
        {securitiesId: "bb" }
      );
      xhrManager.requests[2].resolve([
        { id: "config1", description: "config1" },
        { id: "config2", description: "config2" }
      ]);
      xhrManager.requests[3].resolve({
        config1: "xxx"
      });

      expect(model.availableSecurities).toEqual([
        {id: "aa", name:"aaa" },
        {id: "bb", name:"bbb" }
      ]);
      expect(model.activeSecuritiesId).toEqual("bb");
      expect(model.activeSecuritiesConfiguration).toEqual([
        { id: "config1", description: "config1", value: "xxx" },
        { id: "config2", description: "config2", value: null }
      ]);
    });
  });

  it("選択されている証券会社を変更できる", () => {
    model.initialize();
    xhrManager.requests[0].resolve([
      {id: "aa", name:"aaa" },
      {id: "bb", name:"bbb" }
    ]);
    xhrManager.requests[1].resolve(
      {securitiesId: null }
    );
    xhrManager.requests[2].resolve([]);
    xhrManager.requests[3].resolve({});

    expect(model.availableSecurities).toEqual([
      {id: "aa", name:"aaa" },
      {id: "bb", name:"bbb" }
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
      {id: "aa", name:"aaa" },
      {id: "bb", name:"bbb" }
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
      {id: "aa", name:"aaa" },
      {id: "bb", name:"bbb" }
    ]);
    expect(model.activeSecuritiesId).toEqual("aa");
    expect(model.activeSecuritiesConfiguration).toEqual([
      { id: "config1", description: "config1", value: "xxx" }
    ]);
  });

  it("Saveで設定を永続化できる", () => {
    model.initialize();
    xhrManager.requests[0].resolve([
      {id: "aa", name:"aaa" },
      {id: "bb", name:"bbb" }
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
    expect(xhrManager.requests[6].body).toEqual({
      "securities_id": "bb",
      configurations: {config1: "yyy"}
    });
  });

});
