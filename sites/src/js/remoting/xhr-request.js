import Deferred        from "../utils/deferred";
import xhr             from "xhr"
import Msgpack         from "msgpack"
import HTTPHeaderField from "./http-header-field";
import Error           from "../model/error";
import Transformer     from "./transformer";

export default class XhrRequest {

  constructor(manager, url, method, body, options) {
    this.url = url;
    this.body = body;
    this.manager = manager;
    this.method = method;
    this.options = options;
    this.isBackground = options.isBackground || false;
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
    const base = Object.assign({
      url: this.url,
      method: this.method,
      params: this.params,
      body: this.transformRequest(this.body),
      withCredentials: false,
      headers: this.options.multipart ? {} : {
        "Content-Type": "application/x-msgpack"
      },
      responseType: "arraybuffer"
    }, this.options);
    this.addAuthorizationHeader(base.headers);
    return base;
  }

  transformRequest(data) {
    if (data == null) return null;
    if (this.options.multipart) return data;
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
    const d = new Deferred();
    xhr(setting, (err, resp, body) => {
      if (err) {
        d.reject(err);
      } else {
        if (resp.statusCode >= 400) {
          d.reject(resp);
        } else {
          resp.data = this.transformResponse(resp.body);
          d.resolve(resp);
        }
      }
    });
    return d;
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
    if (response.statusCode == null) return Error.Code.NETWORK_ERROR;
    switch (response.statusCode) {
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
