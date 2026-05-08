CREATE INDEX IF NOT EXISTS idx_catches_angler_date_weight ON catches (angler_id, caught_at) INCLUDE (weight_grams);
CREATE INDEX IF NOT EXISTS idx_catches_date_desc ON catches (caught_at DESC);
CREATE INDEX IF NOT EXISTS idx_sessions_wb_fk ON fishing_sessions (water_body_id);
CREATE INDEX IF NOT EXISTS idx_wb_region_fk ON water_bodies (region_id);
CREATE INDEX IF NOT EXISTS idx_catches_weight_desc ON catches (weight_grams DESC);
CREATE INDEX IF NOT EXISTS idx_catches_species_date ON catches (species_id, caught_at DESC);
CREATE INDEX IF NOT EXISTS idx_catches_session_weight ON catches(session_id, weight_grams DESC);