CREATE TABLE catches (
    id SERIAL PRIMARY KEY,
    session_id INTEGER REFERENCES fishing_sessions(id) ON DELETE CASCADE,
    species_id INTEGER REFERENCES fish_species(id) ON DELETE CASCADE,
    lure_id INTEGER REFERENCES lures(id) ON DELETE SET NULL,
    angler_id INTEGER REFERENCES anglers(id) ON DELETE CASCADE,
    weight_grams INTEGER NOT NULL,
    length_cm DECIMAL(5,2),
    is_released BOOLEAN DEFAULT FALSE,
    caught_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE catch_photos (
    id SERIAL PRIMARY KEY,
    catch_id INTEGER REFERENCES catches(id) ON DELETE CASCADE,
    photo_url VARCHAR(255) NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE weather_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE weather_observations (
    id SERIAL PRIMARY KEY,
    session_id INTEGER REFERENCES fishing_sessions(id) ON DELETE CASCADE,
    weather_type_id INTEGER REFERENCES weather_types(id) ON DELETE SET NULL,
    air_temp_c DECIMAL(4,1),
    pressure_hpa INTEGER,
    wind_speed_ms DECIMAL(4,1),
    wind_direction wind_direction_enum,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE baits (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    is_natural BOOLEAN DEFAULT TRUE
);

CREATE TABLE groundbait_mixtures (
    id SERIAL PRIMARY KEY,
    session_id INTEGER REFERENCES fishing_sessions(id) ON DELETE CASCADE,
    recipe_name VARCHAR(255),
    total_volume_liters DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE mixture_components (
    mixture_id INTEGER REFERENCES groundbait_mixtures(id) ON DELETE CASCADE,
    bait_id INTEGER REFERENCES baits(id) ON DELETE CASCADE,
    weight_grams INTEGER,
    PRIMARY KEY (mixture_id, bait_id)
);

CREATE TABLE seasonal_bans (
    id SERIAL PRIMARY KEY,
    region_id INTEGER REFERENCES regions(id) ON DELETE CASCADE,
    species_id INTEGER REFERENCES fish_species(id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);