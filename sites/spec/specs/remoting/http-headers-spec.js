import HTTPHeaders from "src/remoting/http-headers"

describe("HTTPHeaders", () => {
    it("解析ができる", () => {
        const headerText =
            "Date: Sun, 24 Oct 2004 04:58:38 GMT\r\n" +
            "Server: Apache/1.3.31 (Unix)\r\n" +
            "Keep-Alive: timeout=15, max=99\r\n" +
            "Connection: Keep-Alive\r\n" +
            "WWW-Authenticate: Basic realm=\"VIP Site\"\r\n" +
            "WWW-Authenticate: Negotiate\r\n" +
            "Transfer-Encoding: chunked\r\n" +
            "Content-Type: text/plain; charset=utf-8\r\n" +
            "Location: http://example.com:8080/foo/var/123?foo=var#!test";

        var headers = new HTTPHeaders(headerText);
        expect( headers.get("Location") ).toBe( "http://example.com:8080/foo/var/123?foo=var#!test" );
        expect( headers.get("location") ).toBe( "http://example.com:8080/foo/var/123?foo=var#!test" );
        expect( headers.get("LOCATION") ).toBe( "http://example.com:8080/foo/var/123?foo=var#!test" );

        expect( headers.get("Date") ).toBe("Sun, 24 Oct 2004 04:58:38 GMT");
        expect( headers.get("Server") ).toBe("Apache/1.3.31 (Unix)");
        expect( headers.get("Keep-Alive") ).toBe("timeout=15, max=99");
        expect( headers.get("Connection") ).toBe("Keep-Alive");
        expect( headers.get("WWW-Authenticate") ).toBe("Basic realm=\"VIP Site\",Negotiate");
        expect( headers.get("Transfer-Encoding") ).toBe("chunked");
        expect( headers.get("Content-Type") ).toBe("text/plain; charset=utf-8");

        expect( headers.get("NOT-FOUND") ).toBe(null);
    });
});
