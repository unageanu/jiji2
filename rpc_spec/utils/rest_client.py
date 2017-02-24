import requests
import json

class RESTClient():

    def __init__(self):
        self.api_url = 'http://localhost:3000/api'
        self.default_headers = {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
        }

    def set_token(self, token):
        self.default_headers['Authorization'] = "X-JIJI-AUTHENTICATE " + token

    def get(self, path, query={}, headers={}):
        return requests.get(self.__build_url(path), \
            params=query, headers=self.__create_headers(headers))

    def post(self, path, body, query={},headers={}):
        return requests.post(self.__build_url(path), \
            data=json.dumps(body), params=query, \
            headers=self.__create_headers(headers))

    def put(self, path, body, query={},headers={}):
        return requests.put(self.__build_url(path), \
            data=json.dumps(body), params=query, \
            headers=self.__create_headers(headers))

    def delete(self, path, query={}, headers={}):
        return requests.delete(self.__build_url(path), \
            params=query, headers=self.__create_headers(headers))


    def __build_url(self, path):
        return self.api_url + path

    def __create_headers(self, headers):
        headers = headers.copy()
        headers.update(self.default_headers)
        return headers
