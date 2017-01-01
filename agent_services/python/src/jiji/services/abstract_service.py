import traceback
import grpc
from jiji.model.exceptions import IllegalArgumentError, NotFoundError

class AbstractService():

    def _handle_error(self, error, context):
        self.__print_error(error)
        code, details = self.__convert_error_to_code_and_details(error)
        context.set_code(code)
        context.set_details(details)

    def __convert_error_to_code_and_details(self, error):
        if (isinstance(error, KeyError)):
            return (grpc.StatusCode.NOT_FOUND, error.args[0])
        elif (isinstance(error, NotFoundError)):
            return (grpc.StatusCode.NOT_FOUND, error.args[0])
        elif (isinstance(error, IllegalArgumentError)):
            return (grpc.StatusCode.INVALID_ARGUMENT, error.args[0])
        else:
            return (grpc.StatusCode.INTERNAL, error.args[0])

    def __print_error(self, error):
        print(error.args)
        traceback.print_exc()
