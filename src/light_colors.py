def format(s):
    return float("0."+str(int("0x"+s[0]+s[1],16)))

def hex(s): #converts the colors into light colors (not really how it should be done - but it works)
    return format(s[1]+s[2]),format(s[3]+s[4]),format(s[5]+s[6])
