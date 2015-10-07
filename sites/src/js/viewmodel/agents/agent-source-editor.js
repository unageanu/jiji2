import ContainerJS     from "container-js"
import Observable      from "../../utils/observable"
import Validators      from "../../utils/validation/validators"
import ValidationUtils from "../utils/validation-utils"

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
    const editTarget = this.agentSources.get(id);
    this.setProperty("editTarget", editTarget);
    this.setProperty("targetBody", null);
    if (editTarget) {
      this.agentSources.getBody(id).then(
        (body) => this.setProperty("targetBody", body) );
    }
  }

  save(name, body) {
    const target = this.getProperty("editTarget");
    if (target == null) return;
    if (!this.validate(name)) return;

    this.agentSources.update(target.id, name, body).then((source) => {
      this.setProperty("editTarget", source);
      this.setProperty("targetBody", body);
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

  validate(name) {
    return ValidationUtils.validate(Validators.agentFileName, name,
      {field: "ファイル名"}, (error) => this.fileNameError = error );
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

  get fileNameError() {
    return this.getProperty("fileNameError");
  }
  set fileNameError(fileNameError) {
    this.setProperty("fileNameError", fileNameError);
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
