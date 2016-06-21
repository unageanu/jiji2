import MockXhrManager   from "./mock/remoting/xhr-manager"
import MockLocalStorage from "./mock/stores/local-storage"

export default (binder) => {
  binder.bind("xhrManager")
    .toInstance(new MockXhrManager());
  binder.bind("localStorage")
    .toInstance(new MockLocalStorage());
}
