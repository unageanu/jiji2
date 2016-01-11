import ContainerJS  from "container-js"
import Observable   from "../../utils/observable"
import Collections  from "../../utils/collections"
import Backtest     from "./backtest"

const statusToNumber = function(item) {
  switch( item.status ) {
    case "running" :
      return 10;
    case "wait_for_cancel" :
      return 1;
    case "wait_for_finished" :
      return 0;
    case "wait_for_start" :
      return 20;
    default:
      return 100;
  }
};

const comparator = (a, b) => {
  const statusA = statusToNumber(a);
  const statusB = statusToNumber(b);
  if ( statusA > statusB ) {
    return 1;
  } else if ( statusA < statusB ) {
    return -1;
  }
  return a.createdAt.getTime() > b.createdAt.getTime() ? -1 : 1;
};

export default class Backtests extends Observable {

  constructor() {
    super();
    this.backtestService = ContainerJS.Inject;
    this.graphService    = ContainerJS.Inject;
    this.positionService = ContainerJS.Inject;

    this.tests = [];
    this.byId  = {};
  }

  initialize() {
    return this.initializedDeferred || this.load();
  }

  load() {
    this.initializedDeferred = this.backtestService.getAll().then((tests) => {
      tests = tests.map((test) => this.convertToBacktest(test));
      tests.sort(comparator);
      this.tests  = tests;
      this.byId   = Collections.toMap(tests);
      this.fire("loaded", {items:this.tests});
    });
    if (!this.updater) this.startUpdater();
    return this.initializedDeferred;
  }

  get(id) {
    return this.byId[id];
  }

  register( testConfig ) {
    return this.backtestService.register( testConfig ).then( (test) => {
      return this.addBacktest(test);
    });
  }

  remove(id) {
    return this.backtestService.remove( id ).then( () => {
      return this.removeBacktest(id);
    });
  }

  restart(id) {
    return this.backtestService.restart( id ).then( (result) => {
      this.removeBacktest(id);
      return this.addBacktest(result.result);
    });
  }

  cancel(id) {
    return this.backtestService.cancel( id ).then( () => {
      let item = this.byId[id];
      item.status = "cancelled"
      this.tests.sort(comparator);
      this.fire("updateStates", {items:this.tests});
      return item;
    });
  }

  updateState() {
    const runningTestsIds = this.getRunningTests().map( (test) => test.id );
    if (runningTestsIds.length <= 0) return;
    this.backtestService.getAll(runningTestsIds, true).then((tests) => {
      tests.forEach((test) => {
        const dst = this.byId[test.id];
        if (dst) {
          dst.status       = test.status;
          dst.progress     = test.progress;
          dst.currentTime = test.currentTime;
        }
      });
      this.tests.sort(comparator);
      this.fire("updateStates", {items:this.tests});
    });
  }

  convertToBacktest(info) {
    const test = new Backtest(info);
    test.injectServices(this.graphService,
      this.positionService, this.backtestService);
    return test;
  }

  getRunningTests() {
    return this.tests.filter((test) => !test.isFinished());
  }

  addBacktest(response) {
    const test = this.convertToBacktest(response);
    this.tests.push(test);
    this.tests.sort(comparator);
    this.byId[test.id] = test;
    this.fire("added", {item: test});
    return test;
  }

  removeBacktest(id) {
    let item = this.byId[id];
    this.byId[id] = null;
    this.tests = this.tests.filter((s)=> s.id !== id);
    this.fire("removed", {item: item});
    return item;
  }

  startUpdater() {
    if (this.updater) return;
    this.updater = setInterval(this.updateState.bind(this), 3000);
  }
  stopUpdater() {
    clearInterval(this.updater);
  }
}
