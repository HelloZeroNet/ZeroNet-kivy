import inspect
import json
import logging
import os
import re

from os_platform import getSystemLang


class Translate(dict):

    def __init__(self, lang_dir=None, lang=None):
        if not lang_dir:
            lang_dir = os.path.join(os.path.dirname(
                os.path.abspath(__file__)), "languages")
        if not lang:
            lang = getSystemLang()
        self.lang = lang
        self.lang_dir = lang_dir
        self.setLanguage(lang)

    def setLanguage(self, lang):
        self.lang = lang
        self.lang_file = os.path.join(self.lang_dir, "%s.json" % lang)
        return self.load()

    def __repr__(self):
        return "<translate %s>" % self.lang

    def load(self):
        if os.path.isfile(self.lang_file):
            data = json.load(open(self.lang_file))
            print("Loaded translate file: %s (%s entries)" % (self.lang_file, len(data)))
            dict.__init__(self, data)
            return True
        else:
            data = {}
            dict.__init__(self, data)
            self.clear()
            print("Translate file not exists: %s" % self.lang_file)
            return False

    def format(self, s, kwargs, nested=False):
        kwargs["_"] = self
        if nested:
            return s.format(**kwargs).format(**kwargs)
        else:
            return s.format(**kwargs)

    def formatLocals(self, s, nested=False):
        kwargs = inspect.currentframe().f_back.f_locals
        return self.format(s, kwargs, nested=nested)

    def __call__(self, s):
        return self.translateString(s)

#    def __call__(self, s, kwargs=None, nested=False):
#        if kwargs:
#            return self.format(s, kwargs, nested=nested)
#        else:
#            kwargs = inspect.currentframe().f_back.f_locals
#            return self.format(s, kwargs, nested=nested)

    def __missing__(self, key):
        return key

    def pluralize(self, value, single, multi):
        if value > 1:
            return self[single].format(value)
        else:
            return self[multi].format(value)

    def translateString(self, string, translate_table=None, mode="js"):
        if not translate_table:
            translate_table = self

        if string in translate_table:
            return translate_table[string]
        else:
            return string

    def translateData(self, data, translate_table=None, mode="js"):
        if not translate_table:
            translate_table = self

        data = data.decode("utf8")

        patterns = []
        for key, val in list(translate_table.items()):
            # Problematic string: only match if called between _(" ") function
            if key.startswith("_("):
                key = key.replace("_(", "").replace(
                    ")", "").replace(", ", '", "')
                translate_table[key] = "|" + val
            patterns.append(re.escape(key))

        def replacer(match):
            target = translate_table[match.group(1)]
            if mode == "js":
                if target and target[0] == "|":  # Strict string match
                    # Only if the match if called between _(" ") function
                    if match.string[match.start() - 2] == "_":
                        return '"' + target[1:] + '"'
                    else:
                        return '"' + match.group(1) + '"'
                return '"' + target + '"'
            else:
                return match.group(0)[0] + target + match.group(0)[-1]

        if mode == "html":
            pattern = '[">](' + "|".join(patterns) + ')["<]'
        else:
            pattern = '"(' + "|".join(patterns) + ')"'
        data = re.sub(pattern, replacer, data)
        return data.encode("utf8")

translate = Translate()
