import TableModel from "src/viewmodel/widgets/table-model"
import Deferred   from "src/utils/deferred"

describe("TableModel", () => {

  var loader;
  var model;

  beforeEach(() => {
    loader = {
      load(offset, limit, sortOrder ) {
        this.offset    = offset;
        this.limit     = limit;
        this.sortOrder = sortOrder;
        this.deferred  = new Deferred();
        return this.deferred;
      },
      count() {
        const deferred  =new Deferred();
        deferred.resolve(this.itemCount);
        return deferred;
      },
      itemCount: 90
    };
    model = new TableModel(loader, {name: "asc"}, 20);
  });

  it("loadで一覧を取得できる", () => {

    model.load();
    loader.deferred.resolve(createItems(0, 20));

    expect(loader.offset).toEqual( 0 );
    expect(loader.limit).toEqual( 20 );
    expect(loader.sortOrder).toEqual({name: "asc"});
    expect(model.items.length).toEqual( 20 );
    expect(model.hasNext).toEqual( true );
    expect(model.hasPrev).toEqual( false );
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

  function createItems(start, count) {
    const items = [];
    for (let i=0; i<count; i++) {
      items.push("item"+(start+i));
    }
    return items;
  }

});
