import inject

def config(binder): # pylint: disable=unused-argument
    pass

def initialize():
    inject.configure_once(config)
