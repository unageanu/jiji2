import ContainerJS  from "container-js";
import mockModules  from "./mock-modules";

export default class TestContainerFactory {
  createContainer() {
    return new ContainerJS.Container(
      mockModules,
      ContainerJS.PackagingPolicy.COMMON_JS_MODULE_PER_CLASS,
      ContainerJS.Loaders.COMMON_JS
    );
  }
}
