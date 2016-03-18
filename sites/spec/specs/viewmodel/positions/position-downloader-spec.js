import ContainerJS      from "container-js"
import ContainerFactory from "../../../utils/test-container-factory"
import Dates            from "src/utils/dates"

describe("PositionsTableModel", () => {

  var model;
  var xhrManager;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("viewModelFactory");
    const factory = ContainerJS.utils.Deferred.unpack(d);
    factory.timeSource.now = new Date(2015, 5, 10);

    model = factory.createPositionDownloader();
    model.initialize("rmt");
    xhrManager = model.positionService.xhrManager;

    Dates.setTimezoneOffset(0);
  });
  afterEach( ()=> Dates.resetTimezoneOffset() );

  describe("#initialize", () => {

    it( "can initialize a instance with a backtest.", () => {
      model.initialize({
        id: "aaa",
        startTime: new Date(2015, 5, 1),
        endTime:   new Date(2015, 5, 3)
      });
      expect(model.backtestId).toEqual( "aaa" );
      expect(model.rangeSelectorModel.enable).toEqual( false );
      expect(model.rangeSelectorModel.startTime).toEqual( new Date(2015,5,1) );
      expect(model.rangeSelectorModel.endTime).toEqual( new Date(2015,5,3) );
      expect(model.rangeSelectorModel.minDate).toEqual( new Date(1995,5,10) );
      expect(model.rangeSelectorModel.maxDate).toEqual( new Date(2015,5,10) );
      expect(model.rangeSelectorModel.startTimeError).toEqual( null );
      expect(model.rangeSelectorModel.endTimeError).toEqual( null );
    });

    it( "can initialize a instance for rmt.", () => {
      model.initialize();
      expect(model.backtestId).toEqual( "rmt" );
      expect(model.rangeSelectorModel.enable).toEqual( false );
      expect(model.rangeSelectorModel.startTime).toEqual( new Date(2015,4,11) );
      expect(model.rangeSelectorModel.endTime).toEqual( new Date(2015,5,10) );
      expect(model.rangeSelectorModel.minDate).toEqual( new Date(1995,5,10) );
      expect(model.rangeSelectorModel.maxDate).toEqual( new Date(2015,5,10) );
      expect(model.rangeSelectorModel.startTimeError).toEqual( null );
      expect(model.rangeSelectorModel.endTimeError).toEqual( null );
    });

  });

  describe("#createCSVDownloadUrl", () => {

    it( "can create a csv download url of all positions for a backtest.", () => {
      model.initialize({
        id: "aaa",
        startTime: new Date(2015, 5, 1),
        endTime:   new Date(2015, 5, 3)
      });

      const d = model.createCSVDownloadUrl();
      xhrManager.requests[0].resolve({token: "token"});

      expect(ContainerJS.utils.Deferred.unpack(d)).toEqual(
        "/api/positions/download/token?backtest_id=aaa&order=entered_at&direction=desc");
      expect(model.rangeSelectorModel.startTimeError).toEqual( null );
      expect(model.rangeSelectorModel.endTimeError).toEqual( null );
    });

    it( "can create a csv download url of filterd positions for the rmt.", () => {
      model.initialize();
      model.rangeSelectorModel.startTime = Dates.date("2015-06-01T00:00:00.000Z");
      model.rangeSelectorModel.endTime   = Dates.date("2015-06-03T00:00:00.000Z");

      model.downloadType = "filtered";
      expect(model.rangeSelectorModel.enable).toEqual( true );

      const d = model.createCSVDownloadUrl();
      xhrManager.requests[0].resolve({token: "token"});

      expect(ContainerJS.utils.Deferred.unpack(d)).toEqual(
        "/api/positions/download/token?backtest_id=rmt&"
        + "start=2015-06-01T00%3A00%3A00.000Z&end=2015-06-04T00%3A00%3A00.000Z"
        + "&order=entered_at&direction=desc");
        expect(model.rangeSelectorModel.startTimeError).toEqual( null );
        expect(model.rangeSelectorModel.endTimeError).toEqual( null );
    });

    it( "fails when the filter condition is invalid.", () => {
      model.initialize();
      model.rangeSelectorModel.startTime = new Date(2015, 5, 3);
      model.rangeSelectorModel.endTime   = new Date(2015, 5, 2);

      model.downloadType = "filtered";
      const d = model.createCSVDownloadUrl();

      expect(ContainerJS.utils.Deferred.unpack(d)).toEqual(null);
      expect(model.rangeSelectorModel.startTimeError).toEqual( '開始日時が不正です' );
      expect(model.rangeSelectorModel.endTimeError).toEqual( null );

      model.prepare();
      expect(model.rangeSelectorModel.startTimeError).toEqual( null );
      expect(model.rangeSelectorModel.endTimeError).toEqual( null );
    });

  });

});
