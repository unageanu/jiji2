import Collections from "src/utils/collections"

describe("Collections", () => {

  it("#toMap でMapに変換できる", () => {
    expect( Collections.toMap([
      {id: 1, name:"aa"},
      {id: 2, name:"bb"},
      {id: 3, name:"cc"}
    ])).toEqual({
      "1" : {id: 1, name:"aa"},
      "2" : {id: 2, name:"bb"},
      "3" : {id: 3, name:"cc"}
    });

    expect( Collections.toMap([
      {id: 1, name:"aa"},
      {id: 2, name:"bb"},
      {id: 3, name:"cc"}
    ], (item) => item.name)).toEqual({
      "aa" : {id: 1, name:"aa"},
      "bb" : {id: 2, name:"bb"},
      "cc" : {id: 3, name:"cc"}
    });
  });

  it("#sortBy で配列をソートできる", () => {
    expect( Collections.sortBy([
      {id: 1, name:"aa"},
      {id: 2, name:"cc"},
      {id: 3, name:"bb"}
    ], (item) => item.name)).toEqual([
      {id: 1, name:"aa"},
      {id: 3, name:"bb"},
      {id: 2, name:"cc"}
    ]);

    expect( Collections.sortBy([
      {id: 1, name:"aa"},
      {id: 2, name:"cc"},
      {id: 3, name:"bb"}
    ], (item) => item.id*-1)).toEqual([
      {id: 3, name:"bb"},
      {id: 2, name:"cc"},
      {id: 1, name:"aa"}
    ]);
  });

});
