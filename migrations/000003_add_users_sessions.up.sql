CREATE TABLE anglers (
    id SERIAL PRIMARY KEY,
    nickname VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    experience_level experience_level_enum,
    bio TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE fishing_sessions (
    id SERIAL PRIMARY KEY,
    water_body_id INTEGER REFERENCES water_bodies(id) ON DELETE CASCADE,
    owner_id INTEGER REFERENCES anglers(id) ON DELETE CASCADE,
    title VARCHAR(255),
    start_at TIMESTAMP NOT NULL,
    end_at TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE session_participants (
    session_id INTEGER REFERENCES fishing_sessions(id) ON DELETE CASCADE,
    angler_id INTEGER REFERENCES anglers(id) ON DELETE CASCADE,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (session_id, angler_id)
);
