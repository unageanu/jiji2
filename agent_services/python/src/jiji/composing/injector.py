import inject

def config(binder):
    pass

def initialize():
    inject.configure_once(config)
