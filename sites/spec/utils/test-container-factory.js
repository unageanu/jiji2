import ContainerJS  from "container-js"
import mockModules  from "./mock-modules"
import modules      from "src/composing/modules"
import babelLoader  from "src/composing/babel-loader"

export default class TestContainerFactory {
  createContainer() {
    return new ContainerJS.Container(
      (binder) => {
        mockModules(binder);
        modules(binder);
      },
      ContainerJS.PackagingPolicy.COMMON_JS_MODULE_PER_CLASS,
      babelLoader
    );
  }
}
