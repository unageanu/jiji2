import ContainerJS  from "container-js"
import Observable   from "../../utils/observable"

export default class AgentSourceEditor extends Observable {

  constructor() {
    super();
    this.agentSources = ContainerJS.Inject;
  }

  initialize() {
    this.registerObservers();
  }

  registerObservers() {
    ["loaded", "added", "updated", "removed"].forEach((e) =>
      this.agentSources.addObserver(e, this.onSourcesChanged.bind(this), this));
  }

  load() {
    this.agentSources.load();
  }

  newSourceFile() {
    const name = this.newSourceFileName();
    this.agentSources.add(name, "")
      .then((source) => this.startEdit(source.id));
  }

  startEdit(id) {
    this.setProperty("editTarget", this.agentSources.get(id));
    this.setProperty("targetBody", null);
    this.agentSources.getBody(id).then(
      (body) => this.setProperty("targetBody", body) );
  }

  save(name, body) {
    const target = this.getProperty("editTarget");
    if (target == null) return;

    this.agentSources.update(target.id, name, body).then((source) => {
      this.setProperty("editTarget", source);
    });
  }

  remove() {
    const target = this.getProperty("editTarget");
    if (target == null) return;

    this.agentSources.remove(target.id).then(() => {
      this.setProperty("editTarget", null);
      this.setProperty("targetBody", null);
    });
  }

  onSourcesChanged() {
    this.setProperty("sources", this.agentSources.sources);
  }

  get editTarget() {
    return this.getProperty("editTarget");
  }
  get targetBody() {
    return this.getProperty("targetBody");
  }

  newSourceFileName() {
    let i = 0;
    let name = "new_agent.rb";
    while ( this.existsSourceFile(name) ) {
      name = "new_agent" + (i++) + ".rb";
    }
    return name;
  }
  existsSourceFile(name) {
    return !!this.agentSources.sources.find((s) => s.name === name );
  }

}
