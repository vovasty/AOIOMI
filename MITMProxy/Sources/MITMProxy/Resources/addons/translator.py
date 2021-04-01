from ctypes import c_char_p, POINTER, cdll
import os
module_dirname = os.path.dirname(__file__)

translator = cdll.LoadLibrary(module_dirname + '/../lib/libTranslator.dylib')
translator.translate.argtypes = (c_char_p, POINTER(c_char_p))
translator.translate.restype = c_char_p

def CArray(arr):
    barray = list(map(lambda x: bytes(str(x), "utf8"), arr))
    carray = (c_char_p * (len(barray) + 1))()
    carray[:-1] = barray
    carray[ len(barray) ] = None
    return carray
    
    

class Translator:
    def __init__(self):
        translator.create_translator()

    def translate(self, bjson, paths):
        arr = CArray(paths)
        return translator.translate(c_char_p(bjson), arr)
