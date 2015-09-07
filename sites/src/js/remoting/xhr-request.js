import Deferred        from "../utils/deferred";
import axios           from "axios"
import Msgpack         from "msgpack"
import HTTPHeaderField from "./http-header-field";
import Error           from "../model/error";
import Transformer     from "./transformer";

export default class XhrRequest {

  constructor(manager, url, method, body, params, isBackground = false) {
    this.url = url;
    this.body = body;
    this.manager = manager;
    this.method = method;
    this.params = params;
    this.isBackground = isBackground;
    this.deferred = new Deferred();

    this.transformer = new Transformer();
  }

  result() {
    return this.deferred;
  }

  resendable() {
    return this.method === "GET" || this.isBackground;
  }

  send() {
    const config = this.buildConfig();
    this.manager.startLoading();
    this.sendRequest(config).then(
      this.onSuccess.bind(this),
      this.onFail.bind(this));
  }

  onSuccess(response) {
    if (this.canceled) return;
    this.manager.endLoading();
    this.manager.handleResponse(this, response.data);
  }

  onFail(response) {
    if (this.canceled) return;
    this.manager.endLoading();
    this.manager.handleError(this, this.convertError(response));
  }

  addAuthorizationHeader(headers) {
    if (!this.manager.sessionManager.isLoggedIn) return;
    headers[HTTPHeaderField.AUTHORIZATION] =
      "X-JIJI-AUTHENTICATE " + this.manager.sessionManager.getToken();
  }

  buildConfig() {
    const base = {
      url: this.url,
      method: this.method,
      params: this.params,
      timeout: 1000 * 60 * 3,
      transformRequest: [this.transformRequest.bind(this)],
      transformResponse: [this.transformResponse.bind(this)],
      data: this.body,
      responseType: "arraybuffer",
      headers: {
        "Content-Type": "application/x-msgpack"
      }
    };
    this.addAuthorizationHeader(base.headers);
    return base;
  }

  transformRequest(data) {
    let transformed = this.transformer.transformRequest(data);
    return new Uint8Array(Msgpack.msgpack.pack(transformed));
  }
  transformResponse(arrayBuffer) {
    if (!arrayBuffer) return null
    let data = Msgpack.msgpack.unpack(new Uint8Array(arrayBuffer));
    return this.transformer.transformResponse(data);
  }

  cancel() {
    this.canceled = true;
    this.manager.handleError(this, {
      code: Error.Code.CANCELED
    });
  }

  sendRequest(setting) {
    return axios(setting);
  }

  isAuthRequest() {
    return (
      (this.url.match(/\/api\/authenticator$/) && this.method === "POST")
      || (this.url.match(/\/api\/settings\/user\/password$/) && this.method === "PUT")
    );
  }

  convertError(response) {
    return Error.create({
      response: response,
      code: this.convertErrorCode(response)
    });
  }

  convertErrorCode(response) {
    switch (response.status) {
      case 400:
        return Error.Code.INVALID_VALUE;
      case 401:
        return Error.Code.UNAUTHORIZED;
      case 403:
        return Error.Code.OPERATION_NOT_ALLOWED;
      case 404:
        return Error.Code.NOT_FOUND;
      case 406:
        return Error.Code.INVALID_VALUE;
      default:
        return Error.Code.SERVER_BUSY;
    }
  }
}
