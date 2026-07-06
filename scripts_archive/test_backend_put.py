import requests

base_url = "http://127.0.0.1:8000/api/v1"
user_id = "U00014"

# 1. First, create a user if not exists or just put traveler profile with 'compras'
payload1 = {
  "presupuesto": "bajo",
  "dias_viaje": 1,
  "clima_preferido": "frio",
  "tipo_interes": "mixto",
  "intereses": ["cultura", "gastronomia", "compras"],
  "tolerancia_multitudes": "bajo"
}

print("PUT 1: Adding 'compras'")
r1 = requests.put(f"{base_url}/users/{user_id}/traveler-profile", json=payload1)
print(r1.status_code, r1.json())

# 2. Now simulate Flutter saving WITHOUT 'compras'
payload2 = {
  "presupuesto": "bajo",
  "dias_viaje": 1,
  "clima_preferido": "frio",
  "tipo_interes": "mixto",
  "intereses": ["cultura", "gastronomia"],
  "tolerancia_multitudes": "bajo"
}

print("\nPUT 2: Removing 'compras'")
r2 = requests.put(f"{base_url}/users/{user_id}/traveler-profile", json=payload2)
print(r2.status_code, r2.json())
