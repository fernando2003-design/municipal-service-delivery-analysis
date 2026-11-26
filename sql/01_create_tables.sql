CREATE TABLE public.municipal_service_delivery (
    province VARCHAR(50) NOT NULL,
    district_area VARCHAR(150),
    municipality_name VARCHAR(150) NOT NULL,
    municipality_category CHAR(1) NOT NULL,
    year SMALLINT NOT NULL,
    service_type VARCHAR(30) NOT NULL,
    consumer_units BIGINT NOT NULL,
    municipality_id VARCHAR(250) NOT NULL,

    PRIMARY KEY (municipality_id, year, service_type),

    CHECK (municipality_category IN ('A', 'B', 'C')),
    CHECK (year IN (2022, 2023)),
    CHECK (service_type IN (
        'water', 'electricity', 'sanitation', 'waste'
    )),
    CHECK (consumer_units >= 0)
);