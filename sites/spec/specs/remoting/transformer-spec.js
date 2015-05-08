import Transformer from "src/remoting/transformer"

describe("Transformer", () => {

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

    expect(transformed).toEqual({
      timestamp:           new Date( 1429498940001 ),
      "startAt":          new Date( 1429531340002 ),
      string:              "2015-04-20T12:02:20.002Z",
      "illegalFormatAt": "2015-04-20T12:02:20.002X",
      object: {
        timestamp:           new Date( 1429552940000 ),
        "endAt":            new Date( 1429531340000 ),
        string:              "2015-04-20T12:02:20-06:00",
        "illegalFormatAt": "2015-04-20T12:02:20X"
      }
    });

    expect(t.transformResponse(null)).toEqual(null);
  });

  it("transformRequest", () => {
    const t = new Transformer();

    const transformed = t.transformRequest({
      startAt:   new Date( "2015-04-20T12:02:20+09:00" ),
      arrayValue: [
        new Date( "2015-04-20T12:02:20.001+09:00" ),
        new Date( "2015-04-20T12:02:20.001Z" )
      ],
      objectValue: {
        startAt: new Date( "2015-04-20T12:02:20+09:00" )
      }
    });

    expect(transformed).toEqual({
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
