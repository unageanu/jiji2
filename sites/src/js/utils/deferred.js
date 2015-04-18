import ContainerJS from "container-js"

export default ContainerJS.utils.Deferred;

// export default class Deferred {
//   constructor() {
//     this.promise = new Promise(this.callback.bind(this));
//   }
//   callback(resolve, reject) {
//     this.resolve = resolve;
//     this.reject = reject;
//   }
//   promise() {
//     return this.promise;
//   }
//   then( success, fail ) {
//     return this.promise.then(success, fail);
//   }
// }
