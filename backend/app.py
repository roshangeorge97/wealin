import requests
import json
import time

url = "https://api.monsterapi.ai/v1/generate/llama2-7b-chat"

payload = {
    "beam_size": 1,
    "max_length": 256,
    "repetition_penalty": 1.2,
    "temp": 0.98,
    "top_k": 40,
    "top_p": 0.9,
    "prompt": "financial strategies"
}

headers = {
    "accept": "application/json",
    "content-type": "application/json",
    "authorization": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6IjkzODdlZmJkYjYzMzM0MTMzOTU5MjM2MDFiOTY4OGE0IiwiY3JlYXRlZF9hdCI6IjIwMjQtMDItMDNUMTE6MTc6MTQuMzU4NTgwIn0.Lm53G9nnDS2kQ07ScyBrVJPjYAs7RJ4RxJ7CI62Q73M"
}

response = requests.post(url, json=payload, headers=headers)

print(response.text)

k = response.text
n = json.loads(k)
b = n.get('process_id')
b = str(b)
print(b, "----------------------")

url = "https://api.monsterapi.ai/v1/status/" + b

headers = {
    "accept": "application/json",
    "authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6IjkzODdlZmJkYjYzMzM0MTMzOTU5MjM2MDFiOTY4OGE0IiwiY3JlYXRlZF9hdCI6IjIwMjQtMDItMDNUMTE6MTc6MTQuMzU4NTgwIn0.Lm53G9nnDS2kQ07ScyBrVJPjYAs7RJ4RxJ7CI62Q73M"
}

while True:
    response1 = requests.get(url, headers=headers)
    status = json.loads(response1.text).get('status')

    if status == "COMPLETED":
        result = json.loads(response1.text).get('result')
        print(result)
        break

    time.sleep(5)  # Wait for 5 seconds before checking status again