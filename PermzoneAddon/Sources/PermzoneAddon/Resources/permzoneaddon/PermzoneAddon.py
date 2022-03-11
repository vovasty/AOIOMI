from mitmproxy import flow
from mitmproxy import http

class PermzoneAddon:
    def __init__(self, headers):
        self.headers = headers

    def request(self, flow: http.HTTPFlow):
        for header, value in self.headers.items():
            flow.request.headers[header] = value
