import ContainerJS          from "container-js"
import ContainerFactory     from "../../../utils/test-container-factory"
import IconSelectorModel    from "src/viewmodel/icons/icon-selector-model"

describe("IconSelectorModel", () => {

  var target;
  var xhrManager;

  beforeEach(() => {
    let container = new ContainerFactory().createContainer();
    let d = container.get("icons");
    const icons = ContainerJS.utils.Deferred.unpack(d);
    target = new IconSelectorModel(icons);
    xhrManager = icons.iconService.xhrManager;

    target.initialize();
    xhrManager.requests[0].resolve([
      {id:"aaa"}, {id:"bbb"}
    ]);
    xhrManager.clear();
  });

  it("initializeで状態を初期化できる", () => {
    expect(target.icons.icons).toEqual([
      {id:"aaa"}, {id:"bbb"}
    ]);
    expect(target.selectedId).toEqual(null);
  });

  it("アイコンを選択できる", () => {
    target.selectedId = 1
    expect(target.selectedId).toEqual(1);
  });

});
