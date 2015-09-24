import SelectionModel    from "../widgets/selection-model"
import PositionModel     from "./position-model"

export default class PositionSelectionModel extends SelectionModel {

  constructor( positionService, urlResolver ) {
    super();
    this.positionService = positionService;
    this.urlResolver = urlResolver;
  }

  convertItem(item) {
    return new PositionModel(item, this.urlResolver);
  }

  loadItem(positionIdd) {
    this.selected = null;
    this.positionService.get(positionId).then( (position)=> {
      this.selected = this.convertItem(position);
    });
  }
}
