import requests
from utils.rest_client import RESTClient

class AgentRegister():

    SOURCE_01 = """
from jiji.model.agent import Agent

class TestAgent(Agent):

    def __init__(self):
        self.log = []

    def post_create(self):
        self.log.append("post_create")

    def set_properties(self, properties):
        self.log.append("set_properties")
        self.properties = properties

    def save_state(self):
        self.log.append("save_state")

    def restore_state(self, state):
        self.log.append("restore_state")
        self.state = state

    """

    def __init__(self):
        self.client = RESTClient()

    def initialize(self):
        r = self.client.put('/settings/initialization/mailaddress-and-password', body={
            "mail_address": 'foo@var.com',
            "password":     'test'
        })
        data = r.json()
        self.client.set_token(data['token'])

    def register_agent_source(self):
        r = self.client.post('/agents/sources', {
          'name':     'test_agent',
          'memo':     'メモ1',
          'type':     'agent',
          'language': 'python',
          'body':     self.SOURCE_01
        })

    def register_agent(self):
        r = self.client.post('/agents/sources', {
          'name':     'test_agent',
          'memo':     'メモ1',
          'type':     'agent',
          'language': 'python',
          'body':     self.SOURCE_01
        })
