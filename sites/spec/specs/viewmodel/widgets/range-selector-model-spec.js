import RangeSelectorModel from "src/viewmodel/widgets/range-selector-model"
import Deferred           from "src/utils/deferred"
import Validators         from "src/utils/validation/validators"

describe("RangeSelectorModel", () => {

  var model;

  beforeEach(() => {

    model = new RangeSelectorModel(
      Validators.backtest.startTime,
      Validators.backtest.endTime
    );
    model.initialize(new Date(2015,10,1), new Date(2015,10,15),
      new Date(2015,10,2), new Date(2015,10,3));
  });

  it("初期状態", () => {
    expect(model.startTime).toEqual( new Date(2015,10,2) );
    expect(model.endTime).toEqual( new Date(2015,10,3) );
    expect(model.minDate).toEqual( new Date(2015,10,1) );
    expect(model.maxDate).toEqual( new Date(2015,10,15) );
    expect(model.startTimeError).toEqual( null );
    expect(model.endTimeError).toEqual( null );
  });

  describe("validate", () => {
    it("問題がない場合", () => {
      expect(model.validate()).toEqual( true );

      expect(model.startTime).toEqual( new Date(2015,10,2) );
      expect(model.endTime).toEqual( new Date(2015,10,3) );
      expect(model.minDate).toEqual( new Date(2015,10,1) );
      expect(model.maxDate).toEqual( new Date(2015,10,15) );
      expect(model.startTimeError).toEqual( null );
      expect(model.endTimeError).toEqual( null );
    });
    it("startTimeが未入力の場合", () => {
      model.startTime = null;
      expect(model.validate()).toEqual( false );

      expect(model.startTime).toEqual( null );
      expect(model.endTime).toEqual( new Date(2015,10,3) );
      expect(model.minDate).toEqual( new Date(2015,10,1) );
      expect(model.maxDate).toEqual( new Date(2015,10,15) );
      expect(model.startTimeError).toEqual( "開始日時を入力してください" );
      expect(model.endTimeError).toEqual( null );
    });
    it("endTimeが未入力の場合", () => {
      model.endTime = null;
      expect(model.validate()).toEqual( false );

      expect(model.startTime).toEqual( new Date(2015,10,2) );
      expect(model.endTime).toEqual( null );
      expect(model.minDate).toEqual( new Date(2015,10,1) );
      expect(model.maxDate).toEqual( new Date(2015,10,15) );
      expect(model.startTimeError).toEqual( null );
      expect(model.endTimeError).toEqual( "終了日時を入力してください" );
    });
    it("startTime >= endTimeの場合", () => {
      model.endTime = new Date(2015,10,2);
      expect(model.validate()).toEqual( false );

      expect(model.startTime).toEqual( new Date(2015,10,2) );
      expect(model.endTime).toEqual(  new Date(2015,10,2) );
      expect(model.minDate).toEqual( new Date(2015,10,1) );
      expect(model.maxDate).toEqual( new Date(2015,10,15) );
      expect(model.startTimeError).toEqual( "開始日時が不正です" );
      expect(model.endTimeError).toEqual( null );

      model.endTime = new Date(2015,10,1,23);
      expect(model.validate()).toEqual( false );

      expect(model.startTime).toEqual( new Date(2015,10,2) );
      expect(model.endTime).toEqual(  new Date(2015,10,1,23) );
      expect(model.minDate).toEqual( new Date(2015,10,1) );
      expect(model.maxDate).toEqual( new Date(2015,10,15) );
      expect(model.startTimeError).toEqual( "開始日時が不正です" );
      expect(model.endTimeError).toEqual( null );
    });
  });
});
