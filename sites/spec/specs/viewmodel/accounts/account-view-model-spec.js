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
      expect(model.formatedChangeRatioFromPreviousDay).toEqual("-24.42%");
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
      expect(model.formatedChangesFromPreviousDay).toEqual("-");
      expect(model.formatedChangeRatioFromPreviousDay).toEqual("-");
    });

    it("balanceが小数になる場合", () => {
      model.initialize();
      xhrManager = model.rmtService.xhrManager;
      xhrManager.requests[0].resolve({
        balance:            2999881.9505,
        balanceOfYesterday: 2999882.1165,
        marginRate:               0.0032,
        profitOrLoss:               5860
      });

      expect(model.balance).toEqual(2999881.9505);
      expect(model.formatedBalance).toEqual("2,999,881.9505");
      expect(model.profitOrLoss).toEqual(5860);
      expect(model.formatedProfitOrLoss).toEqual("5,860");
      expect(model.marginRate).toEqual(0.0032);
      expect(model.formatedMarginRate).toEqual("0.32%");
      expect(model.changesFromPreviousDay).toEqual(-0.166);
      expect(model.formatedChangesFromPreviousDay).toEqual("-0.166");
      expect(model.formatedChangeRatioFromPreviousDay).toEqual("-0.00%");
    });

  });

});
