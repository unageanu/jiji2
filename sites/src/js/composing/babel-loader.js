import ContainerJS  from "container-js";

export default {
  load( moduleName ) {
    var d = new ContainerJS.utils.Deferred();
    try {
        d.resolve( require( moduleName ).default );
    } catch (e) {
        d.reject(e);
    }
    return d;
  }
}
