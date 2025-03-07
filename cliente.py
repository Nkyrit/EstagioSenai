import socket

def comecando_client(host="127.0.0.1", port=12345):
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    client_socket.connect((host, port))
    print(f"Conectado ao servidor {host}:{port}")

    try:
        mensagem = input('Envie uma mensagem:')
        client_socket.sendall(mensagem.encode('utf-8'))

        data = client_socket.recv(1024)
        print(f"Recebido do servidor: {data.decode('utf-8')}")

    finally:
        client_socket.close()

if __name__ == "__main__":
    comecando_client()
