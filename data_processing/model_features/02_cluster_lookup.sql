-- Cluster lookup: human-readable archetypes derived from k=7 KMeans output.
-- cluster_id values are determined by KMeans with random_state=42 in
-- notebooks/04_clustering.ipynb. If the model is re-fit with different
-- features or seed, this lookup must be rebuilt from updated profiles.

DROP TABLE IF EXISTS model_cluster_lookup;
CREATE TABLE model_cluster_lookup (
    cluster_id   INTEGER PRIMARY KEY,
    cluster_name TEXT    NOT NULL,
    description  TEXT
);

INSERT INTO model_cluster_lookup (cluster_id, cluster_name, description) VALUES
    (3, 'Large urban academic medical centers',
        '~296 beds, 100% teaching, high CMI (1.94), metro. Major AMCs.'),
    (0, 'Mid-size urban community (non-teaching)',
        '~113 beds, <1% teaching, metro, average CMI. Urban community hospitals.'),
    (5, 'Urban safety-net hospitals',
        '~191 beds, 66% teaching, very high DSH (0.67), metro. DSH-supplemented urban hospitals.'),
    (6, 'Specialty metro hospitals',
        '~26 beds, very high CMI (2.95), very low DSH (0.08), metro. Likely physician-owned specialty (cardiac/surgical/orthopedic).'),
    (1, 'Micropolitan community hospitals',
        '~74 beds, micropolitan, mid CMI (1.51), 19% teaching.'),
    (2, 'Small-town community hospitals',
        '~43 beds, small-town, low CMI (1.36).'),
    (4, 'Rural community hospitals',
        '~39 beds, rural, low CMI (1.23).');