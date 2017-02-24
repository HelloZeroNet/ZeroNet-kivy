import os, json

def loadEnv():
    env=None
    if 'ENV_JSON' in os.environ:
        with open(os.environ['ENV_JSON'], 'r') as f:
            env = json.load(f)
    else:
        with open('env.json', 'r') as f:
            env = json.load(f)
    return env
