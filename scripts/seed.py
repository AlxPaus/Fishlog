import os
import sys
import psycopg2
from faker import Faker
import random

if os.environ.get("APP_ENV") == "prod":
    print("APP_ENV установлен в 'prod'. Пропускаем сидирование.")
    sys.exit(0)

multiplier = int(os.environ.get("SEED_COUNT", 1))
print(f"==> Запуск Python-сидирования (SEED_COUNT = {multiplier}) ...")

fake = Faker('ru_RU')

try:
    conn = psycopg2.connect(
        dbname=os.environ.get("POSTGRES_DB"),
        user=os.environ.get("POSTGRES_USER"),
        password=os.environ.get("POSTGRES_PASSWORD"),
        host="db",
        port=os.environ.get("POSTGRES_PORT", 5432)
    )
    conn.autocommit = True
    cursor = conn.cursor()
except Exception as e:
    print(f"Ошибка подключения к БД: {e}")
    sys.exit(1)

fish_families = [
    ('Карповые', 'Мирные пресноводные рыбы'),
    ('Окуневые', 'Стайные хищники')
]
for name, desc in fish_families:
    cursor.execute("INSERT INTO fish_families (name, description) VALUES (%s, %s) ON CONFLICT DO NOTHING;", (name, desc))

experience_levels = ['beginner', 'amateur', 'expert', 'pro']
anglers_count = 5 * multiplier

for _ in range(anglers_count):
    nickname = f"{fake.user_name()}_{random.randint(100, 999)}"
    email = fake.unique.email()
    exp = random.choice(experience_levels)
    bio = fake.text(max_nb_chars=100)
    
    cursor.execute("""
        INSERT INTO anglers (nickname, email, experience_level, bio) 
        VALUES (%s, %s, %s, %s) ON CONFLICT DO NOTHING;
    """, (nickname, email, exp, bio))

cursor.execute("SELECT id FROM regions LIMIT 1")
region_id = cursor.fetchone()
if not region_id:
    cursor.execute("INSERT INTO regions (name) VALUES ('Секретный регион') RETURNING id;")
    region_id = cursor.fetchone()[0]
else:
    region_id = region_id[0]

water_bodies_count = 10 * multiplier
water_body_names = ['Озеро', 'Пруд', 'Водохранилище', 'Залив']

for _ in range(water_bodies_count):
    name = f"{random.choice(water_body_names)} {fake.last_name().capitalize()}"
    max_depth = round(random.uniform(2.0, 30.0), 2)
    area = round(random.uniform(10.0, 1000.0), 2)
    
    cursor.execute("""
        INSERT INTO water_bodies (region_id, name, max_depth_meters, surface_area_ha) 
        VALUES (%s, %s, %s, %s) ON CONFLICT DO NOTHING;
    """, (region_id, name, max_depth, area))

print("Cидирование успешно завершено! База наполнена данными.")

cursor.close()
conn.close()