import ContainerJS      from "container-js"
import ContainerFactory from "../../../utils/test-container-factory"

describe("PositionsTableModel", () => {

  var model;
  var xhrManager;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("viewModelFactory");
    const factory = ContainerJS.utils.Deferred.unpack(d);
    model = factory.createPositionsTableModel(20);
    model.initialize("rmt");
    xhrManager = model.positionService.xhrManager;
  });

  describe("load", () => {

    it("loadで一覧を取得できる", () => {

      model.load();
      xhrManager.requests[0].resolve({
        count: 50
      });
      xhrManager.requests[1].resolve(createItems(20));

      expect(xhrManager.requests[1].url).toEqual(
        "/api/positions/rmt?offset=0&limit=20&order=profit_or_loss&direction=desc");
      expect(model.sortOrder).toEqual({order:"profit_or_loss", direction: "desc"});

      expect(model.items[0].enteredAt).toEqual( new Date(0) );
      expect(model.items[0].formatedEnteredAt).not.toBe( null );
      expect(model.items[0].entryPrice).toEqual( 0 );
      expect(model.items[0].formatedEntryPrice).toEqual( "0" );
      expect(model.items[0].exitPrice).toEqual( 1 );
      expect(model.items[0].formatedExitPrice).toEqual( "1" );
      expect(model.items[0].profitOrLoss).toEqual( 0 );
      expect(model.items[0].formatedProfitOrLoss).toEqual( "0" );
      expect(model.items[0].units).toEqual( 1000 );
      expect(model.items[0].formatedUnits).toEqual( "1,000" );
      expect(model.items[0].sellOrBuy).toEqual( "sell" );
      expect(model.items[0].formatedSellOrBuy).toEqual( "売" );
      expect(model.items[0].exitedAt).toEqual( new Date(10) );
      expect(model.items[0].formatedExitedAt).not.toBe( null );
      expect(model.items[0].closingPolicy.takeProfit).toEqual( undefined );
      expect(model.items[0].closingPolicy.formatedTakeProfit).toEqual( "-" );
      expect(model.items[0].closingPolicy.lossCut).toEqual( undefined );
      expect(model.items[0].closingPolicy.formatedLossCut).toEqual( "-" );

      expect(model.items[1].enteredAt).toEqual( new Date(1000) );
      expect(model.items[1].formatedEnteredAt).not.toBe( null );
      expect(model.items[1].entryPrice).toEqual( 1 );
      expect(model.items[1].formatedEntryPrice).toEqual( "1" );
      expect(model.items[1].exitPrice).toEqual( 2 );
      expect(model.items[1].formatedExitPrice).toEqual( "2" );
      expect(model.items[1].profitOrLoss).toEqual( 1000 );
      expect(model.items[1].formatedProfitOrLoss).toEqual( "1,000" );
      expect(model.items[1].units).toEqual( 2000 );
      expect(model.items[1].formatedUnits).toEqual( "2,000" );
      expect(model.items[1].sellOrBuy).toEqual( "buy" );
      expect(model.items[1].formatedSellOrBuy).toEqual( "買" );
      expect(model.items[1].exitedAt).toEqual( null );
      expect(model.items[1].formatedExitedAt).toEqual( "" );
      expect(model.items[1].closingPolicy.takeProfit).toEqual( 1001 );
      expect(model.items[1].closingPolicy.formatedTakeProfit).toEqual( "1,001" );
      expect(model.items[1].closingPolicy.lossCut).toEqual( 1011 );
      expect(model.items[1].closingPolicy.formatedLossCut).toEqual( "1,011" );
      expect(model.hasNext).toEqual( true );
      expect(model.hasPrev).toEqual( false );
      expect(model.selectedPosition).toBe( null );
    });

    it("データ数0の場合、ロードは行われない。", () => {

      model.load();
      xhrManager.requests[0].resolve({
        count: 0
      });
      expect(model.sortOrder).toEqual({order:"profit_or_loss", direction: "desc"});
      expect(model.items).toEqual( [] );
      expect(model.hasNext).toEqual( false );
      expect(model.hasPrev).toEqual( false );
      expect(model.selectedPosition).toBe( null );
    });

  });

  describe("選択", () => {
    it("通知を選択できる", () => {
      model.load();
      xhrManager.requests[0].resolve({
        count: 50
      });
      xhrManager.requests[1].resolve(createItems(20));

      model.selectedPosition = model.items[0];
      expect(model.selectedPosition).toBe( model.items[0] );
    });
    it("次へ/前へを押してページを切り替えると、選択が解除される", () => {
      model.load();
      xhrManager.requests[0].resolve({
        count: 50
      });
      xhrManager.requests[1].resolve(createItems(20));

      model.selectedPosition = model.items[0];
      model.next();
      xhrManager.requests[2].resolve(createItems(20));
      expect(model.selectedPosition).toBe( null );

      model.selectedPosition = model.items[0];
      model.prev();
      xhrManager.requests[3].resolve(createItems(20));
      expect(model.selectedPosition).toBe( null );
    });
    it("ソート順を変更すると、選択が解除される", () => {
      model.load();
      xhrManager.requests[0].resolve({
        count: 50
      });
      xhrManager.requests[1].resolve(createItems(20));

      model.selectedPosition = model.items[0];
      model.sortBy({order:"timestamp", direction: "asc"});
      xhrManager.requests[2].resolve(createItems(20));
      expect(model.selectedPosition).toBe( null );
    });
    it("一覧を再読み込みすると、選択が解除される", () => {
      model.load();
      xhrManager.requests[0].resolve({
        count: 50
      });
      xhrManager.requests[1].resolve(createItems(20));

      model.selectedPosition = model.items[0];
      model.load();
      xhrManager.requests[2].resolve({
        count: 50
      });
      xhrManager.requests[3].resolve(createItems(20));
      expect(model.selectedPosition).toBe( null );
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
      "/api/positions/rmt?offset=20&limit=20&order=profit_or_loss&direction=desc");
    expect(model.sortOrder).toEqual({order:"profit_or_loss", direction: "desc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );
    expect(model.selectedPosition).toBe( null );


    model.next();
    xhrManager.requests[3].resolve(createItems(20));

    expect(xhrManager.requests[3].url).toEqual(
      "/api/positions/rmt?offset=40&limit=20&order=profit_or_loss&direction=desc");
    expect(model.sortOrder).toEqual({order:"profit_or_loss", direction: "desc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( false );
    expect(model.hasPrev).toEqual( true );
    expect(model.selectedPosition).toBe( null );


    model.prev();
    xhrManager.requests[4].resolve(createItems(20));

    expect(xhrManager.requests[4].url).toEqual(
      "/api/positions/rmt?offset=20&limit=20&order=profit_or_loss&direction=desc");
    expect(model.sortOrder).toEqual({order:"profit_or_loss", direction: "desc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );
    expect(model.selectedPosition).toBe( null );


    model.prev();
    xhrManager.requests[5].resolve(createItems(20));

    expect(xhrManager.requests[5].url).toEqual(
      "/api/positions/rmt?offset=0&limit=20&order=profit_or_loss&direction=desc");
    expect(model.sortOrder).toEqual({order:"profit_or_loss", direction: "desc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( false );
    expect(model.selectedPosition).toBe( null );

  });

  it("sortByでソート順を変更できる", () => {
    model.load();
    xhrManager.requests[0].resolve({
      count: 60
    });
    xhrManager.requests[1].resolve(createItems(20));

    model.sortBy({order:"profit_or_loss", direction: "desc"});
    xhrManager.requests[2].resolve(createItems(20));

    expect(xhrManager.requests[2].url).toEqual(
      "/api/positions/rmt?offset=0&limit=20&order=profit_or_loss&direction=desc");
    expect(model.sortOrder).toEqual({order:"profit_or_loss", direction: "desc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( false );
    expect(model.selectedPosition).toBe( null );

    model.next();
    xhrManager.requests[3].resolve(createItems(20));

    expect(xhrManager.requests[3].url).toEqual(
      "/api/positions/rmt?offset=20&limit=20&order=profit_or_loss&direction=desc");
    expect(model.sortOrder).toEqual({order:"profit_or_loss", direction: "desc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );
    expect(model.selectedPosition).toBe( null );

    model.sortBy({order:"entered_at", direction: "asc"});
    xhrManager.requests[4].resolve(createItems(20));

    expect(xhrManager.requests[4].url).toEqual(
      "/api/positions/rmt?offset=0&limit=20&order=entered_at&direction=asc");
    expect(model.sortOrder).toEqual({order:"entered_at", direction: "asc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( false );
    expect(model.selectedPosition).toBe( null );
  });

  function createItems(count) {
    var items = [];
    for( let i=0; i<count; i++ ) {
      items.push({
        entryPrice:   i,
        exitPrice:    i+1,
        profitOrLoss: i*1000,
        units:        i*1000 + 1000,
        sellOrBuy:    i%2===0 ? "sell" : "buy",
        enteredAt:    new Date(i*1000),
        exitedAt:     i%2===0 ? new Date(i*1000+10) : null,
        closingPolicy: i%2===0 ? null : {
          takeProfit: i+1000,
          lossCut:    i+1010
        }
      });
    }
    return items;
  }

});
