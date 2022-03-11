from mitmproxy import ctx
from mitmproxy import flow
from mitmproxy import http
from translatoraddon.translator import Translator

class TranslatorAddon:
    def __init__(self, definitions):
        self.tr = Translator()
        self.definitions = definitions

    def response(self, flow: http.HTTPFlow):
        if flow.response.headers.get("content-type") != "application/json;charset=UTF-8":
            ctx.log.info("not a json, skipped")
            return
        url = flow.request.pretty_url.split("?")[0]
        path = self.definitions.get(url)
        if path is None:
            ctx.log.info(f"no definition, skipped {url}")
            return
        
        ctx.log.info("translating")
        translation = self.tr.translate(flow.response.content, path)
        flow.response.content = translation
