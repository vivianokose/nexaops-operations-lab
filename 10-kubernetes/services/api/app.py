import http.server
import json
import os

class APIHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/health':
            body = json.dumps({'status': 'healthy', 'service': 'clearops-api', 'version': '1.0.1'})
        elif self.path == '/data':
            body = json.dumps({'records': 42, 'source': 'clearops-api', 'pod': os.environ.get('HOSTNAME', 'unknown')})
        else:
            body = json.dumps({'error': 'not found'})

        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(body.encode())

    def log_message(self, *args): pass

server = http.server.HTTPServer(('0.0.0.0', 8080), APIHandler)
print('ClearOps API running on port 8080')
server.serve_forever()
