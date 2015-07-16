import ContainerJS      from "container-js"
import ContainerFactory from "../../../utils/test-container-factory"

describe("LogViewerModel", () => {

  var model;
  var xhrManager;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("viewModelFactory");
    const factory = ContainerJS.utils.Deferred.unpack(d);
    model = factory.createLogViewerModel();
    model.initialize("rmt");
    xhrManager = model.logService.xhrManager;
  });

  describe("load", () => {

    it("loadで一覧を取得できる", () => {

      model.load();
      xhrManager.requests[0].resolve({
        count: 3
      });
      xhrManager.requests[1].resolve({
        body : "test3",
        timestamp: new Date(100),
        size: 4
      });

      expect(xhrManager.requests[1].url).toEqual(
        "/api/logs/rmt?offset=2&direction=asc");
      expect(model.sortOrder).toEqual({direction: "asc"});
      expect(model.items[0].body).toEqual( "test3" );
      expect(model.hasNext).toEqual( false );
      expect(model.hasPrev).toEqual( true );
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([2, 1, 0]);
    });

    it("データ数0の場合、ロードは行われない。", () => {

      model.load();
      xhrManager.requests[0].resolve({
        count: 0
      });
      expect(model.sortOrder).toEqual({direction: "asc"});
      expect(model.items).toEqual( [] );
      expect(model.hasNext).toEqual( false );
      expect(model.hasPrev).toEqual( false );
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([]);
    });

    it("データ数が1の場合、ロードが行われる", () => {

      model.load();
      xhrManager.requests[0].resolve({
        count: 1
      });
      xhrManager.requests[1].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });

      expect(xhrManager.requests[1].url).toEqual(
        "/api/logs/rmt?offset=0&direction=asc");
      expect(model.sortOrder).toEqual({direction: "asc"});
      expect(model.items[0].body).toEqual( "test1" );
      expect(model.hasNext).toEqual( false );
      expect(model.hasPrev).toEqual( false );
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([0]);
    });
  });

  it("next/prevで次/前の一覧を取得できる", () => {

    model.load();
    xhrManager.requests[0].resolve({
      count: 3
    });
    xhrManager.requests[1].resolve({
      body : "test3",
      timestamp: new Date(300),
      size: 4
    });

    model.prev();
    xhrManager.requests[2].resolve({
      body : "test2",
      timestamp: new Date(200),
      size: 5
    });

    expect(xhrManager.requests[2].url).toEqual(
      "/api/logs/rmt?offset=1&direction=asc");
    expect(model.sortOrder).toEqual({direction: "asc"});
    expect(model.items[0].body).toEqual( "test2" );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );
    expect(model.pageSelectors.map((s)=>s.label)).toEqual([2, 1, 0]);

    model.prev();
    xhrManager.requests[3].resolve({
      body : "test",
      timestamp: new Date(100),
      size: 4
    });

    expect(xhrManager.requests[3].url).toEqual(
      "/api/logs/rmt?offset=0&direction=asc");
    expect(model.sortOrder).toEqual({direction: "asc"});
    expect(model.items[0].body).toEqual( "test" );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( false );
    expect(model.pageSelectors.map((s)=>s.label)).toEqual([2, 1, 0]);

    model.next();
    xhrManager.requests[4].resolve({
      body : "test2",
      timestamp: new Date(200),
      size: 5
    });

    expect(xhrManager.requests[4].url).toEqual(
      "/api/logs/rmt?offset=1&direction=asc");
    expect(model.sortOrder).toEqual({direction: "asc"});
    expect(model.items[0].body).toEqual( "test2" );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );
    expect(model.pageSelectors.map((s)=>s.label)).toEqual([2, 1, 0]);

    model.next();
    xhrManager.requests[5].resolve({
      body : "test3",
      timestamp: new Date(100),
      size: 5
    });

    expect(xhrManager.requests[5].url).toEqual(
      "/api/logs/rmt?offset=2&direction=asc");
    expect(model.sortOrder).toEqual({direction: "asc"});
    expect(model.items[0].body).toEqual( "test3" );
    expect(model.hasNext).toEqual( false );
    expect(model.hasPrev).toEqual( true );
    expect(model.pageSelectors.map((s)=>s.label)).toEqual([2, 1, 0]);

  });

  it("goToで任意のページに移動できる", () => {

    model.load();
    xhrManager.requests[0].resolve({
      count: 3
    });
    xhrManager.requests[1].resolve({
      body : "test3",
      timestamp: new Date(300),
      size: 4
    });

    model.goTo(1);
    xhrManager.requests[2].resolve({
      body : "test2",
      timestamp: new Date(300),
      size: 4
    });
    expect(xhrManager.requests[2].url).toEqual(
      "/api/logs/rmt?offset=1&direction=asc");
    expect(model.sortOrder).toEqual({direction: "asc"});
    expect(model.items[0].body).toEqual( "test2" );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );
    expect(model.pageSelectors.map((s)=>s.label)).toEqual([2, 1, 0]);

    model.goTo(-1);
    xhrManager.requests[3].resolve({
      body : "test",
      timestamp: new Date(300),
      size: 4
    });
    expect(xhrManager.requests[3].url).toEqual(
      "/api/logs/rmt?offset=0&direction=asc");
    expect(model.sortOrder).toEqual({direction: "asc"});
    expect(model.items[0].body).toEqual( "test" );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( false );
    expect(model.pageSelectors.map((s)=>s.label)).toEqual([2, 1, 0]);

    model.goTo(2);
    xhrManager.requests[4].resolve({
      body : "test3",
      timestamp: new Date(300),
      size: 4
    });
    expect(xhrManager.requests[4].url).toEqual(
      "/api/logs/rmt?offset=2&direction=asc");
    expect(model.sortOrder).toEqual({direction: "asc"});
    expect(model.items[0].body).toEqual( "test3" );
    expect(model.hasNext).toEqual( false );
    expect(model.hasPrev).toEqual( true );
    expect(model.pageSelectors.map((s)=>s.label)).toEqual([2, 1, 0]);

    model.goTo(3);
    xhrManager.requests[5].resolve({
      body : "test3",
      timestamp: new Date(300),
      size: 4
    });
    expect(xhrManager.requests[5].url).toEqual(
      "/api/logs/rmt?offset=2&direction=asc");
    expect(model.sortOrder).toEqual({direction: "asc"});
    expect(model.items[0].body).toEqual( "test3" );
    expect(model.hasNext).toEqual( false );
    expect(model.hasPrev).toEqual( true );
    expect(model.pageSelectors.map((s)=>s.label)).toEqual([2, 1, 0]);
  });

  describe("pageSelectors", () => {

    it("要素数0の場合", () => {
      model.load();
      xhrManager.requests[0].resolve({
        count: 0
      });
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([]);
    });
    it("要素数1の場合", () => {
      model.load();
      xhrManager.requests[0].resolve({
        count: 1
      });
      xhrManager.requests[1].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([0]);
    });
    it("要素数2の場合", () => {
      model.load();
      xhrManager.requests[0].resolve({
        count: 2
      });
      xhrManager.requests[1].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([1, 0]);

      model.goTo(0);
      xhrManager.requests[2].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([1, 0]);
    });

    it("要素数3の場合", () => {
      model.load();
      xhrManager.requests[0].resolve({
        count: 3
      });
      xhrManager.requests[1].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([2, 1, 0]);

      model.goTo(1);
      xhrManager.requests[2].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([2, 1, 0]);

      model.goTo(0);
      xhrManager.requests[3].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([2, 1, 0]);
    });

    it("要素数4の場合", () => {
      model.load();
      xhrManager.requests[0].resolve({
        count: 4
      });
      xhrManager.requests[1].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([3, 2, "...", 0]);

      model.goTo(2);
      xhrManager.requests[2].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([3, 2, 1, 0]);

      model.goTo(1);
      xhrManager.requests[3].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([3, 2, 1, 0]);

      model.goTo(0);
      xhrManager.requests[4].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([3, "...", 1, 0]);
    });

    it("要素数5の場合", () => {
      model.load();
      xhrManager.requests[0].resolve({
        count: 5
      });
      xhrManager.requests[1].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([4, 3, "...", 0]);

      model.goTo(3);
      xhrManager.requests[2].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([4, 3, 2, "...", 0]);

      model.goTo(2);
      xhrManager.requests[3].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([4, 3, 2, 1, 0]);

      model.goTo(1);
      xhrManager.requests[4].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([4, "...", 2, 1, 0]);

      model.goTo(0);
      xhrManager.requests[5].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([4, "...", 1, 0]);
    });

    it("要素数6の場合", () => {
      model.load();
      xhrManager.requests[0].resolve({
        count: 6
      });
      xhrManager.requests[1].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([5, 4, "...", 0]);

      model.goTo(4);
      xhrManager.requests[2].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([5, 4, 3, "...", 0]);

      model.goTo(3);
      xhrManager.requests[3].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([5, 4, 3, 2, "...", 0]);

      model.goTo(2);
      xhrManager.requests[4].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([5, "...", 3, 2, 1, 0]);

      model.goTo(1);
      xhrManager.requests[5].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([5, "...", 2, 1, 0]);

      model.goTo(0);
      xhrManager.requests[6].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([5, "...", 1, 0]);
    });

    it("要素数7の場合", () => {
      model.load();
      xhrManager.requests[0].resolve({
        count: 7
      });
      xhrManager.requests[1].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([6, 5, "...", 0]);

      model.goTo(3);
      xhrManager.requests[2].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([6, "...", 4, 3, 2, "...", 0]);

      model.goTo(0);
      xhrManager.requests[3].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(model.pageSelectors.map((s)=>s.label)).toEqual([6, "...", 1, 0]);
    });

    it("セレクターで指定ページに移動できる", () => {
      model.load();
      xhrManager.requests[0].resolve({
        count: 4
      });
      xhrManager.requests[1].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });

      model.pageSelectors[3].action();
      xhrManager.requests[2].resolve({
        body : "test2",
        timestamp: new Date(100),
        size: 4
      });
      expect(xhrManager.requests[2].url).toEqual(
        "/api/logs/rmt?offset=0&direction=asc");
      expect(model.sortOrder).toEqual({direction: "asc"});
      expect(model.items[0].body).toEqual( "test2" );
      expect(model.hasNext).toEqual( true );
      expect(model.hasPrev).toEqual( false );
    });
  });

});
