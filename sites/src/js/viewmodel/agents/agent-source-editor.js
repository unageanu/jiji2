import ContainerJS     from "container-js"
import Observable      from "../../utils/observable"
import Validators      from "../../utils/validation/validators"
import ValidationUtils from "../utils/validation-utils"
import DateFormatter   from "../utils/date-formatter"

export default class AgentSourceEditor extends Observable {

  constructor() {
    super();
    this.agentSources = ContainerJS.Inject;
    this.timeSource   = ContainerJS.Inject;
  }

  initialize() {
    this.registerObservers();

    this.isSaving   = false;
    this.savedLabel = null;
  }

  registerObservers() {
    ["loaded", "added", "updated", "removed"].forEach((e) =>
      this.agentSources.addObserver(e, this.onSourcesChanged.bind(this), this));
  }

  load() {
    this.isSaving   = false;
    this.savedLabel = null;
    this.setProperty("editTarget", null);
    this.setProperty("targetBody", null);
    this.setProperty("fileNameError", null);

    this.agentSources.load();
  }

  newSourceFile() {
    const name = this.newSourceFileName();
    this.agentSources.add(name, "")
      .then((source) => this.startEdit(source.id));
  }

  startEdit(id) {
    this.savedLabel = null;
    const editTarget = this.agentSources.get(id);
    this.setProperty("editTarget", editTarget);
    this.setProperty("targetBody", null);
    this.setProperty("fileNameError", null);
    if (editTarget) {
      this.agentSources.getBody(id).then(
        (body) => this.setProperty("targetBody", body) );
    }
  }

  save(name, body, formatMessage) {
    const target = this.getProperty("editTarget");
    if (target == null) return;
    if (!this.validate(name, formatMessage)) return;

    this.isSaving = true;
    this.savedLabel = null;
    this.agentSources.update(target.id, name, body).then((source) => {
      this.setProperty("editTarget", source);
      this.setProperty("targetBody", body);
      this.setProperty("fileNameError", null);
      this.isSaving   = false;
      this.savedLabel = formatMessage({id:'viewmodel.AgentSourceEditor.saved'}) + " ( " +
        DateFormatter.format(this.timeSource.now) + " )";
    }, () => this.isSaving = false );
  }

  remove() {
    const target = this.getProperty("editTarget");
    if (target == null) return;

    this.agentSources.remove(target.id).then(() => {
      this.setProperty("editTarget", null);
      this.setProperty("targetBody", null);
      this.setProperty("fileNameError", null);
    });
  }

  validate(name, formatMessage) {
    return ValidationUtils.validate(Validators.agentFileName, name,
      {field: formatMessage({id:'validation.fields.fileName'})}, (error) => this.fileNameError = error, formatMessage );
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

  get sources() {
    return this.getProperty("sources");
  }

  get isSaving() {
    return this.getProperty("isSaving");
  }
  set isSaving(isSaving) {
    this.setProperty("isSaving", isSaving);
  }

  get savedLabel() {
    return this.getProperty("savedLabel");
  }
  set savedLabel(savedLabel) {
    this.setProperty("savedLabel", savedLabel);
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
