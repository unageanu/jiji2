import Transformer from "src/remoting/transformer"

describe("Transformer", () => {

  it("Dateオブジェクトを変換できる", () => {
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
      "start_at":          new Date( 1429531340002 ),
      string:              "2015-04-20T12:02:20.002Z",
      "illegal_format_at": "2015-04-20T12:02:20.002X",
      object: {
        timestamp:           new Date( 1429552940000 ),
        "end_at":            new Date( 1429531340000 ),
        string:              "2015-04-20T12:02:20-06:00",
        "illegal_format_at": "2015-04-20T12:02:20X"
      }
    });

  });

});
