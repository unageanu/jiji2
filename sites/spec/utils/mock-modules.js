import modules        from "src/composing/modules";
import MockXhrManager from "./mock/remoting/xhr-manager";

export default (binder) => {
  binder.bind("xhrManager")
    .toInstance(new MockXhrManager());

  modules(binder);
}
