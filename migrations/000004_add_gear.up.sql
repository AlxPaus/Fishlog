CREATE TABLE gear_manufacturers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    country VARCHAR(255)
);

CREATE TABLE gear_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE gear_items (
    id SERIAL PRIMARY KEY,
    category_id INTEGER REFERENCES gear_categories(id) ON DELETE SET NULL,
    manufacturer_id INTEGER REFERENCES gear_manufacturers(id) ON DELETE SET NULL,
    model_name VARCHAR(255) NOT NULL,
    serial_number VARCHAR(255),
    purchase_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE rod_specs (
    id SERIAL PRIMARY KEY,
    gear_item_id INTEGER UNIQUE REFERENCES gear_items(id) ON DELETE CASCADE,
    test_min_grams DECIMAL(5,2),
    test_max_grams DECIMAL(5,2),
    length_meters DECIMAL(4,2),
    action_type rod_action_enum
);

CREATE TABLE lure_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE lures (
    id SERIAL PRIMARY KEY,
    gear_item_id INTEGER UNIQUE REFERENCES gear_items(id) ON DELETE CASCADE,
    lure_type_id INTEGER REFERENCES lure_types(id) ON DELETE SET NULL,
    weight_grams DECIMAL(6,2),
    color_hex VARCHAR(7)
);
