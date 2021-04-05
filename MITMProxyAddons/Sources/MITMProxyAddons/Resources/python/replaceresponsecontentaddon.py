from mitmproxy import ctx
from mitmproxy import flow
from mitmproxy import http
import json
import re

class ReplaceResponseContentAddon:
    def __init__(self, config):
        with open(config, 'r') as file:
            data = json.load(file)
            config = []
            for key, value in data.items():
                config.append((re.compile(key), bytes(value, "utf8")))
            self.config = config
            

    def response(self, flow: http.HTTPFlow):
        url = flow.request.pretty_url
        for (regex, value) in self.config:
            matched = not regex.match(url) is None
            ctx.log.debug(f"ReplaceResponseContentAddon: {url} ~= {regex} {matched}")
            if matched:
                flow.response.content = value
