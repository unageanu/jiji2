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
  });

});
