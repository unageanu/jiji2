import ContainerJS      from "container-js"
import ContainerFactory from "../../../utils/test-container-factory"

describe("NotificationsTableModel", () => {

  var model;
  var xhrManager;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("viewModelFactory");
    const factory = ContainerJS.utils.Deferred.unpack(d);
    model = factory.createNotificationsTableModel(20);
    model.initialize("rmt");
    xhrManager = model.notificationService.xhrManager;
  });

  describe("load", () => {

    it("loadで一覧を取得できる", () => {

      model.load();
      xhrManager.requests[0].resolve({
        count: 50
      });
      xhrManager.requests[1].resolve(createItems(20));

      expect(xhrManager.requests[1].url).toEqual(
        "/api/notifications/rmt?offset=0&limit=20&order=timestamp&direction=desc");
      expect(model.sortOrder).toEqual({order:"timestamp", direction: "desc"});
      expect(model.items[0].timestamp).toEqual( new Date(0) );
      expect(model.items[0].formatedTimestamp).not.toBe( null );
      expect(model.hasNext).toEqual( true );
      expect(model.hasPrev).toEqual( false );
      expect(model.selectedNotification).toBe( null );
    });

    it("データ数0の場合、ロードは行われない。", () => {

      model.load();
      xhrManager.requests[0].resolve({
        count: 0
      });
      expect(model.sortOrder).toEqual({order:"timestamp", direction: "desc"});
      expect(model.items).toEqual( [] );
      expect(model.hasNext).toEqual( false );
      expect(model.hasPrev).toEqual( false );
      expect(model.selectedNotification).toBe( null );
    });

  });

  describe("選択", () => {
    it("通知を選択できる", () => {
      model.load();
      xhrManager.requests[0].resolve({
        count: 50
      });
      xhrManager.requests[1].resolve(createItems(20));

      model.selectedNotification = model.items[0];
      expect(model.selectedNotification).toBe( model.items[0] );
    });
    it("次へ/前へを押してページを切り替えると、選択が解除される", () => {
      model.load();
      xhrManager.requests[0].resolve({
        count: 50
      });
      xhrManager.requests[1].resolve(createItems(20));

      model.selectedNotification = model.items[0];
      model.next();
      xhrManager.requests[2].resolve(createItems(20));
      expect(model.selectedNotification).toBe( null );

      model.selectedNotification = model.items[0];
      model.prev();
      xhrManager.requests[3].resolve(createItems(20));
      expect(model.selectedNotification).toBe( null );
    });
    it("ソート順を変更すると、選択が解除される", () => {
      model.load();
      xhrManager.requests[0].resolve({
        count: 50
      });
      xhrManager.requests[1].resolve(createItems(20));

      model.selectedNotification = model.items[0];
      model.sortBy({order:"timestamp", direction: "asc"});
      xhrManager.requests[2].resolve(createItems(20));
      expect(model.selectedNotification).toBe( null );
    });
    it("一覧を再読み込みすると、選択が解除される", () => {
      model.load();
      xhrManager.requests[0].resolve({
        count: 50
      });
      xhrManager.requests[1].resolve(createItems(20));

      model.selectedNotification = model.items[0];
      model.load();
      xhrManager.requests[2].resolve({
        count: 50
      });
      xhrManager.requests[3].resolve(createItems(20));
      expect(model.selectedNotification).toBe( null );
    });
  });

  it("next/prevで次/前の一覧を取得できる", () => {

    model.load();
    xhrManager.requests[0].resolve({
      count: 60
    });
    xhrManager.requests[1].resolve(createItems(20));

    model.next();
    xhrManager.requests[2].resolve(createItems(20));

    expect(xhrManager.requests[2].url).toEqual(
      "/api/notifications/rmt?offset=20&limit=20&order=timestamp&direction=desc");
    expect(model.sortOrder).toEqual({order:"timestamp", direction: "desc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );
    expect(model.selectedNotification).toBe( null );


    model.next();
    xhrManager.requests[3].resolve(createItems(20));

    expect(xhrManager.requests[3].url).toEqual(
      "/api/notifications/rmt?offset=40&limit=20&order=timestamp&direction=desc");
    expect(model.sortOrder).toEqual({order:"timestamp", direction: "desc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( false );
    expect(model.hasPrev).toEqual( true );
    expect(model.selectedNotification).toBe( null );


    model.prev();
    xhrManager.requests[4].resolve(createItems(20));

    expect(xhrManager.requests[4].url).toEqual(
      "/api/notifications/rmt?offset=20&limit=20&order=timestamp&direction=desc");
    expect(model.sortOrder).toEqual({order:"timestamp", direction: "desc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );
    expect(model.selectedNotification).toBe( null );


    model.prev();
    xhrManager.requests[5].resolve(createItems(20));

    expect(xhrManager.requests[5].url).toEqual(
      "/api/notifications/rmt?offset=0&limit=20&order=timestamp&direction=desc");
    expect(model.sortOrder).toEqual({order:"timestamp", direction: "desc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( false );
    expect(model.selectedNotification).toBe( null );

  });

  it("sortByでソート順を変更できる", () => {
    model.load();
    xhrManager.requests[0].resolve({
      count: 60
    });
    xhrManager.requests[1].resolve(createItems(20));

    model.sortBy({order:"timestamp", direction: "asc"});
    xhrManager.requests[2].resolve(createItems(20));

    expect(xhrManager.requests[2].url).toEqual(
      "/api/notifications/rmt?offset=0&limit=20&order=timestamp&direction=asc");
    expect(model.sortOrder).toEqual({order:"timestamp", direction: "asc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( false );
    expect(model.selectedNotification).toBe( null );

    model.next();
    xhrManager.requests[3].resolve(createItems(20));

    expect(xhrManager.requests[3].url).toEqual(
      "/api/notifications/rmt?offset=20&limit=20&order=timestamp&direction=asc");
    expect(model.sortOrder).toEqual({order:"timestamp", direction: "asc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );
    expect(model.selectedNotification).toBe( null );

    model.sortBy({order:"agent_name", direction: "desc"});
    xhrManager.requests[4].resolve(createItems(20));

    expect(xhrManager.requests[4].url).toEqual(
      "/api/notifications/rmt?offset=0&limit=20&order=agent_name&direction=desc");
    expect(model.sortOrder).toEqual({order:"agent_name", direction: "desc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( false );
    expect(model.selectedNotification).toBe( null );
  });

  function createItems(count) {
    var items = [];
    for( let i=0; i<count; i++ ) {
      items.push({
        agentId:   "agent_id",
        agentName: "agent_name",
        timestamp: new Date(i*1000),
        message:   "message" + i,
        readAt:    i%2===0 ? new Date(i*1000+10) : null
      });
    }
    return items;
  }

});
