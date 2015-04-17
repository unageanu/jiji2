export default class HTTPHeaders {

    constructor(headerText) {
        this.headers = this.parseHTTPHeaderText(headerText);
    }

    parseHTTPHeaderText(headerText) {
        // see http://www.w3.org/TR/XMLHttpRequest/#the-getallresponseheaders-method
        const headerRows = headerText.split(/[\r\n]/);
        // each header line separated by a U+000D CR U+000A LF pair
        return headerRows.reduce(
          (r, f) => this.parseHeaderRow(r, f), {});
    }

    parseHeaderRow( headers, row ) {
        const separatorIndex = row.indexOf(": ");
        // each header name and header value separated by a U+003A COLON U+0020 SPACE pair
        if (separatorIndex <= 0 || row.length-2 < separatorIndex ) {
            return headers;
        }
        const field = row.substring(0, separatorIndex).trim();
        const value = row.substring(separatorIndex+2).trim();
        if (headers[field]) {
            headers[field] += ","+value;
        } else {
            headers[field] = value;
        }
        return headers;
    }

    get( field ) {
        if (!this.headers) return null;
        const normalizedHeaderName = field.toLowerCase();
        for ( let i in this.headers ) {
            if ( !this.headers.hasOwnProperty(i) ) continue;
            if ( i.toLowerCase() === normalizedHeaderName) {
                return this.headers[i];
            }
        }
        return null;
    }

}
