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
  return a.createdAt.getTime() > b .createdAt.getTime() ? -1 : 1;
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

  load() {
    this.backtestService.getAll().then((tests) => {
      tests = tests.map((test) => this.convertToBacktest(test));
      tests.sort(comparator);
      this.tests  = tests;
      this.byId   = Collections.toMap(tests);
      this.fire("loaded", {items:this.tests});
    });
  }

  get(id) {
    return this.byId[id];
  }

  register( testConfig ) {
    return this.backtestService.register( testConfig ).then( (test) => {
      test = this.convertToBacktest(test);
      this.tests.push(test);
      this.tests.sort(comparator);
      this.byId[test.id] = test;
      this.fire("added", {item: test});
      return test;
    });
  }

  remove(id) {
    return this.backtestService.remove( id ).then( () => {
      let item = this.byId[id];
      this.byId[id] = null;
      this.tests = this.tests.filter((s)=> s.id !== id);
      this.fire("removed", {item: item});
      return item;
    });
  }

  updateState() {
    this.backtestService.getRunnings().then((tests) => {
      tests.forEach((test) => {
        const dst = this.byId[test.id];
        dst.status       = test.status;
        dst.progress     = test.progress;
        dst.currentTime = test.currentTime;
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

}
