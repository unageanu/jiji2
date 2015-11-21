import Urls from "src/utils/urls"

describe("Urls", () => {

    it("#extractNormarizedPathName", () => {
      expect(
        Urls.extractNormarizedPathName("http://foo.com:7000/foo/var/a?a=b#aa")
      ).toEqual( "/foo/var/a" );
      expect(
        Urls.extractNormarizedPathName("https://user:pass@foo.com:7000")
      ).toEqual( "/" );
      expect(
        Urls.extractNormarizedPathName("//user:pass@foo.com:7000/1")
      ).toEqual( "/$" );
      expect(
        Urls.extractNormarizedPathName("/foo-var/A/1/a-b/2?a=b#aa")
      ).toEqual( "/foo-var/$/$/a-b/$" );
      expect(
        Urls.extractNormarizedPathName("Z")
      ).toEqual( "$" );
    });

});
