CREATE TYPE diet_type_enum AS ENUM ('predator', 'herbivore', 'omnivore', 'benthivore', 'planktivore');
CREATE TYPE rod_action_enum AS ENUM ('extra_fast', 'fast', 'moderate', 'slow');
CREATE TYPE wind_direction_enum AS ENUM ('N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW', 'CALM');
CREATE TYPE experience_level_enum AS ENUM ('beginner', 'amateur', 'expert', 'pro');

CREATE TABLE fish_families (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE fish_genera (
    id SERIAL PRIMARY KEY,
    family_id INTEGER NOT NULL REFERENCES fish_families(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE fish_species (
    id SERIAL PRIMARY KEY,
    genus_id INTEGER NOT NULL REFERENCES fish_genera(id) ON DELETE CASCADE,
    common_name VARCHAR(255) NOT NULL,
    scientific_name VARCHAR(255),
    diet_type diet_type_enum,
    avg_weight_kg DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);