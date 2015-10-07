import ContainerJS  from "container-js"
import Observable   from "../../utils/observable"
import Deferred     from "../../utils/deferred"
import Collections  from "../../utils/collections"

export default class AgentSources extends Observable {

  constructor() {
    super();
    this.agentService = ContainerJS.Inject;
    this.sources = [];
    this.byId    = {};
  }

  load() {
    this.agentService.getSources().then((sources) => {
      this.sources = Collections.sortBy(sources, (item) => item.name);
      this.byId    = Collections.toMap(sources);
      this.fire("loaded", {items:this.sources});
    });
  }

  get(id) {
    return this.byId[id] || null;
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
    return this.agentService.addSource( name, body ).then( (a) => {
      this.sources.push(a);
      Collections.sortBy(this.sources, (item) => item.name);
      this.byId[a.id] = a;
      this.fire("added", {item: a});
      return a;
    });
  }
  remove(id) {
    return this.agentService.deleteSource( id ).then( (a) => {
      let item = this.byId[id];
      this.byId[id] = null;
      this.sources = this.sources.filter((s)=> s.id !== id);
      this.fire("removed", {item: item});
      return a;
    });
  }

  update(id, name, body) {
    return this.agentService.updateSource( id, name, "", body ).then( (a) => {
      this.byId[id] = a;
      this.sources = this.sources.filter((s)=> s.id !== id);
      this.sources.push(a);
      Collections.sortBy(this.sources, (item) => item.name);
      this.fire("updated", {item: a});
      return a;
    });
  }

}
