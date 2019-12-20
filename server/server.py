import json
import os
import sys
from logging import getLogger
from flask import Flask, request, redirect
from flask_cors import CORS, cross_origin
from settings import *
from parser import get_presenters_from_url

sys.path.append(os.pardir)
sys.path.append(os.curdir)

LOGGER = getLogger(__name__)

class ApiServer():
    def __init__(
        self,
        static_url_path,
        static_url_dir,
        host=HOST,
        port=PORT,
        reload=True
    ):
        self.reload=reload
        self.host=host
        self.port=port

        _f = Flask(__name__, static_url_path=static_url_path, static_folder=static_url_dir)

        self.app = self._init_flask(_f)

    def _init_flask(self, app):
        app.config['CORS_HEADERS'] = 'Content-Type'
        cors=CORS(app)

        LOGGER.info("Starting up flask webserver....")

        @app.route('/<path:path>')
        def _static_serve(path):
            LOGGER.info(f"Static serving..... {path}")
            return app.send_static_file(path)

        @app.route('/')
        def _serve():
            return "ok", 200

        @app.route('/getpresenters', methods=["POST"])
        @cross_origin(origins='*')
        def _getpresenters():
            ml_url = request.data
            presenter_list = get_presenters_from_url(ml_url)
            LOGGER.info(f"Processed presenters...{presenter_list}")
            presenters_json = [{"presenter": x} for x in presenter_list]
            return json.dumps(presenters_json)
        return app

    def launch_server(self):
        print(f"Launched server on: {self.host}:{self.port}")
        self.app.run(host=self.host, port=self.port, debug=True,
                           use_reloader=self.reload)


if __name__ == "__main__":
    server = ApiServer(
        static_url_path="/home",
        static_url_dir="../src"
    )
    
    server.launch_server()

