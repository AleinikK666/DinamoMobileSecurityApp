# server.py
import ssl
import http.server
import json
import socket
import argparse
import datetime
import random
import os

class HockeyDataHandler(http.server.BaseHTTPRequestHandler):
    
    def do_GET(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        
        if self.path == '/stocks-data.json':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            
            data = self.generate_hockey_data()
            self.wfile.write(json.dumps(data, indent=2).encode('utf-8'))
            
        elif self.path == '/cert-status':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            
            status = {
                'certificate': self.server.cert_type,
                'valid': self.server.cert_type == 'valid'
            }
            self.wfile.write(json.dumps(status).encode('utf-8'))
            
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b'Not Found')
    
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
    
    def generate_hockey_data(self):
        teams = ["ЦСКА", "СКА", "Ак Барс", "Салават Юлаев", "Локомотив", "Динамо Москва"]
        recent_games = []
        
        for i in range(5):
            date = datetime.datetime.now() - datetime.timedelta(days=i)
            
            # 30% шанс на овертайм/буллиты
            is_overtime = random.random() < 0.3
            
            if is_overtime:
                # В овертайме счет всегда с разницей в 1 шайбу
                if random.random() < 0.5:
                    # Победа в овертайме
                    goals_for = random.randint(2, 4)
                    goals_against = goals_for - 1
                    result = "ot_win"
                else:
                    # Поражение в овертайме
                    goals_against = random.randint(2, 4)
                    goals_for = goals_against - 1
                    result = "ot_loss"
            else:
                # Основное время
                goals_for = random.randint(0, 5)
                goals_against = random.randint(0, 5)
                
                if goals_for > goals_against:
                    result = "win"
                elif goals_for < goals_against:
                    result = "loss"
                else:
                    # Ничья в основное время - переносим в овертайм
                    if random.random() < 0.5:
                        goals_for = 1
                        goals_against = 0
                        result = "ot_win"
                    else:
                        goals_for = 0
                        goals_against = 1
                        result = "ot_loss"
            
            recent_games.append({
                "date": date.strftime("%Y-%m-%d"),
                "opponent": random.choice(teams),
                "goals_for": goals_for,
                "goals_against": goals_against,
                "result": result,
                "shots": random.randint(20, 40),
                "faceoffs_win_percentage": round(random.uniform(45, 65), 1),
                "penalty_minutes": random.randint(2, 12)
            })
        
        return {
            "team": "ХК Динамо Минск",
            "last_update": datetime.datetime.now().isoformat(),
            "recent_games": recent_games,
            "season_stats": {
                "games_played": 52,
                "wins": 28,
                "losses": 20,
                "draws": 4, 
                "goals_scored": 168,
                "goals_conceded": 152,
                "points": 60
            },
            "top_scorers": [
                {"name": "Вадим Шипачев", "goals": 21, "assists": 32},
                {"name": "Сэм Энас", "goals": 19, "assists": 26},
                {"name": "Роман Горбунов", "goals": 14, "assists": 21}
            ]
        }
    
    def log_message(self, format, *args):
        print(f"{datetime.datetime.now().strftime('%H:%M:%S')} - {self.path} - {args[0] if args else ''}")

class HTTPServerWithCert(http.server.HTTPServer):
    def __init__(self, server_address, RequestHandlerClass, cert_type):
        self.cert_type = cert_type
        super().__init__(server_address, RequestHandlerClass)

def run_server(port=8443, cert_type='valid'):
    cert_file = f'certs/{cert_type}_cert.pem'
    key_file = f'certs/{cert_type}_key.pem'
    
    if not os.path.exists(cert_file) or not os.path.exists(key_file):
        print(f"Ошибка: Сертификаты не найдены. Запустите generate_certs.sh")
        return
    
    server_address = ('0.0.0.0', port)
    httpd = HTTPServerWithCert(server_address, HockeyDataHandler, cert_type)
    
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    context.load_cert_chain(certfile=cert_file, keyfile=key_file)
    httpd.socket = context.wrap_socket(httpd.socket, server_side=True)
    
    hostname = socket.gethostname()
    local_ip = socket.gethostbyname(hostname)
    
    print("\n========================================")
    print("SSL PINNING SERVER ЗАПУЩЕН")
    print("========================================")
    print(f"Сертификат: {'VALID' if cert_type == 'valid' else 'INVALID'}")
    print(f"Порт: {port}")
    print(f"\nДля симулятора iOS:")
    print(f"  https://localhost:{port}/stocks-data.json")
    print(f"\nДля реального устройства (в одной сети):")
    print(f"  https://{local_ip}:{port}/stocks-data.json")
    print(f"\nСтатус SSL Pinning:")
    if cert_type == 'valid':
        print("  Приложение подключится успешно")
    else:
        print("  Приложение покажет ошибку")
    print("\nДля остановки: Ctrl+C")
    print("========================================\n")
    
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nСервер остановлен")
        httpd.server_close()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='SSL Pinning Server')
    parser.add_argument('--port', type=int, default=8443, help='Порт для сервера')
    parser.add_argument('--cert', choices=['valid', 'invalid'], default='valid', help='Тип сертификата')
    
    args = parser.parse_args()
    run_server(port=args.port, cert_type=args.cert)