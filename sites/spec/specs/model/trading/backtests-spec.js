import ContainerJS      from "container-js";
import ContainerFactory from "../../../utils/test-container-factory";


function date(m) {
  return new Date(2015, 4, 1, 0, 0, m);
}

describe("Backtests", () => {

  var target;
  var xhrManager;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("backtests");
    target = ContainerJS.utils.Deferred.unpack(d);
    xhrManager = target.backtestService.xhrManager;

    target.load();
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

  it("loadでソース一覧をロードできる", () => {
    expect(target.tests).toEqual([
      {id: "5", name:"ee", status: "wait_for_finished", createdAt: date(5)},
      {id: "4", name:"dd", status: "wait_for_cancel",   createdAt: date(4)},
      {id: "2", name:"cc", status: "running",           createdAt: date(2)},
      {id: "3", name:"bb", status: "wait_for_start",    createdAt: date(3)},
      {id: "7", name:"gg", status: "cancelled",         createdAt: date(7)},
      {id: "6", name:"ff", status: "error",             createdAt: date(6)},
      {id: "1", name:"aa", status: "finished",          createdAt: date(1)}
    ]);
  });

  it("getでテストを取得できる", () => {
    expect(target.get("2")).toEqual(
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
    expect(target.tests).toEqual([
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

    expect(target.tests).toEqual([
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

    expect(target.tests).toEqual([
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
  });

});
