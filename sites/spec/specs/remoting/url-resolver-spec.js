import UrlResolver from "src/remoting/url-resolver"

describe("UrlResolver", () => {
  it("serviceUrlを取得できる", () => {
    const resolver = new UrlResolver();

    expect( resolver.resolveServiceUrl("test") ).toBe("/api/test");
    expect(
      resolver.resolveServiceUrl("test", {foo:"var", "aa&+あ?b":"aa&+あ?b"}
    )).toBe("/api/test?foo=var&aa%26%2B%E3%81%82%3Fb=aa%26%2B%E3%81%82%3Fb");
  });
});
