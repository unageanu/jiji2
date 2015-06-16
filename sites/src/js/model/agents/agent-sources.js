import ContainerJS  from "container-js"
import Observable   from "../../utils/observable"
import Deferred     from "../../utils/deferred";

export default class AgentSources extends Observable {

  constructor() {
    this.agentService = ContainerJS.Inject;
    this.sources = [];
    this.byId    = {};
  }

  load() {
    this.agentService.getSources().then((sources) => {
      this.sources = this.sortByName(sources);
      this.byId    = this.createSourceMap(sources);
      this.fire("loaded", {items:this.sources});
    });
  }

  getBody(id) {
    let d = new Deferred();
    let item = this.byId[id];
    if (item && item.body != null) {
      d.resolve(item.body);
    } else {
      this.agentService.getSource(id).then((r)=>{
        item.body = r.body;
        d.resolve(r.body);
      });
    }
    return d;
  }


  add( name, body ) {
    this.agentService.addSource( name, body ).then( (a) => {
      this.sources.push(a);
      this.sortByName( this.sources );
      this.byId[a.id] = a;
      this.fire("added", {item: a});
    });
  }
  remove(id) {
    this.agentService.deleteSource( id ).then( (a) => {
      let item = this.byId[id];
      this.byId[id] = null;
      this.sources = this.sources.filter((s)=> s.id !== id);
      this.fire("removed", {item: item});
    });
  }

  update(id, name, body) {
    this.agentService.updateSource( id, name, body ).then( (a) => {
      this.byId[id] = a;
      this.sources = this.sources.filter((s)=> s.id !== id);
      this.sources.push(a);
      this.sortByName( this.sources );
      this.fire("updated", {item: a});
    });
  }

  sortByName( sources ) {
    sources.sort((a, b) => a.name > b.name ? 1 : -1 );
    return sources;
  }
  createSourceMap() {
    return this.sources.reduce((r, s) => {
      r[s.id] = s;
      return r;
    }, {});
  }

}
