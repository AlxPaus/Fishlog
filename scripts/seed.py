import os
import sys
import psycopg2
from psycopg2.extras import execute_values
from faker import Faker
import random
from datetime import timedelta

if os.environ.get("APP_ENV") == "prod":
    sys.exit(0)

multiplier = int(os.environ.get("SEED_COUNT", 1000))
fake = Faker('ru_RU')

try:
    conn = psycopg2.connect(
        dbname=os.environ.get("POSTGRES_DB"),
        user=os.environ.get("POSTGRES_USER"),
        password=os.environ.get("POSTGRES_PASSWORD"),
        host="haproxy",
        port=os.environ.get("POSTGRES_PORT", 5432)
    )
    conn.autocommit = True
    cursor = conn.cursor()
except Exception as e:
    print(f"Connection error: {e}")
    sys.exit(1)

fish_families = [
    ('Карповые', 'Мирные пресноводные рыбы'),
    ('Окуневые', 'Стайные хищники'),
    ('Щуковые', 'Крупные пресноводные хищники')
]
execute_values(cursor, "INSERT INTO fish_families (name, description) VALUES %s ON CONFLICT DO NOTHING", fish_families)

cursor.execute("SELECT id FROM fish_families WHERE name = 'Щуковые' LIMIT 1")
pike_fam_id = cursor.fetchone()[0]
cursor.execute("INSERT INTO fish_genera (family_id, name) VALUES (%s, 'Esox') RETURNING id", (pike_fam_id,))
pike_gen_id = cursor.fetchone()[0]

cursor.execute("SELECT id FROM fish_families WHERE name = 'Окуневые' LIMIT 1")
perch_fam_id = cursor.fetchone()[0]
cursor.execute("INSERT INTO fish_genera (family_id, name) VALUES (%s, 'Perca') RETURNING id", (perch_fam_id,))
perch_gen_id = cursor.fetchone()[0]

cursor.execute("INSERT INTO fish_species (genus_id, common_name, scientific_name, diet_type, avg_weight_kg) VALUES (%s, 'Pike', 'Esox lucius', 'predator', 5.0) RETURNING id", (pike_gen_id,))
pike_id = cursor.fetchone()[0]

cursor.execute("INSERT INTO fish_species (genus_id, common_name, scientific_name, diet_type, avg_weight_kg) VALUES (%s, 'Perch', 'Perca fluviatilis', 'predator', 0.5) RETURNING id", (perch_gen_id,))
perch_id = cursor.fetchone()[0]

cursor.execute("INSERT INTO fish_species (genus_id, common_name, scientific_name, diet_type, avg_weight_kg) VALUES (%s, 'Zander', 'Sander lucioperca', 'predator', 2.5) RETURNING id", (perch_gen_id,))
zander_id = cursor.fetchone()[0]

other_species = [perch_id, zander_id]

regions_data = [(fake.region(), 'RUS') for _ in range(10)]
execute_values(cursor, "INSERT INTO regions (name, country_code) VALUES %s ON CONFLICT DO NOTHING", regions_data)
cursor.execute("SELECT id FROM regions")
reg_ids = [r[0] for r in cursor.fetchall()]

wb_data = []
wb_types = ['Озеро', 'Пруд', 'Водохранилище', 'Залив', 'Река']
for _ in range(10 * multiplier):
    name = f"{random.choice(wb_types)} {fake.last_name()}"
    wb_data.append((
        random.choice(reg_ids),
        name,
        round(random.uniform(2.0, 30.0), 2),
        round(random.uniform(10.0, 1000.0), 2),
        random.choice([True, False]),
        float(fake.latitude()),
        float(fake.longitude())
    ))
execute_values(cursor, "INSERT INTO water_bodies (region_id, name, max_depth_meters, surface_area_ha, is_paid_access, lat, lng) VALUES %s", wb_data)
cursor.execute("SELECT id FROM water_bodies")
wb_ids = [r[0] for r in cursor.fetchall()]

anglers_data = []
exp_levels = ['beginner', 'amateur', 'expert', 'pro']
for _ in range(5 * multiplier):
    anglers_data.append((
        f"{fake.user_name()}_{random.randint(1000, 9999)}",
        fake.unique.email(),
        random.choice(exp_levels),
        fake.text(max_nb_chars=100)
    ))
execute_values(cursor, "INSERT INTO anglers (nickname, email, experience_level, bio) VALUES %s ON CONFLICT DO NOTHING", anglers_data)
cursor.execute("SELECT id FROM anglers")
angler_ids = [r[0] for r in cursor.fetchall()]

sessions_data = []
for _ in range(20 * multiplier):
    start = fake.past_datetime(start_date="-2y")
    end = start + timedelta(hours=random.randint(2, 14))
    sessions_data.append((
        random.choice(wb_ids),
        random.choice(angler_ids),
        fake.sentence(nb_words=3)[:-1],
        start,
        end
    ))
execute_values(cursor, "INSERT INTO fishing_sessions (water_body_id, owner_id, title, start_at, end_at) VALUES %s", sessions_data)
cursor.execute("SELECT id, start_at FROM fishing_sessions")
sessions = cursor.fetchall()

catches_count = 100 * multiplier
batch_size = 10000
catches_data = []

for i in range(catches_count):
    session = random.choice(sessions)
    s_id = session[0]
    s_start = session[1]
    
    is_pike = (i % 20 == 0)
    is_trophy = (i % 100 == 0)
    
    species = pike_id if is_pike else random.choice(other_species)
    weight = random.randint(10001, 20000) if is_trophy else random.randint(100, 9999)
    
    caught_at = s_start + timedelta(minutes=random.randint(5, 300))
    is_released = random.choice([True, False])
    
    catches_data.append((
        s_id,
        species,
        random.choice(angler_ids),
        weight,
        is_released,
        caught_at
    ))
    
    if len(catches_data) >= batch_size:
        execute_values(
            cursor, 
            "INSERT INTO catches (session_id, species_id, angler_id, weight_grams, is_released, caught_at) VALUES %s", 
            catches_data
        )
        catches_data = []

if catches_data:
    execute_values(
        cursor, 
        "INSERT INTO catches (session_id, species_id, angler_id, weight_grams, is_released, caught_at) VALUES %s", 
        catches_data
    )

cursor.execute("ANALYZE catches; ANALYZE fishing_sessions; ANALYZE water_bodies; ANALYZE anglers; ANALYZE fish_species;")

cursor.close()
conn.close()