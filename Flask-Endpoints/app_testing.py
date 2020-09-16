import requests

mydata = {
    'ip': '192.169.0.1'
}
create_server_try = requests.post('http://127.0.0.1:5000/make-server', data = mydata)
if not create_server_try['error'] == 'none' :
    print(create_server_try['error'])
else :
    print(create_server_try['code'])