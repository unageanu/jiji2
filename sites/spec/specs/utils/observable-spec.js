import Observable from "../../../src/js/utils/observable"

describe("Observable", () => {

    it( "登録したObserverにイベントを通知できる", () => {

      var target = new Observable();

      const log = [];
      target.addObserver( "a", (n, e) => log.push(e.value) );
      target.addObserver( "a", (n, e) => log.push(e.value) );
      target.addObserver( "b", (n, e) => log.push(e.value) );

      target.fire("a", {value:"aa"});
      expect( log.length ).toBe( 2 );
      expect( log[0] ).toBe( "aa" );
      expect( log[1] ).toBe( "aa" );

      target.fire("b", {value:"bb"});
      expect( log.length ).toBe( 3 );
      expect( log[0] ).toBe( "aa" );
      expect( log[1] ).toBe( "aa" );
      expect( log[2] ).toBe( "bb" );

      target.fire("c", {value:"cc"});
      expect( log.length ).toBe( 3 );
      expect( log[0] ).toBe( "aa" );
      expect( log[1] ).toBe( "aa" );
      expect( log[2] ).toBe( "bb" );
    });

});
