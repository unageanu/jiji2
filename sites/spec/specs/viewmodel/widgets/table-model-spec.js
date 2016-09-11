import TableModel from "src/viewmodel/widgets/table-model"
import Deferred   from "src/utils/deferred"

describe("TableModel", () => {

  var loader;
  var model;

  beforeEach(() => {
    loader = {
      load(offset, limit, sortOrder, filterCondition ) {
        this.offset    = offset;
        this.limit     = limit;
        this.sortOrder = sortOrder;
        this.filter    = filterCondition;
        this.deferred  = new Deferred();
        return this.deferred;
      },
      count(filterCondition) {
        const deferred  =new Deferred();
        this.filterForCount = filterCondition;
        deferred.resolve({count:this.itemCount});
        return deferred;
      }, 
      itemCount: 90
    };
    model = new TableModel({name: "asc"}, 20);
    model.initialize(loader);
  });

  describe("load", () => {
    it("loadで一覧を取得できる", () => {
      model.load();
      expect(model.items).toEqual( null );
      loader.deferred.resolve(createItems(0, 20));

      expect(loader.offset).toEqual( 0 );
      expect(loader.limit).toEqual( 20 );
      expect(loader.sortOrder).toEqual({name: "asc"});
      expect(loader.filter).toEqual(null);
      expect(loader.filterForCount).toEqual(null);
      expect(model.items.length).toEqual( 20 );
      expect(model.hasNext).toEqual( true );
      expect(model.hasPrev).toEqual( false );
    });
    it("要素数が0の場合、一覧の取得は行われない", () => {
      loader.itemCount = 0;
      model.load();

      expect(model.items.length).toEqual( 0 );
      expect(model.hasNext).toEqual( false );
      expect(model.hasPrev).toEqual( false );
    });
  });

  it("nextで次の一覧を取得できる", () => {

    model.load();
    loader.deferred.resolve(createItems(0, 20));

    model.next();
    loader.deferred.resolve(createItems(20, 20));

    expect(loader.offset).toEqual(20 );
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({name: "asc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );

    model.next();
    loader.deferred.resolve(createItems(40, 20));

    expect(loader.offset).toEqual( 40 );
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({name: "asc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );

    model.next();
    loader.deferred.resolve(createItems(60, 20));

    expect(loader.offset).toEqual( 60 );
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({name: "asc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );

    model.next();
    loader.deferred.resolve(createItems(80, 10));

    expect(loader.offset).toEqual( 80 );
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({name: "asc"});
    expect(model.items.length).toEqual( 10 );
    expect(model.hasNext).toEqual( false );
    expect(model.hasPrev).toEqual( true );

    loader.itemCount = 40;
    model.load();
    loader.deferred.resolve(createItems(0, 20));
    expect(loader.offset).toEqual( 0 );
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({name: "asc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( false );

    model.next();
    loader.deferred.resolve(createItems(20, 20));
    expect(loader.offset).toEqual( 20 );
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({name: "asc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( false );
    expect(model.hasPrev).toEqual( true );
  });

  it("prevで前の一覧を取得できる", () => {

    model.load();
    loader.deferred.resolve(createItems(0, 20));

    model.next();
    loader.deferred.resolve(createItems(20, 20));

    expect(loader.offset).toEqual(20 );
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({name: "asc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );

    model.next();
    loader.deferred.resolve(createItems(40, 20));

    expect(loader.offset).toEqual( 40 );
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({name: "asc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );

    model.prev();
    loader.deferred.resolve(createItems(20, 20));

    expect(loader.offset).toEqual( 20 );
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({name: "asc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );


    model.prev();
    loader.deferred.resolve(createItems(0, 20));

    expect(loader.offset).toEqual( 0 );
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({name: "asc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( false );
  });

  it("sortByでソート順を変更できる", () => {

    model.load();
    loader.deferred.resolve(createItems(0, 20));

    model.sortBy({age: "desc"});
    loader.deferred.resolve(createItems(0, 20));

    expect(loader.offset).toEqual( 0 );
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({age: "desc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( false );


    model.next();
    loader.deferred.resolve(createItems(20, 20));

    expect(loader.offset).toEqual( 20 );
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({age: "desc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );


    model.prev();
    loader.deferred.resolve(createItems(0, 20));

    expect(loader.offset).toEqual( 0 );
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({age: "desc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( false );


    model.next();
    loader.deferred.resolve(createItems(20, 20));

    expect(loader.offset).toEqual( 20 );
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({age: "desc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );


    model.sortBy({age: "asc"});
    loader.deferred.resolve(createItems(0, 20));

    expect(loader.offset).toEqual( 0 );
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({age: "asc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( false );
  });

  it("fillNextで次の一覧を取得できる", () => {

    model.load();
    loader.deferred.resolve(createItems(0, 20));

    model.fillNext();
    loader.deferred.resolve(createItems(20, 20));

    expect(loader.offset).toEqual( 20 );
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({name: "asc"});
    expect(model.items.length).toEqual( 40 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );

    model.fillNext();
    loader.deferred.resolve(createItems(40, 20));

    expect(loader.offset).toEqual( 40 );
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({name: "asc"});
    expect(model.items.length).toEqual( 60 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );

    model.fillNext();
    loader.deferred.resolve(createItems(60, 20));

    expect(loader.offset).toEqual( 60 );
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({name: "asc"});
    expect(model.items.length).toEqual( 80 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );

    model.fillNext();
    loader.deferred.resolve(createItems(80, 10));

    expect(loader.offset).toEqual( 80 );
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({name: "asc"});
    expect(model.items.length).toEqual( 90 );
    expect(model.hasNext).toEqual( false );
    expect(model.hasPrev).toEqual( true );

    model.sortBy({age: "asc"});
    loader.deferred.resolve(createItems(0, 20));

    expect(loader.offset).toEqual( 0 );
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({age: "asc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( false );

    model.fillNext();
    loader.deferred.resolve(createItems(20, 20));

    expect(loader.offset).toEqual( 20 );
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({age: "asc"});
    expect(model.items.length).toEqual( 40 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );
  });

  it("goToで任意のページに移動できる", () => {

    model.load();
    loader.deferred.resolve(createItems(0, 20));

    model.goTo(25);
    loader.deferred.resolve(createItems(25, 20));

    expect(loader.offset).toEqual(25);
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({name: "asc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );

    model.goTo(-5);
    loader.deferred.resolve(createItems(0, 20));

    expect(loader.offset).toEqual(0);
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({name: "asc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( false );

    model.goTo(71);
    loader.deferred.resolve(createItems(70, 19));

    expect(loader.offset).toEqual(70);
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({name: "asc"});
    expect(model.items.length).toEqual( 19 );
    expect(model.hasNext).toEqual( false );
    expect(model.hasPrev).toEqual( true );

    model.goTo(70);
    loader.deferred.resolve(createItems(70, 20));

    expect(loader.offset).toEqual(70);
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({name: "asc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( false );
    expect(model.hasPrev).toEqual( true );

  });

  it("filterで絞り込み条件を指定できる", () => {

    model.load();
    loader.deferred.resolve(createItems(0, 20));

    model.filter({age: 18});
    loader.deferred.resolve(createItems(0, 20));

    expect(loader.offset).toEqual( 0 );
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({name: "asc"});
    expect(loader.filter).toEqual({age: 18});
    expect(loader.filterForCount).toEqual({age: 18});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( false );

    model.next();
    loader.deferred.resolve(createItems(0, 20));

    expect(loader.offset).toEqual( 20 );
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({name: "asc"});
    expect(loader.filter).toEqual({age: 18});
    expect(loader.filterForCount).toEqual({age: 18});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( true );

    model.filter({age: 17});
    loader.deferred.resolve(createItems(0, 20));

    expect(loader.offset).toEqual( 0 );
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({name: "asc"});
    expect(loader.filter).toEqual({age: 17});
    expect(loader.filterForCount).toEqual({age: 17});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( false );

    model.next();
    loader.deferred.resolve(createItems(0, 20));

    model.sortBy({age: "desc"});
    loader.deferred.resolve(createItems(0, 20));

    expect(loader.offset).toEqual( 0 );
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({age: "desc"});
    expect(loader.filter).toEqual({age: 17});
    expect(loader.filterForCount).toEqual({age: 17});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( false );

    loader.itemCount = 0;
    model.filter({age: 16});

    expect(loader.offset).toEqual( 0 );
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({age: "desc"});
    expect(loader.filter).toEqual({age: 17});
    expect(loader.filterForCount).toEqual({age: 16});
    expect(model.items.length).toEqual( 0 );
    expect(model.hasNext).toEqual( false );
    expect(model.hasPrev).toEqual( false );
  });

  function createItems(start, count) {
    const items = [];
    for (let i=0; i<count; i++) {
      items.push("item"+(start+i));
    }
    return items;
  }

});
