export default {
  Code: {
    CANCELED: "CANCELED",
    NETWORK_ERROR: "NETWORK_ERROR",

    SERVER_BUSY: "SERVER_BUSY",

    UNAUTHORIZED: "UNAUTHORIZED",
    OPERATION_NOT_ALLOWED: "OPERATION_NOT_ALLOWED",

    NOT_FOUND: "NOT_FOUND",
    INVALID_VALUE: "INVALID_VALUE"
  },

  create(params={}) {
    const error = new Error();
    for (let i in params) {
      error[i] = params[i];
    }
    return error;
  },

  rise(params={}) {
    throw this.create(params);
  }
}
