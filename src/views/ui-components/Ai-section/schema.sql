-- Table to store user symptom queries and AI responses
CREATE TABLE symptom_queries (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE, -- Assuming a `users` table exists
    query TEXT NOT NULL,
    response TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
