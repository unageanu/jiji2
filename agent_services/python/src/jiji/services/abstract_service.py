import traceback
import grpc
from jiji.model.exceptions import IllegalArgumentError, NotFoundError

class AbstractService():

    def _handle_error(self, error, context):
        self._print_error(error)
        code, details = self.__extract_code_and_details(error)
        context.set_code(code)
        context.set_details(details)

    @staticmethod
    def __extract_code_and_details(error):
        if isinstance(error, KeyError):
            return (grpc.StatusCode.NOT_FOUND, error.args[0])
        elif isinstance(error, NotFoundError):
            return (grpc.StatusCode.NOT_FOUND, error.args[0])
        elif isinstance(error, IllegalArgumentError):
            return (grpc.StatusCode.INVALID_ARGUMENT, error.args[0])
        else:
            return (grpc.StatusCode.INTERNAL, error.args[0])

    @staticmethod
    def _print_error(error):
        print(error.args)
        traceback.print_exc()
