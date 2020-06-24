from random import randrange

class HanRandom(object):
    def __init__(self):
        pass

    def ip(self):
        invalid = [10,127,169,172,192]
        first = randrange(1,256)
        while first in invalid:
            first = randrange(1,256)
        ip = ".".join([str(first), str(randrange(1, 256)), str(randrange(1, 256)), str(randrange(1, 256))])
        return ip

    def port(self):
        invalid = [8081,]
        port = randrange(1024,65536)
        while port in invalid:
            port = randrange(1024,65536)
        return str(port)

if __name__ == "__main__":
    instance = HanRandom()
    print instance.ip()
    print instance.port()


