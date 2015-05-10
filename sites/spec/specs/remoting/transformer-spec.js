import Transformer    from "src/remoting/transformer"
import Dates          from "src/utils/dates"
import CustomMatchers from "../../utils/custom-matchers"

describe("Transformer", () => {

  beforeEach(() => jasmine.addMatchers(CustomMatchers) );

  it("transformResponse", () => {
    const t = new Transformer();

    const transformed = t.transformResponse({
      timestamp:           "2015-04-20T12:02:20.001+09:00",
      "start_at":          "2015-04-20T12:02:20.002Z",
      string:              "2015-04-20T12:02:20.002Z",
      "illegal_format_at": "2015-04-20T12:02:20.002X",
      object: {
        timestamp:           "2015-04-20T12:02:20-06:00",
        "end_at":            "2015-04-20T12:02:20Z",
        string:              "2015-04-20T12:02:20-06:00",
        "illegal_format_at": "2015-04-20T12:02:20X"
      }
    });

    expect(transformed).toEq({
      timestamp:           Dates.date( 1429498940001 ),
      "startAt":           Dates.date( 1429531340002 ),
      string:              "2015-04-20T12:02:20.002Z",
      "illegalFormatAt":   "2015-04-20T12:02:20.002X",
      object: {
        timestamp:         Dates.date( 1429552940000 ),
        "endAt":           Dates.date( 1429531340000 ),
        string:            "2015-04-20T12:02:20-06:00",
        "illegalFormatAt": "2015-04-20T12:02:20X"
      }
    });

    expect(t.transformResponse(null)).toEqual(null);
  });

  it("transformRequest", () => {
    const t = new Transformer();

    const transformed = t.transformRequest({
      startAt:   Dates.date( "2015-04-20T12:02:20+09:00" ),
      arrayValue: [
        Dates.date( "2015-04-20T12:02:20.001+09:00" ),
        Dates.date( "2015-04-20T12:02:20.001Z" )
      ],
      objectValue: {
        startAt: Dates.date( "2015-04-20T12:02:20+09:00" )
      }
    });

    expect(transformed).toEq({
      "start_at":   "2015-04-20T03:02:20.000Z",
      "array_value": [
        "2015-04-20T03:02:20.001Z",
        "2015-04-20T12:02:20.001Z"
      ],
      "object_value": {
        "start_at":  "2015-04-20T03:02:20.000Z"
      }
    });

    expect(t.transformRequest(null)).toEqual(null);
  });

});
