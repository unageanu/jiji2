import sys
import subprocess
import os

class Server():

    def start(self):
        print("start server")
        self.process = subprocess.Popen(self.__args(), env=self.__env(),
            stdout=sys.stdout, stderr=sys.stderr)

    def stop(self):
        print("stop server")
        self.process.send_signal(2)

    @staticmethod
    def __args():
        return ['bundle', 'exec', 'puma', '-C', 'config/puma.rb']

    @staticmethod
    def __env():
        env = {
            'RACK_ENV': 'test',
            'PORT': '3000'
        }
        for k, v in os.environ.items():
            env[k] = v
        return env
