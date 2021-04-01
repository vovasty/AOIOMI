from mitmproxy import ctx
from mitmproxy import flow
from mitmproxy import http

class PermzoneAddon:
    def __init__(self, host, port):
        self.host = host
        self.port = port

    def request(self, flow: http.HTTPFlow):
        flow.request.headers["X-Manual-Override"] = f'{{"hosts": {{"modular_search": {{"host": "{self.host}", "port": "{self.port}"}}}}}}'
