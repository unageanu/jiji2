import ContainerJS      from "container-js";
import ContainerFactory from "../../../utils/test-container-factory";
import Slider           from "src/viewmodel/chart/slider";
import _                from "underscore";

describe("Slider", () => {

  const candleStickPadding = 56;
  var slider;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("viewModelFactory");
    const factory = ContainerJS.utils.Deferred.unpack(d);
    slider = factory.createSlider();
  });


  it("必要なデータが揃うと、表示範囲等の状態が計算される", () => {
    // 最初は未初期化
    expect(slider.range).toBe(undefined);
    expect(slider.width).toBe(undefined);
    expect(slider.pageWidth).toBe(undefined);
    expect(slider.currentRange).toBe(undefined);
    expect(slider.positionX).toBe(undefined);

    // データを設定
    initialize();

    expect(slider.normalizedRange).toEqual({
      start: new Date(2015, 4,  1,  0, 0, 0),
      end:   new Date(2015, 4, 10,  1, 0, 0)
    });
    expect(slider.width).toBe(100);
    expect(slider.pageWidth).toBe(30);
    expect(slider.currentRange).toEqual({
      start: new Date(2015, 4,  9,  5,  0,  0),
      end:   new Date(2015, 4, 10,  1,  0,  0)
    });
    expect(slider.positionX).toBe(70);
  });


  describe("rangeの更新", () => {
    it("rangeが更新されると、状態が更新される", () => {
      initialize();
      slider.rates.reload();
      slider.rates.rateService.xhrManager.requests[1].resolve({
        start: new Date(2015, 3, 30,  0, 1, 10),
        end:   new Date(2015, 4, 11,  0, 2, 20)
      });

      expect(slider.normalizedRange).toEqual({
        start: new Date(2015, 3, 30,  0, 0, 0),
        end:   new Date(2015, 4, 11,  1, 0, 0)
      });
      expect(slider.width).toBe(100);
      expect(slider.pageWidth).toBe(30);
      expect(slider.currentRange).toEqual({
        start: new Date(2015, 4, 10,  5,  0,  0),
        end:   new Date(2015, 4, 11,  1,  0,  0)
      });
      expect(slider.positionX).toBe(70);
    });

    it("最新のレートを表示している場合、rangeが変更となっても最新のレートが表示されたままになる。",  () => {
      initialize(1000);
      expect(slider.width).toBe(1000);
      expect(slider.pageWidth).toBe(92);
      expect(slider.currentRange).toEqual({
        start: new Date(2015, 4,  9,  5,  0,  0),
        end:   new Date(2015, 4, 10,  1,  0,  0)
      });
      expect(slider.positionX).toBe(908);

      slider.rates.reload();
      slider.rates.rateService.xhrManager.requests[1].resolve({
        start: new Date(2015, 3, 30,  0, 1, 10),
        end:   new Date(2015, 4, 11,  0, 2, 20)
      });

      expect(slider.normalizedRange).toEqual({
        start: new Date(2015, 4,  0,  0, 0, 0),
        end:   new Date(2015, 4, 11,  1, 0, 0)
      });
      expect(slider.width).toBe(1000);
      expect(slider.pageWidth).toBe(75);
      expect(slider.currentRange).toEqual({
        start: new Date(2015, 4, 10, 5,  0,  0),
        end:   new Date(2015, 4, 11, 1,  0,  0)
      });
      expect(slider.positionX).toBe(925);
    });

    it("古いレートを表示中の場合、スクロール位置はそのまま維持される",  () => {
      initialize(1000);
      expect(slider.width).toBe(1000);
      expect(slider.pageWidth).toBe(92);
      expect(slider.currentRange).toEqual({
        start: new Date(2015, 4,  9,  5,  0,  0),
        end:   new Date(2015, 4, 10,  1,  0,  0)
      });
      expect(slider.positionX).toBe(908);

      slider.positionX = 900;
      expect(slider.width).toBe(1000);
      expect(slider.pageWidth).toBe(92);
      expect(slider.currentRange).toEqual({
        start: new Date(2015, 4,  9,  3,  0,  0),
        end:   new Date(2015, 4,  9, 23,  0,  0)
      });
      expect(slider.positionX).toBe(900);

      slider.rates.reload();
      slider.rates.rateService.xhrManager.requests[1].resolve({
        start: new Date(2015, 3, 30,  0, 1, 10),
        end:   new Date(2015, 4, 11,  0, 2, 20)
      });

      expect(slider.normalizedRange).toEqual({
        start: new Date(2015, 4,  0,  0, 0, 0),
        end:   new Date(2015, 4, 11,  1, 0, 0)
      });
      expect(slider.width).toBe(1000);
      expect(slider.pageWidth).toBe(75);
      expect(slider.currentRange).toEqual({
        start: new Date(2015, 4,  9,  2,  0,  0),
        end:   new Date(2015, 4,  9, 22,  0,  0)
      });
      expect(slider.positionX).toBe(826);
    });
  });

  it("集計期間を変更すると、状態が更新される", () => {
    initialize(1000);
    slider.preferences.chartInterval = "fifteen_minutes";

    expect(slider.normalizedRange).toEqual({
      start: new Date(2015, 4,  1,  0,  0, 0),
      end:   new Date(2015, 4, 10,  0, 15, 0)
    });
    expect(slider.width).toBe(1000);
    expect(slider.pageWidth).toBe(30);
    expect(slider.currentRange).toEqual({
      start: new Date(2015, 4,  9, 19, 15,  0),
      end:   new Date(2015, 4, 10,  0, 15,  0)
    });
    expect(slider.positionX).toBe(970);

    slider.preferences.chartInterval = "one_minute";

    expect(slider.normalizedRange).toEqual({
      start: new Date(2015, 4,  1,  0, 1, 0),
      end:   new Date(2015, 4, 10,  0, 3, 0)
    });
    expect(slider.width).toBe(1000);
    expect(slider.pageWidth).toBe(30);
    expect(slider.currentRange).toEqual({
      start: new Date(2015, 4,  9, 23, 43,  0),
      end:   new Date(2015, 4, 10,  0,  3,  0)
    });
    expect(slider.positionX).toBe(970);

    slider.preferences.chartInterval = "one_day";

    expect(slider.normalizedRange).toEqual({
      start: new Date(2015, 3, 30,  9, 0, 0),
      end:   new Date(2015, 4, 10,  9, 0, 0)
    });
    expect(slider.width).toBe(1000);
    expect(slider.pageWidth).toBe(2000);
    expect(slider.currentRange).toEqual({
      start: new Date(2015, 3, 20, 9,  0,  0),
      end:   new Date(2015, 4, 10, 9,  0,  0)
    });
    expect(slider.positionX).toBe(-1000);
  });

  describe("スライダーを移動すると、表示範囲が更新される", () => {
    it("スライダーの移動で、現在の表示範囲が更新される", () => {
      initialize(1000);

      slider.positionX = 900;
      expect(slider.width).toBe(1000);
      expect(slider.pageWidth).toBe(92);
      expect(slider.currentRange).toEqual({
        start: new Date(2015, 4,  9,  3,  0,  0),
        end:   new Date(2015, 4,  9, 23,  0,  0)
      });
      expect(slider.positionX).toBe(900);

      slider.positionX = 0;
      expect(slider.width).toBe(1000);
      expect(slider.pageWidth).toBe(92);
      expect(slider.currentRange).toEqual({
        start: new Date(2015, 4,  1,  0,  0,  0),
        end:   new Date(2015, 4,  1, 20,  0,  0)
      });
      expect(slider.positionX).toBe(0);

      slider.positionX = 100;
      expect(slider.width).toBe(1000);
      expect(slider.pageWidth).toBe(92);
      expect(slider.currentRange).toEqual({
        start: new Date(2015, 4,  1, 21,  0,  0),
        end:   new Date(2015, 4,  2, 17,  0,  0)
      });
      expect(slider.positionX).toBe(100);
    });
    it("0以下 or スライド可能な最大幅以上には移動できない", () => {
      initialize(1000);

      slider.positionX = 1000;
      expect(slider.width).toBe(1000);
      expect(slider.pageWidth).toBe(92);
      expect(slider.currentRange).toEqual({
        start: new Date(2015, 4,  9,  5,  0,  0),
        end:   new Date(2015, 4, 10,  1,  0,  0)
      });
      expect(slider.positionX).toBe(908);

      slider.positionX = -100;
      slider.positionX = 0;
      expect(slider.width).toBe(1000);
      expect(slider.pageWidth).toBe(92);
      expect(slider.currentRange).toEqual({
        start: new Date(2015, 4,  1,  0,  0,  0),
        end:   new Date(2015, 4,  1, 20,  0,  0)
      });
      expect(slider.positionX).toBe(0);
    });
  });

  it("goToで任意の日付に移動できる", () => {
    initialize(1000);

    slider.goTo( new Date(2015, 4, 6,  5,  0,  0));
    expect(slider.width).toBe(1000);
    expect(slider.pageWidth).toBe(92);
    expect(slider.currentRange).toEqual({
      start: new Date(2015, 4,  5, 19,  0,  0),
      end:   new Date(2015, 4,  6, 15,  0,  0)
    });
    expect(slider.positionX).toBe(530);
  });


  function initialize(width=100, candleCount=20, interval="one_hour") {
    slider.width = width;
    slider.rates.initialize();
    slider.rates.rateService.xhrManager.requests[0].resolve({
      start: new Date(2015, 4,  1,  0, 1, 10),
      end:   new Date(2015, 4, 10,  0, 2, 20)
    });
    slider.candleSticks.stageSize = {w:candleStickPadding+6*candleCount, h:100};
    slider.preferences.chartInterval = interval;
  }

});
