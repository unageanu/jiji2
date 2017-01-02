

class IllegalArgumentError(Exception):
    def __init__(self, message):
        super().__init__(message)
        self.message = message

    def __str__(self):
        return self.message

class NotFoundError(Exception):
    def __init__(self, message):
        super().__init__(message)
        self.message = message

    def __str__(self):
        return self.message


def illigal_argument(message):
    raise IllegalArgumentError(message)

def not_found(message):
    raise NotFoundError(message)
