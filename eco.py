import socket
import subprocess
import psutil

def comecando_server(host="0.0.0.0", port=15000):
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    server.bind((host, port))
    
    server.listen(10)
    print(f"Servidor de eco rodando em {host}:{port}")

    calculadora = None

    while True:
        client_novo, client_ip = server.accept()
        print(f"Conexão recebida de {client_ip}")

        try:
            while True:
                data = client_novo.recv(1024)
                if not data:
                    break

                mensagem = data.decode('utf-8')
                print(f"Recebido: {mensagem}")  

                if mensagem.strip().lower() == "calc":
                    if calculadora is None:
                        print("Abrindo a calculadora")
                        calculadora = subprocess.Popen("calc")
                        print(f'Processo criado com o PID: {calculadora.pid}')
                        client_novo.sendall("Calculadora funcionando".encode('utf-8'))
                    else:
                        client_novo.sendall("Calculadora já está em execução".encode('utf-8'))
                
                elif mensagem.strip().lower() == "killcalc":
                    if calculadora:
                        print("Fechando Calculadora")
                        for proc in psutil.process_iter():
                            if proc.name() == 'CalculatorApp.exe':
                                proc.kill()
                        calculadora = None
                        client_novo.sendall("Calculadora encerrada".encode('utf-8'))
                    else: client_novo.sendall("Calculadora não está em execução".encode('utf-8'))

                else:client_novo.sendall(data)


        except Exception as e:
            print(f"Erro: {e}")

if __name__ == "__main__":
    comecando_server()
