CREATE TABLE regions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE,
    country_code VARCHAR(3) DEFAULT 'RUS'
);

CREATE TABLE water_body_types (
    id SERIAL PRIMARY KEY,
    type_name VARCHAR(255)
);

CREATE TABLE water_bodies (
    id SERIAL PRIMARY KEY,
    region_id INTEGER REFERENCES regions(id) ON DELETE CASCADE,
    type_id INTEGER REFERENCES water_body_types(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    max_depth_meters DECIMAL(5,2),
    surface_area_ha DECIMAL(10,2),
    is_paid_access BOOLEAN DEFAULT FALSE,
    lat DECIMAL(9,6),
    lng DECIMAL(9,6),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
