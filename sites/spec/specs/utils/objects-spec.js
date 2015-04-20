import Objects from "src/utils/objects"
import _       from "underscore";

describe("Objects", () => {

  it("convertでオブジェクトの値を変換できる", () => {

    const object = createTestOjbect();

    const converted = Objects.convert( object, (v, k) => {
      if (k === "string") {
        return "converted";
      } else if (k === "number") {
        return v*2;
      }
      return v;
    });

    expect(_.isEqual(object, createTestOjbect())).toBe(true);

    expect(_.isEqual(converted, {
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
    })).toBe(true);
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
