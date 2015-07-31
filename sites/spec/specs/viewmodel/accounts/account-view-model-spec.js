import ContainerJS      from "container-js"
import ContainerFactory from "../../../utils/test-container-factory"

describe("AccountViewModel", () => {

  var model;
  var xhrManager;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("viewModelFactory");
    const factory = ContainerJS.utils.Deferred.unpack(d);
    model = factory.createAccountViewModel();
  });

  describe("initialize", () => {

    it("口座情報を取得できる", () => {
      model.initialize();
      xhrManager = model.rmtService.xhrManager;
      xhrManager.requests[0].resolve({
        balance:            30230400,
        balanceOfYesterday: 40000400,
        marginRate:           0.0032,
        profitOrLoss:           5860
      });

      expect(model.balance).toEqual(30230400);
      expect(model.formatedBalance).toEqual("30,230,400");
      expect(model.profitOrLoss).toEqual(5860);
      expect(model.formatedProfitOrLoss).toEqual("5,860");
      expect(model.marginRate).toEqual(0.0032);
      expect(model.formatedMarginRate).toEqual("0.32%");
      expect(model.changesFromPreviousDay).toEqual(-9770000);
      expect(model.formatedChangesFromPreviousDay).toEqual("-9,770,000");
      expect(model.formatedChangeRatioFromPreviousDay).toEqual("-24.4%");
    });

    it("前日の残高が取得できない場合", () => {
      model.initialize();
      xhrManager = model.rmtService.xhrManager;
      xhrManager.requests[0].resolve({
        balance:            30230400,
        balanceOfYesterday:     null,
        marginRate:           0.0032,
        profitOrLoss:           5860
      });

      expect(model.balance).toEqual(30230400);
      expect(model.formatedBalance).toEqual("30,230,400");
      expect(model.profitOrLoss).toEqual(5860);
      expect(model.formatedProfitOrLoss).toEqual("5,860");
      expect(model.marginRate).toEqual(0.0032);
      expect(model.formatedMarginRate).toEqual("0.32%");
      expect(model.changesFromPreviousDay).toEqual(undefined);
      expect(model.formatedChangesFromPreviousDay).toEqual(undefined);
      expect(model.formatedChangeRatioFromPreviousDay).toEqual(undefined);
    });

  });

});
