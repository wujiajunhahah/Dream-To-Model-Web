import http.server
import socketserver

PORT = 8080
DIRECTORY = "static"

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        super().end_headers()

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"Serving at port {PORT}")
    print(f"Visit http://localhost:{PORT}/models/bus.obj to view the model")
    httpd.serve_forever() 