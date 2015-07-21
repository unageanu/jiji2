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
    model.initialize();
    xhrManager = model.notificationService.xhrManager;
    xhrManager.requests[0].resolve([
      {id: "aa", name:"aaa", createdAt: new Date(200)},
      {id: "bb", name:"bbb", createdAt: new Date(100)}
    ]);
    xhrManager.requests = [];
  });

  describe("load", () => {

    it("loadで一覧を取得できる", () => {
      model.load();
      xhrManager.requests[0].resolve({
        count: 50
      });
      xhrManager.requests[1].resolve(createItems(20));

      expect(xhrManager.requests[1].url).toEqual(
        "/api/notifications?offset=0&limit=20&"
        + "order=timestamp&direction=desc");
      expect(model.sortOrder).toEqual({order:"timestamp", direction: "desc"});
      expect(model.filterCondition).toEqual({backtestId: null});
      expect(model.items[0].timestamp).toEqual( new Date(0) );
      expect(model.items[0].formatedTimestamp).not.toBe( null );
      expect(model.hasNext).toEqual( true );
      expect(model.hasPrev).toEqual( false );
      expect(model.selectedNotification).toBe( null );
      expect(model.availableFilterConditions).toEqual([
        { id: "all", text:"すべて",        condition: {backtestId: null} },
        { id: "rmt", text:"リアルトレード", condition: {backtestId: "rmt"} },
        { id: "aa",  text:"aaa",          condition: {backtestId: "aa"} },
        { id: "bb",  text:"bbb",          condition: {backtestId: "bb"} }
      ]);
    });

    it("データ数0の場合、ロードは行われない。", () => {
      model.load();
      xhrManager.requests[0].resolve({
        count: 0
      });
      expect(model.sortOrder).toEqual({order:"timestamp", direction: "desc"});
      expect(model.filterCondition).toEqual({backtestId: null});
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

      expect(model.items[1].readAt).toBe( null );
      model.selectedNotification = model.items[1];
      expect(model.selectedNotification).toBe( model.items[1] );
      expect(model.items[1].readAt).not.toBe( null );
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
      "/api/notifications?offset=20&limit=20&"
      + "order=timestamp&direction=desc");
    expect(model.sortOrder).toEqual({order:"timestamp", direction: "desc"});
    expect(model.filterCondition).toEqual({backtestId: null});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );
    expect(model.selectedNotification).toBe( null );


    model.next();
    xhrManager.requests[3].resolve(createItems(20));

    expect(xhrManager.requests[3].url).toEqual(
      "/api/notifications?offset=40&limit=20"
      + "&order=timestamp&direction=desc");
    expect(model.sortOrder).toEqual({order:"timestamp", direction: "desc"});
    expect(model.filterCondition).toEqual({backtestId: null});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( false );
    expect(model.hasPrev).toEqual( true );
    expect(model.selectedNotification).toBe( null );


    model.prev();
    xhrManager.requests[4].resolve(createItems(20));

    expect(xhrManager.requests[4].url).toEqual(
      "/api/notifications?offset=20&limit=20"
      + "&order=timestamp&direction=desc");
    expect(model.sortOrder).toEqual({order:"timestamp", direction: "desc"});
    expect(model.filterCondition).toEqual({backtestId: null});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );
    expect(model.selectedNotification).toBe( null );


    model.prev();
    xhrManager.requests[5].resolve(createItems(20));

    expect(xhrManager.requests[5].url).toEqual(
      "/api/notifications?offset=0&limit=20"
      + "&order=timestamp&direction=desc");
    expect(model.sortOrder).toEqual({order:"timestamp", direction: "desc"});
    expect(model.filterCondition).toEqual({backtestId: null});
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
      "/api/notifications?offset=0&limit=20"
      + "&order=timestamp&direction=asc");
    expect(model.sortOrder).toEqual({order:"timestamp", direction: "asc"});
    expect(model.filterCondition).toEqual({backtestId: null});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( false );
    expect(model.selectedNotification).toBe( null );

    model.next();
    xhrManager.requests[3].resolve(createItems(20));

    expect(xhrManager.requests[3].url).toEqual(
      "/api/notifications?offset=20&limit=20"
      + "&order=timestamp&direction=asc");
    expect(model.sortOrder).toEqual({order:"timestamp", direction: "asc"});
    expect(model.filterCondition).toEqual({backtestId: null});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );
    expect(model.selectedNotification).toBe( null );

    model.sortBy({order:"agent_name", direction: "desc"});
    xhrManager.requests[4].resolve(createItems(20));

    expect(xhrManager.requests[4].url).toEqual(
      "/api/notifications?offset=0&limit=20"
      + "&order=agent_name&direction=desc");
    expect(model.sortOrder).toEqual({order:"agent_name", direction: "desc"});
    expect(model.filterCondition).toEqual({backtestId: null});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( false );
    expect(model.selectedNotification).toBe( null );
  });

  it("filterで一覧の絞り込みができる", () => {
    model.load();
    xhrManager.requests[0].resolve({
      count: 60
    });
    xhrManager.requests[1].resolve(createItems(20));

    model.filter(model.availableFilterConditions[1].condition);
    xhrManager.requests[2].resolve({
      count: 30
    });
    xhrManager.requests[3].resolve(createItems(20));

    expect(xhrManager.requests[3].url).toEqual(
      "/api/notifications?offset=0&limit=20"
      + "&order=timestamp&direction=desc&backtestId=rmt");
    expect(model.sortOrder).toEqual({order:"timestamp", direction: "desc"});
    expect(model.filterCondition).toEqual({backtestId: "rmt"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( false );
    expect(model.selectedNotification).toBe( null );

    model.next();
    xhrManager.requests[4].resolve(createItems(10));

    expect(xhrManager.requests[4].url).toEqual(
      "/api/notifications?offset=20&limit=20"
      + "&order=timestamp&direction=desc&backtestId=rmt");
    expect(model.sortOrder).toEqual({order:"timestamp", direction: "desc"});
    expect(model.filterCondition).toEqual({backtestId: "rmt"});
    expect(model.items.length).toEqual( 10 );
    expect(model.hasNext).toEqual( false );
    expect(model.hasPrev).toEqual( true );
    expect(model.selectedNotification).toBe( null );

    model.filter(model.availableFilterConditions[2].condition);
    xhrManager.requests[5].resolve({
      count: 50
    });
    xhrManager.requests[6].resolve(createItems(20));

    expect(xhrManager.requests[6].url).toEqual(
      "/api/notifications?offset=0&limit=20"
      + "&order=timestamp&direction=desc&backtestId=aa");
    expect(model.sortOrder).toEqual({order:"timestamp", direction: "desc"});
    expect(model.filterCondition).toEqual({backtestId: "aa"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( false );
    expect(model.selectedNotification).toBe( null );

    model.next();
    xhrManager.requests[7].resolve(createItems(20));

    expect(xhrManager.requests[7].url).toEqual(
      "/api/notifications?offset=20&limit=20"
      + "&order=timestamp&direction=desc&backtestId=aa");
    expect(model.sortOrder).toEqual({order:"timestamp", direction: "desc"});
    expect(model.filterCondition).toEqual({backtestId: "aa"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );
    expect(model.selectedNotification).toBe( null );

    model.sortBy({order:"agent_name", direction: "desc"});
    xhrManager.requests[8].resolve(createItems(20));

    expect(xhrManager.requests[8].url).toEqual(
      "/api/notifications?offset=0&limit=20"
      + "&order=agent_name&direction=desc&backtestId=aa");
    expect(model.sortOrder).toEqual({order:"agent_name", direction: "desc"});
    expect(model.filterCondition).toEqual({backtestId: "aa"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( false );
    expect(model.selectedNotification).toBe( null );


    model.filter(model.availableFilterConditions[0].condition);
    xhrManager.requests[9].resolve({
      count: 0
    });
    expect(model.sortOrder).toEqual({order:"agent_name", direction: "desc"});
    expect(model.filterCondition).toEqual({backtestId: null});
    expect(model.items.length).toEqual( 0 );
    expect(model.hasNext).toEqual( false );
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
