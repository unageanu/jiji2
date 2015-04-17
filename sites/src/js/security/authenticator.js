import Deferred        from "../utils/deferred";
import ContainerJS     from "container-js";
import Error           from "../model/error";

export default class Authenticator {

    constructor(){
        this.sessionManager = ContainerJS.Inject;
        this.xhrManager     = ContainerJS.Inject;
    }

    serviceUrl() {
        return this.urlResolver.resolveRESTUrl("/sessions");
    }

    authenticate(userId, password) {
        return this.doAuthenticate({
            "mode" : "default",
            "username" : userId,
            "password" : password
        }, Error.Code.LOGIN_FAILED);
    }

    doAuthenticate( param, authErrorCode ) {
        var d = new Deferred();
        this.xhrManager.xhr(
            this.serviceUrl(), "POST", param
        ).then( function( ticket ){
            this.sessionManager.setTicket(ticket);
            d.resolve(ticket);
        }.bind(this), function(error) {
            if (error.param.httpStatusCode === 401) {
                error.code = authErrorCode;
            }
            d.reject(error);
        });
        return d;
    }

    logout() {
        var d = new Deferred();
        var ticket = this.sessionManager.getTicket();
        if (ticket) {
            this.xhrManager.xhr(
              this.serviceUrl() +"/" + ticket, "DELETE"
            ).then( function( result ){
                this.sessionManager.deleteTicket();
                d.resolve();
            }.bind(this), function(error) {
                this.sessionManager.deleteTicket();
                error.processed = true;
                d.resolve();
            }.bind(this));
        } else {
            d.resolve();
        }
        return d;
    }

}
