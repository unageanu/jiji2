import Objects from "src/utils/objects"

describe("Objects", () => {

  describe("convert", () => {
    it("オブジェクトの値を変換できる", () => {

      const object = createTestOjbect();

      const converted = Objects.convert( object, (v, k) => {
        if (k === "string") {
          return "converted";
        } else if (k === "number") {
          return v*2;
        }
        return v;
      });

      expect(object).toEqual(createTestOjbect());

      expect(converted).toEqual({
        string : "converted",
        number: 20,
        date: new Date(10),
        array: [
          "string",
          null,
          10,
          new Date(100),
          {
            string : "converted",
            number: 20,
            date: new Date(10)
          }
        ],
        object : {
          string : "converted",
          number: 20,
          date: new Date(10)
        }
      });
    });

    it("keyConvertを指定するとオブジェクトのキーを変換できる", () => {

      const object = createTestOjbect();

      const converted = Objects.convert( object, (v, k) => {
        if (k === "string") {
          return "converted";
        } else if (k === "number") {
          return v*2;
        }
        return v;
      }, (k) => k + "x" );

      expect(object).toEqual(createTestOjbect());

      expect(converted).toEqual({
        stringx : "converted",
        numberx: 20,
        datex: new Date(10),
        arrayx: [
          "string",
          null,
          10,
          new Date(100),
          {
            stringx : "converted",
            numberx: 20,
            datex: new Date(10)
          }
        ],
        objectx : {
          stringx : "converted",
          numberx: 20,
          datex: new Date(10)
        }
      });
    });
  });

  it("traverseValuesでオブジェクトの値をスキャンできる", () => {
    const object = createTestOjbect();

    var i = 0;
    Objects.traverseValues( object, (v, k) => {
      i++;
    });

    expect( i ).toBe(13);
  });

  function createTestOjbect() {
    return {
      string : "string",
      number: 10,
      date: new Date(10),
      array: [
        "string",
        null,
        10,
        new Date(100),
        {
          string : "string",
          number: 10,
          date: new Date(10)
        }
      ],
      object : {
        string : "string",
        number: 10,
        date: new Date(10)
      }
    };
  }

});
