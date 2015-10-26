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
        "/api/logs/rmt?offset=2");
      expect(model.sortOrder).toEqual({});
      expect(model.items[0].body).toEqual( "test3" );
      expect(model.hasNext).toEqual( false );
      expect(model.hasPrev).toEqual( true );
      expect(pageSelectorLabelOf(model)).toEqual([2, 1, 0]);
      expect(selectedPageIndexOf(model)).toEqual(2);
    });

    it("データ数0の場合、ロードは行われない。", () => {

      model.load();
      xhrManager.requests[0].resolve({
        count: 0
      });
      expect(model.sortOrder).toEqual({});
      expect(model.items).toEqual( [] );
      expect(model.hasNext).toEqual( false );
      expect(model.hasPrev).toEqual( false );
      expect(pageSelectorLabelOf(model)).toEqual([]);
      expect(selectedPageIndexOf(model)).toEqual(-1);
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
        "/api/logs/rmt?offset=0");
      expect(model.sortOrder).toEqual({});
      expect(model.items[0].body).toEqual( "test1" );
      expect(model.hasNext).toEqual( false );
      expect(model.hasPrev).toEqual( false );
      expect(pageSelectorLabelOf(model)).toEqual([0]);
      expect(selectedPageIndexOf(model)).toEqual(0);
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
      "/api/logs/rmt?offset=1");
    expect(model.sortOrder).toEqual({});
    expect(model.items[0].body).toEqual( "test2" );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );
    expect(pageSelectorLabelOf(model)).toEqual([2, 1, 0]);
    expect(selectedPageIndexOf(model)).toEqual(1);

    model.prev();
    xhrManager.requests[3].resolve({
      body : "test",
      timestamp: new Date(100),
      size: 4
    });

    expect(xhrManager.requests[3].url).toEqual(
      "/api/logs/rmt?offset=0");
    expect(model.sortOrder).toEqual({});
    expect(model.items[0].body).toEqual( "test" );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( false );
    expect(pageSelectorLabelOf(model)).toEqual([2, 1, 0]);
    expect(selectedPageIndexOf(model)).toEqual(0);

    model.next();
    xhrManager.requests[4].resolve({
      body : "test2",
      timestamp: new Date(200),
      size: 5
    });

    expect(xhrManager.requests[4].url).toEqual(
      "/api/logs/rmt?offset=1");
    expect(model.sortOrder).toEqual({});
    expect(model.items[0].body).toEqual( "test2" );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );
    expect(pageSelectorLabelOf(model)).toEqual([2, 1, 0]);
    expect(selectedPageIndexOf(model)).toEqual(1);

    model.next();
    xhrManager.requests[5].resolve({
      body : "test3",
      timestamp: new Date(100),
      size: 5
    });

    expect(xhrManager.requests[5].url).toEqual(
      "/api/logs/rmt?offset=2");
    expect(model.sortOrder).toEqual({});
    expect(model.items[0].body).toEqual( "test3" );
    expect(model.hasNext).toEqual( false );
    expect(model.hasPrev).toEqual( true );
    expect(pageSelectorLabelOf(model)).toEqual([2, 1, 0]);
    expect(selectedPageIndexOf(model)).toEqual(2);

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
      "/api/logs/rmt?offset=1");
    expect(model.sortOrder).toEqual({});
    expect(model.items[0].body).toEqual( "test2" );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );
    expect(pageSelectorLabelOf(model)).toEqual([2, 1, 0]);
    expect(selectedPageIndexOf(model)).toEqual(1);

    model.goTo(-1);
    xhrManager.requests[3].resolve({
      body : "test",
      timestamp: new Date(300),
      size: 4
    });
    expect(xhrManager.requests[3].url).toEqual(
      "/api/logs/rmt?offset=0");
    expect(model.sortOrder).toEqual({});
    expect(model.items[0].body).toEqual( "test" );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( false );
    expect(pageSelectorLabelOf(model)).toEqual([2, 1, 0]);
    expect(selectedPageIndexOf(model)).toEqual(0);

    model.goTo(2);
    xhrManager.requests[4].resolve({
      body : "test3",
      timestamp: new Date(300),
      size: 4
    });
    expect(xhrManager.requests[4].url).toEqual(
      "/api/logs/rmt?offset=2");
    expect(model.sortOrder).toEqual({});
    expect(model.items[0].body).toEqual( "test3" );
    expect(model.hasNext).toEqual( false );
    expect(model.hasPrev).toEqual( true );
    expect(pageSelectorLabelOf(model)).toEqual([2, 1, 0]);
    expect(selectedPageIndexOf(model)).toEqual(2);

    model.goTo(3);
    xhrManager.requests[5].resolve({
      body : "test3",
      timestamp: new Date(300),
      size: 4
    });
    expect(xhrManager.requests[5].url).toEqual(
      "/api/logs/rmt?offset=2");
    expect(model.sortOrder).toEqual({});
    expect(model.items[0].body).toEqual( "test3" );
    expect(model.hasNext).toEqual( false );
    expect(model.hasPrev).toEqual( true );
    expect(pageSelectorLabelOf(model)).toEqual([2, 1, 0]);
    expect(selectedPageIndexOf(model)).toEqual(2);
  });

  describe("pageSelectors", () => {

    it("要素数0の場合", () => {
      model.load();
      xhrManager.requests[0].resolve({
        count: 0
      });
      expect(pageSelectorLabelOf(model)).toEqual([]);
      expect(selectedPageIndexOf(model)).toEqual(-1);
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
      expect(pageSelectorLabelOf(model)).toEqual([0]);
      expect(selectedPageIndexOf(model)).toEqual(0);
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
      expect(pageSelectorLabelOf(model)).toEqual([1, 0]);
      expect(selectedPageIndexOf(model)).toEqual(1);

      model.goTo(0);
      xhrManager.requests[2].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(pageSelectorLabelOf(model)).toEqual([1, 0]);
      expect(selectedPageIndexOf(model)).toEqual(0);
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
      expect(pageSelectorLabelOf(model)).toEqual([2, 1, 0]);
      expect(selectedPageIndexOf(model)).toEqual(2);

      model.goTo(1);
      xhrManager.requests[2].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(pageSelectorLabelOf(model)).toEqual([2, 1, 0]);
      expect(selectedPageIndexOf(model)).toEqual(1);

      model.goTo(0);
      xhrManager.requests[3].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(pageSelectorLabelOf(model)).toEqual([2, 1, 0]);
      expect(selectedPageIndexOf(model)).toEqual(0);
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
      expect(pageSelectorLabelOf(model)).toEqual([3, 2, "...", 0]);
      expect(selectedPageIndexOf(model)).toEqual(3);

      model.goTo(2);
      xhrManager.requests[2].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(pageSelectorLabelOf(model)).toEqual([3, 2, 1, 0]);
      expect(selectedPageIndexOf(model)).toEqual(2);

      model.goTo(1);
      xhrManager.requests[3].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(pageSelectorLabelOf(model)).toEqual([3, 2, 1, 0]);
      expect(selectedPageIndexOf(model)).toEqual(1);

      model.goTo(0);
      xhrManager.requests[4].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(pageSelectorLabelOf(model)).toEqual([3, "...", 1, 0]);
      expect(selectedPageIndexOf(model)).toEqual(0);
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
      expect(pageSelectorLabelOf(model)).toEqual([4, 3, "...", 0]);
      expect(selectedPageIndexOf(model)).toEqual(4);

      model.goTo(3);
      xhrManager.requests[2].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(pageSelectorLabelOf(model)).toEqual([4, 3, 2, "...", 0]);
      expect(selectedPageIndexOf(model)).toEqual(3);

      model.goTo(2);
      xhrManager.requests[3].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(pageSelectorLabelOf(model)).toEqual([4, 3, 2, 1, 0]);
      expect(selectedPageIndexOf(model)).toEqual(2);

      model.goTo(1);
      xhrManager.requests[4].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(pageSelectorLabelOf(model)).toEqual([4, "...", 2, 1, 0]);
      expect(selectedPageIndexOf(model)).toEqual(1);

      model.goTo(0);
      xhrManager.requests[5].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(pageSelectorLabelOf(model)).toEqual([4, "...", 1, 0]);
      expect(selectedPageIndexOf(model)).toEqual(0);
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
      expect(pageSelectorLabelOf(model)).toEqual([5, 4, "...", 0]);
      expect(selectedPageIndexOf(model)).toEqual(5);

      model.goTo(4);
      xhrManager.requests[2].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(pageSelectorLabelOf(model)).toEqual([5, 4, 3, "...", 0]);
      expect(selectedPageIndexOf(model)).toEqual(4);

      model.goTo(3);
      xhrManager.requests[3].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(pageSelectorLabelOf(model)).toEqual([5, 4, 3, 2, "...", 0]);
      expect(selectedPageIndexOf(model)).toEqual(3);

      model.goTo(2);
      xhrManager.requests[4].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(pageSelectorLabelOf(model)).toEqual([5, "...", 3, 2, 1, 0]);
      expect(selectedPageIndexOf(model)).toEqual(2);

      model.goTo(1);
      xhrManager.requests[5].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(pageSelectorLabelOf(model)).toEqual([5, "...", 2, 1, 0]);
      expect(selectedPageIndexOf(model)).toEqual(1);

      model.goTo(0);
      xhrManager.requests[6].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(pageSelectorLabelOf(model)).toEqual([5, "...", 1, 0]);
      expect(selectedPageIndexOf(model)).toEqual(0);
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
      expect(pageSelectorLabelOf(model)).toEqual([6, 5, "...", 0]);
      expect(selectedPageIndexOf(model)).toEqual(6);

      model.goTo(3);
      xhrManager.requests[2].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(pageSelectorLabelOf(model)).toEqual([6, "...", 4, 3, 2, "...", 0]);
      expect(selectedPageIndexOf(model)).toEqual(3);

      model.goTo(0);
      xhrManager.requests[3].resolve({
        body : "test1",
        timestamp: new Date(100),
        size: 4
      });
      expect(pageSelectorLabelOf(model)).toEqual([6, "...", 1, 0]);
      expect(selectedPageIndexOf(model)).toEqual(0);
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
        "/api/logs/rmt?offset=0");
      expect(model.sortOrder).toEqual({});
      expect(model.items[0].body).toEqual( "test2" );
      expect(model.hasNext).toEqual( true );
      expect(model.hasPrev).toEqual( false );
    });
  });

  function pageSelectorLabelOf(taret) {
    return taret.pageSelectors.map((s) => s.label);
  }
  function selectedPageIndexOf(taret) {
    var no = -1;
    taret.pageSelectors.forEach((page) => {
      if (!page.selected) return;
      if (no !== -1) throw "fail.";
      no = page.label;
    });
    return no;
  }

});
