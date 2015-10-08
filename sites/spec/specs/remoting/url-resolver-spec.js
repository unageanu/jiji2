import UrlResolver from "src/remoting/url-resolver"

describe("UrlResolver", () => {
  it("serviceUrlを取得できる", () => {
    const resolver = new UrlResolver();

    expect( resolver.resolveServiceUrl("test") ).toBe("/api/test");
    expect(
      resolver.resolveServiceUrl("test", {foo:"var", "aa&+あ?b":"aa&+あ?b"}
    )).toBe("/api/test?foo=var&aa_%E3%81%82_b=aa%26%2B%E3%81%82%3Fb");

    expect(
      resolver.resolveServiceUrl("test", {foo:new Date("2015-05-01T12:01:11+0900")}
    )).toBe("/api/test?foo=2015-05-01T03%3A01%3A11.000Z");

    expect(
      resolver.resolveServiceUrl("test", {fooVarHoge:"fooVar"}
    )).toBe("/api/test?foo_var_hoge=fooVar");

  });
});
