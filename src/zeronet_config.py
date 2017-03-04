import ConfigParser
import os


# Parse config file


def parseConfig(config_file):
    # Load config file
    res = dict({})
    if os.path.isfile(config_file):
        config = ConfigParser.ConfigParser(allow_no_value=True)
        config.read(config_file)
        for section in config.sections():
            for key, val in config.items(section):
                if section != "global":  # If not global prefix key with section
                    key = section + "_" + key
                resval = None
                if val:
                    if len(val.strip().split("\n")) > 1:
                        resval = []
                        for line in val.strip().split("\n"):  # Allow multi-line values
                            resval.append(line)
                    else:
                        resval = val
                res[key] = resval
    return res


def saveConfigValue(config_file, key, value):
    if not os.path.isfile(config_file):
        content = ""
    else:
        content = open(config_file).read()
    lines = content.splitlines()

    global_line_i = None
    key_line_i = None
    i = 0
    for line in lines:
        if line.strip() == "[global]":
            global_line_i = i
        if line.startswith(key + " = "):
            key_line_i = i
        i += 1

    if value is None:  # Delete line
        if key_line_i:
            del lines[key_line_i]
    else:  # Add / update
        new_line = "%s = %s" % (
            key, str(value).replace("\n", "").replace("\r", ""))
        if key_line_i:  # Already in the config, change the line
            lines[key_line_i] = new_line
        elif global_line_i is None:  # No global section yet, append to end of file
            lines.append("[global]")
            lines.append(new_line)
        else:  # Has global section, append the line after it
            lines.insert(global_line_i + 1, new_line)

    open(config_file, "w").write("\n".join(lines) + "\n")


def getConfigValue(f, key, default=None):
    c = parseConfig(f)
    if key not in c:
        return default
    return c[key]
