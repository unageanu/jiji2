import ContainerJS      from "container-js"
import DateWithOffset   from "date-with-offset"
import _                from "underscore"

import GraphType        from "src/viewmodel/chart/graph-type"
import Numbers          from "src/utils/numbers"
import Dates            from "src/utils/dates"

import CustomMatchers   from "../../../utils/custom-matchers"

describe("GraphType", () => {

  var type;
  var coordinateCalculator;

  beforeEach(() => {
    jasmine.addMatchers(CustomMatchers);
    coordinateCalculator = {
      calculateY( value ) {
        return value;
      },
      calculateX( value ) {
        return value;
      },
      rateAreaHeight:   200,
      profitAreaHeight: 100,
      graphAreaHeight:  100
    };
  });

  describe("Rate", () => {
    beforeEach(() => type = GraphType.create("rate", coordinateCalculator) );

    it("calculateY は coordinateCalculator.calculateY()の値をそのまま返す", () => {
      expect(type.calculateY(10)).toEqual(10);
      expect(type.calculateY(100)).toEqual(100);
      expect(type.calculateY(null)).toEqual(null);
    });
    it("getAxises は 空の配列を返す", () => {
      expect(type.calculateAxises([-10, 20, 30])).toEqual([]);
    });
  });

  describe("Line", () => {
    beforeEach(() => {
      type = GraphType.create("line", coordinateCalculator);
    });

    describe("値にばらつきがある場合", ()=> {
      beforeEach(() => {
        type.calculateRange([
          [1, 10, 20], [-10, 3, null]
        ], [20, 70]);
      });
      it("calculateY は 値に対応する座標を返す", () => {
        expect(type.calculateY(12)).toEqual(376.75);
        expect(type.calculateY(48)).toEqual(339.25);
        expect(type.calculateY(null)).toEqual(null);
      });
      it("getAxises は axisesの値を座標系に変換したものを返す", () => {
        expect(type.calculateAxises([-12, 21, 30])).toEqual([
          {value: -12, y:402}, {value:21, y:367}, {value:30, y:358}
        ]);
      });
    });
    describe("値がすべて同じ場合", ()=> {
      beforeEach(() => {
        type.calculateRange([
          [10], [10, null]
        ], null);
      });
      it("calculateY は 値に対応する座標を返す", () => {
        expect(type.calculateY(10)).toEqual(358);
        expect(type.calculateY(null)).toEqual(null);
      });
      it("getAxises は axisesの値を座標系に変換したものを返す", () => {
        expect(type.calculateAxises([10])).toEqual([
          {value: 10, y:358}
        ]);
      });
    });
    describe("値がすべてnullの場合", ()=> {
      beforeEach(() => {
        type.calculateRange([
          [null], [null]
        ], null);
      });
      it("calculateY は 値に対応する座標を返す", () => {
        expect(type.calculateY(null)).toEqual(null);
      });
      it("getAxises は axisesの値を座標系に変換したものを返す", () => {
        expect(type.calculateAxises([])).toEqual([]);
      });
    });
  });

  describe("ProfitOrLoss", () => {
    beforeEach(() => {
      type = GraphType.create("profitOrLoss", coordinateCalculator);
    });

    describe("値にばらつきがある場合", ()=> {
      beforeEach(() => {
        type.calculateRange([
          [0, 100, 15280], [-4720, 1234, null]
        ], []);
      });
      it("calculateY は 値に対応する座標を返す", () => {
        expect(type.calculateY(0)).toEqual(280);
        expect(type.calculateY(13248)).toEqual(224.8);
        expect(type.calculateY(-3312)).toEqual(293.8);
        expect(type.calculateY(null)).toEqual(null);
      });
      it("getAxises は 金額に応じた座標系を返す", () => {
        expect(type.calculateAxises([])).toEqual([
          {value: 10000, y: 238}, {value:0, y:280}
        ]);
      });
    });
    describe("値がすべて同じ場合", ()=> {
      beforeEach(() => {
        type.calculateRange([
          [0], [0, null]
        ], null);
      });
      it("calculateY は 値に対応する座標を返す", () => {
        expect(type.calculateY(0)).toEqual(258);
        expect(type.calculateY(null)).toEqual(null);
      });
      it("getAxises は axisesの値を座標系に変換したものを返す", () => {
        expect(type.calculateAxises([])).toEqual([
          {value: 0, y:258}
        ]);
      });
    });
    describe("値がすべてnullの場合", ()=> {
      beforeEach(() => {
        type.calculateRange([
          [null], [null]
        ], null);
      });
      it("calculateY は 値に対応する座標を返す", () => {
        expect(type.calculateY(null)).toEqual(null);
      });
      it("getAxises は axisesの値を座標系に変換したものを返す", () => {
        expect(type.calculateAxises([])).toEqual([
          {value: 0, y:258}
        ]);
      });
    });
  });

});
