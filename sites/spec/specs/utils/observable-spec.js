import Observable from "src/utils/observable"

describe("Observable", () => {

  var target;

  beforeEach(() => {
    target = new Observable();
  });

  it("登録したObserverにイベントを通知できる", () => {
    const log = [];
    target.addObserver("a", (n, e) => log.push(e.value));
    target.addObserver("a", (n, e) => log.push(e.value));
    target.addObserver("b", (n, e) => log.push(e.value));

    target.fire("a", {
      value: "aa"
    });
    expect(log.length).toBe(2);
    expect(log[0]).toBe("aa");
    expect(log[1]).toBe("aa");

    target.fire("b", {
      value: "bb"
    });
    expect(log.length).toBe(3);
    expect(log[0]).toBe("aa");
    expect(log[1]).toBe("aa");
    expect(log[2]).toBe("bb");

    target.fire("c", {
      value: "cc"
    });
    expect(log.length).toBe(3);
    expect(log[0]).toBe("aa");
    expect(log[1]).toBe("aa");
    expect(log[2]).toBe("bb");
  });

  it("removeObserverでobserverを削除できる", () => {
    const log = [];
    const observer1 = (n, e) => log.push(e.value);
    const observer2 = (n, e) => log.push(e.value+"2");
    target.addObserver("a", observer1);
    target.addObserver("a", observer2);
    target.addObserver("b", observer1);

    target.removeObserver( "a", observer1 );

    target.fire("a", {
      value: "aa"
    });
    expect(log.length).toBe(1);
    expect(log[0]).toBe("aa2");

    target.fire("b", {
      value: "bb"
    });
    expect(log.length).toBe(2);
    expect(log[0]).toBe("aa2");
    expect(log[1]).toBe("bb");

    target.removeObserver( "a", observer2 );
    target.removeObserver( "b", observer1 );

    target.fire("a", {
      value: "aa"
    });
    target.fire("b", {
      value: "bb"
    });
    expect(log.length).toBe(2);
  });

  it("receiverを指定して登録すると、removeAllObserversでreceiverに関連したObserverをまとめて削除できる", () => {

    const receiver1 = {};
    const receiver2 = {};

    const log = [];
    target.addObserver("a", (n, e) => log.push(e.value+"1"), receiver1);
    target.addObserver("a", (n, e) => log.push(e.value+"2"), receiver2);
    target.addObserver("a", (n, e) => log.push(e.value));
    target.addObserver("b", (n, e) => log.push(e.value+"1"), receiver1);

    target.removeAllObservers(receiver1);

    target.fire("a", {
      value: "aa"
    });
    expect(log.length).toBe(2);
    expect(log[0]).toBe("aa2");
    expect(log[1]).toBe("aa");

    target.fire("b", {
      value: "bb"
    });
    expect(log.length).toBe(2);

    target.removeAllObservers(receiver2);
    target.fire("a", {
      value: "aa"
    });
    expect(log.length).toBe(3);
    expect(log[0]).toBe("aa2");
    expect(log[1]).toBe("aa");
    expect(log[2]).toBe("aa");
  });

  describe("setProperty/getProperty", () => {

    it("プロパティを更新できる", () => {
      expect(target.getProperty("a")).toBe(undefined);

      target.setProperty("a", "aa");
      target.setProperty("b", 10);
      expect(target.getProperty("a")).toBe("aa");
      expect(target.getProperty("b")).toBe(10);
    });

    it("プロパティの変更がある場合、イベントが通知される", () => {
      const log = [];
      target.addObserver("propertyChanged", (n, e) => log.push(e));

      target.setProperty("a", "aa");
      expect(log.length).toBe(1);
      expect(log[0].key).toBe("a");
      expect(log[0].oldValue).toBe(undefined);
      expect(log[0].newValue).toBe("aa");

      target.setProperty("a", "bb");
      expect(log.length).toBe(2);
      expect(log[1].key).toBe("a");
      expect(log[1].oldValue).toBe("aa");
      expect(log[1].newValue).toBe("bb");

      target.setProperty("a", "bb");
      expect(log.length).toBe(2);
    });

    it("引数でcomparatorを指定できる", () => {
      const log = [];
      target.addObserver("propertyChanged", (n, e) => log.push(e));

      target.setProperty("a", "aa");
      expect(log.length).toBe(1);
      expect(log[0].key).toBe("a");
      expect(log[0].oldValue).toBe(undefined);
      expect(log[0].newValue).toBe("aa");

      target.setProperty("a", "bb", (a, b) => true );
      expect(log.length).toBe(1);

      target.setProperty("a", "aa", (a, b) => false );
      expect(log.length).toBe(2);
      expect(log[1].key).toBe("a");
      expect(log[1].oldValue).toBe("aa");
      expect(log[1].newValue).toBe("aa");
    });

  });

});
