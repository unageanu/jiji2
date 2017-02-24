import sys
import subprocess
import os

from pymongo import MongoClient

class Server():

    def start(self):
        print("start server")
        self.__initialize_db()
        self.process = subprocess.Popen(self.__args(), env=self.__env(),
            stdout=sys.stdout, stderr=sys.stderr)

    def stop(self):
        print("stop server")
        self.process.send_signal(2)

    def __initialize_db(self):
        c = MongoClient('mongodb://localhost:27017/')
        c.drop_database('jiji_test')

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
