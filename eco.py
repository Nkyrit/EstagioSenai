import socket
import subprocess
import psutil

def comecando_server(host="0.0.0.0", port=15000):
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    server.bind((host, port))
    
    server.listen(10)
    print(f"Servidor de eco rodando em {host}:{port}")

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

                if mensagem.lower() == "calc":
                    print("Abrindo a calculadora")
                    subprocess.Popen("calc")
                    client_novo.sendall("Calculadora funcionando".encode('utf-8'))
                
                else:client_novo.sendall(data)


                

        except Exception as e:
            print(f"Erro: {e}")
        finally:
            print(f"Conexão encerrada com {client_ip}")
            client_novo.close()

if __name__ == "__main__":
    comecando_server()
