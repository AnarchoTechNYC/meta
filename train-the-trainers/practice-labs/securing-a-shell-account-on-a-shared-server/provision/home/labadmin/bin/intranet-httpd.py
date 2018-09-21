#!/usr/bin/python3
#
# This is a simple Web server that loads files from users' "intranet"
# home pages, which are expected to be in `~/intranet_html`, offering 
# a semi-private Web browsing experience for users of the lab machine.

from socketserver import ForkingMixIn
from http.server import HTTPServer as BaseHTTPServer, SimpleHTTPRequestHandler
import re
import os

def list_dir(self, path):
  self.send_error(403, "Forbidden")
  return None

SimpleHTTPRequestHandler.list_directory = list_dir

class HTTPHandler(SimpleHTTPRequestHandler):
    """This handler uses server.base_path instead of always using os.getcwd()"""
    def translate_path(self, path):
        if path[0] == "/":
          if len(path) == 1:
            return os.environ["HOME"] + "/intranet_home/index.html"
          elif path[1] != "~": # Not a user ("tilde") page.
            return os.environ["HOME"] + "/intranet_home{}".format(path)
        fullpath = re.sub(r"^/~(.+?)(/.*)?$", r"/home/\g<1>/intranet_html\g<2>", path);
        return fullpath

class HTTPServer(ForkingMixIn, BaseHTTPServer):
    """
    The main server, you pass in base_path which is the path you want
    to serve requests from.
    """
    def __init__(self, base_path, server_address, RequestHandlerClass=HTTPHandler):
        self.base_path = base_path
        BaseHTTPServer.__init__(self, server_address, RequestHandlerClass)

httpd = HTTPServer(os.environ["HOME"] + "/bin/intranet-httpd.py", ("127.0.0.1", 12345))
httpd.serve_forever()
