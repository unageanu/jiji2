import ContainerJS      from "container-js";
import ContainerFactory from "../../../utils/test-container-factory";


function date(m) {
  return new Date(2015, 4, 1, 0, 0, m);
}

function extractProperties(backtest) {
  return {
    id:          backtest.id,
    name:        backtest.name,
    status:      backtest.status,
    createdAt:   backtest.createdAt,
    progress:    backtest.progress,
    currentTime: backtest.currentTime
  };
}

const matchers = {
  toSomeBacktest(util, customEqualityTesters) {
    return {
      compare(actual, expected) {
        const propertiesOfActual   = extractProperties(actual);
        const propertiesOfExpected = extractProperties(expected);
        return {
          pass: util.equals(
            propertiesOfActual, propertiesOfExpected, customEqualityTesters)
        };
      }
    };
  },
  toSomeBacktests(util, customEqualityTesters) {
    return {
      compare(actual, expected) {
        const propertiesOfActual   = actual.map((a) => extractProperties(a));
        const propertiesOfExpected = expected.map((e) => extractProperties(e));
        return {
          pass: util.equals(
            propertiesOfActual, propertiesOfExpected, customEqualityTesters)
        };
      }
    };
  }
};

describe("Backtests", () => {

  var target;
  var xhrManager;

  beforeEach(() => {
    jasmine.addMatchers(matchers);

    let container = new ContainerFactory().createContainer();
    let d = container.get("backtests");
    target = ContainerJS.utils.Deferred.unpack(d);
    xhrManager = target.backtestService.xhrManager;

    target.initialize();
    xhrManager.requests[0].resolve([
      {id: "1", name:"aa", status: "finished",          createdAt: date(1)},
      {id: "2", name:"cc", status: "running",           createdAt: date(2)},
      {id: "3", name:"bb", status: "wait_for_start",    createdAt: date(3)},
      {id: "4", name:"dd", status: "wait_for_cancel",   createdAt: date(4)},
      {id: "5", name:"ee", status: "wait_for_finished", createdAt: date(5)},
      {id: "6", name:"ff", status: "error",             createdAt: date(6)},
      {id: "7", name:"gg", status: "cancelled",         createdAt: date(7)}
    ]);
    xhrManager.clear();
  });
  afterEach(() => {
    target.stopUpdater();
  });

  it("initializeでソース一覧をロードできる", () => {
    expect(target.tests).toSomeBacktests([
      {id: "5", name:"ee", status: "wait_for_finished", createdAt: date(5)},
      {id: "4", name:"dd", status: "wait_for_cancel",   createdAt: date(4)},
      {id: "2", name:"cc", status: "running",           createdAt: date(2)},
      {id: "3", name:"bb", status: "wait_for_start",    createdAt: date(3)},
      {id: "7", name:"gg", status: "cancelled",         createdAt: date(7)},
      {id: "6", name:"ff", status: "error",             createdAt: date(6)},
      {id: "1", name:"aa", status: "finished",          createdAt: date(1)}
    ]);

    // 複数回呼び出しても再読み込みはされない。
    target.initialize();
    expect(xhrManager.requests.length).toEqual(0);
    expect(target.tests).toSomeBacktests([
      {id: "5", name:"ee", status: "wait_for_finished", createdAt: date(5)},
      {id: "4", name:"dd", status: "wait_for_cancel",   createdAt: date(4)},
      {id: "2", name:"cc", status: "running",           createdAt: date(2)},
      {id: "3", name:"bb", status: "wait_for_start",    createdAt: date(3)},
      {id: "7", name:"gg", status: "cancelled",         createdAt: date(7)},
      {id: "6", name:"ff", status: "error",             createdAt: date(6)},
      {id: "1", name:"aa", status: "finished",          createdAt: date(1)}
    ]);
  });

  it("loadでソース一覧を再読み込みできる", () => {
    target.load();
    xhrManager.requests[0].resolve([
      {id: "1", name:"aa", status: "finished",          createdAt: date(1)},
      {id: "2", name:"cc", status: "running",           createdAt: date(2)},
      {id: "3", name:"bb", status: "wait_for_start",    createdAt: date(3)},
      {id: "7", name:"gg", status: "cancelled",         createdAt: date(7)}
    ]);
    expect(target.tests).toSomeBacktests([
      {id: "2", name:"cc", status: "running",           createdAt: date(2)},
      {id: "3", name:"bb", status: "wait_for_start",    createdAt: date(3)},
      {id: "7", name:"gg", status: "cancelled",         createdAt: date(7)},
      {id: "1", name:"aa", status: "finished",          createdAt: date(1)}
    ]);
  });

  it("getでテストを取得できる", () => {
    expect(target.get("2")).toSomeBacktest(
      {id: "2", name:"cc", status: "running", createdAt: date(2)});
  });

  it("registerでテストを登録できる", () => {
    target.register({name:"hhh"});
    xhrManager.requests[0].resolve({
      id:   "8",
      name: "hh",
      status: "wait_for_start",
      createdAt: date(10)
    });
    expect(target.tests).toSomeBacktests([
      {id: "5", name:"ee", status: "wait_for_finished", createdAt: date(5)},
      {id: "4", name:"dd", status: "wait_for_cancel",   createdAt: date(4)},
      {id: "2", name:"cc", status: "running",           createdAt: date(2)},
      {id: "8", name:"hh", status: "wait_for_start",    createdAt: date(10)},
      {id: "3", name:"bb", status: "wait_for_start",    createdAt: date(3)},
      {id: "7", name:"gg", status: "cancelled",         createdAt: date(7)},
      {id: "6", name:"ff", status: "error",             createdAt: date(6)},
      {id: "1", name:"aa", status: "finished",          createdAt: date(1)}
    ]);
  });

  it("removeでソースを削除できる", () => {
    target.remove("3");
    xhrManager.requests[0].resolve({});

    expect(target.tests).toSomeBacktests([
      {id: "5", name:"ee", status: "wait_for_finished", createdAt: date(5)},
      {id: "4", name:"dd", status: "wait_for_cancel",   createdAt: date(4)},
      {id: "2", name:"cc", status: "running",           createdAt: date(2)},
      {id: "7", name:"gg", status: "cancelled",         createdAt: date(7)},
      {id: "6", name:"ff", status: "error",             createdAt: date(6)},
      {id: "1", name:"aa", status: "finished",          createdAt: date(1)}
    ]);
  });

  it("updateState で状態を更新できる", () => {
    target.updateState();
    xhrManager.requests[0].resolve([
      {id: "4", name:"dd", status: "finished",
        createdAt: date(4), progress:1,   currentTime: date(100)},
      {id: "2", name:"cc", status: "running",
        createdAt: date(2), progress:0.2, currentTime: date(200)}
    ]);

    expect(target.tests).toSomeBacktests([
      {id: "5", name:"ee", status: "wait_for_finished", createdAt: date(5)},
      {id: "2", name:"cc", status: "running",
        createdAt: date(2), progress:0.2, currentTime: date(200)},
      {id: "3", name:"bb", status: "wait_for_start",    createdAt: date(3)},
      {id: "7", name:"gg", status: "cancelled",         createdAt: date(7)},
      {id: "6", name:"ff", status: "error",             createdAt: date(6)},
      {id: "4", name:"dd", status: "finished",
        createdAt: date(4), progress:1,   currentTime: date(100)},
      {id: "1", name:"aa", status: "finished",          createdAt: date(1)}
    ]);

    target.updateState();
    xhrManager.requests[1].resolve([
      {id: "2", name:"cc", status: "finished"},
      {id: "3", name:"bb", status: "cancelled"},
      {id: "5", name:"ee", status: "error"}
    ]);

    expect(target.tests).toSomeBacktests([
      {id: "7", name:"gg", status: "cancelled",         createdAt: date(7)},
      {id: "6", name:"ff", status: "error",             createdAt: date(6)},
      {id: "5", name:"ee", status: "error",
        createdAt: date(5), progress:undefined, currentTime: undefined},
      {id: "4", name:"dd", status: "finished",
        createdAt: date(4), progress:1,   currentTime: date(100)},
      {id: "3", name:"bb", status: "cancelled",
        createdAt: date(3), progress:undefined, currentTime: undefined},
      {id: "2", name:"cc", status: "finished",
        createdAt: date(2), progress:undefined, currentTime: undefined},
      {id: "1", name:"aa", status: "finished",          createdAt: date(1)}
    ]);

    target.updateState();
    expect(xhrManager.requests.length).toEqual(2);
  });

});
