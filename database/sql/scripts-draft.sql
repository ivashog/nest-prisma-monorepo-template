-- get occupation_raw list ordered by frequency
SELECT
    DISTINCT lower(occupation_raw) as occupation,
             COUNT(*) AS frequency
FROM public.candidates
GROUP BY lower(occupation_raw)
ORDER BY frequency DESC;
-- get education list ordered by frequency
SELECT
    DISTINCT lower(education) as education,
             COUNT(*) AS frequency
FROM public.candidates
GROUP BY lower(education)
ORDER BY frequency DESC;

------------------------------------------------------------
-- Join candidate party affiliation by name using pg_trgm --
------------------------------------------------------------
SELECT
    p.name AS "PartyAffiliation",
    c.party_affiliation_raw,
    c.full_name
FROM candidates c
         LEFT JOIN LATERAL (
    SELECT p.code, p.name
    FROM parties p
    ORDER BY p.name <-> c.party_affiliation_raw
    LIMIT 1
    ) p ON true
WHERE c.party_affiliation_raw NOT LIKE 'безпартійн%'
LIMIT 1000;
-- VACUUM (VERBOSE, ANALYZE) candidates;

-- create pg_trgm index for party name search
CREATE INDEX "idx_pg_trgm_party_name"
    ON parties USING gist
        (name "gist_trgm_ops");

----------------------
-- Join rads to atu --
----------------------
-- set region_id for radas
UPDATE radas r
SET region_id = (
    SELECT region_id
    FROM atu
    WHERE atu.level = 1
      AND atu.name_uk = r.region_name
)
WHERE region_id IS NULL;

-- clone Kiev for district atu level:
INSERT INTO atu (id, name_uk, name_en, koatuu, level, region_id, district_id)
    SELECT 2000 AS id, a.name_uk, a.name_en, a.koatuu,
           2::smallint as level, a.region_id,
           180000 as district_id
    FROM atu a WHERE a.koatuu = '8000000000' AND a.level = 1;
-- clone in atu_geometry
INSERT INTO atu_geometry (koatuu, level, geom)
    SELECT '8000000000' AS koatuu, 2::smallint as level, a.geom
    FROM atu_geometry a WHERE a.koatuu = '8000000000' AND a.level = 1;
-- clone Kiev for otg atu level:
INSERT INTO atu (id, name_uk, name_en, koatuu, level, region_id, district_id)
    SELECT 3000 AS id, a.name_uk, a.name_en, a.koatuu,
           3::smallint as level, a.region_id,
           180000 as district_id
    FROM atu a WHERE a.koatuu = '8000000000' AND a.level = 1;
-- clone in atu_geometry
INSERT INTO atu_geometry (koatuu, level, geom)
    SELECT '8000000000' AS koatuu, 3::smallint as level, a.geom
    FROM atu_geometry a WHERE a.koatuu = '8000000000' AND a.level = 1;

UPDATE radas
    SET region_id = 180,
        atu_level = 1,
        koatuu = '8000000000'
WHERE full_name = 'Київська міська рада';

-----------------------------
-- rada_type_id = 1 (regions)
WITH radas2atu AS (
    SELECT
        r.id AS rada_id,
        a.koatuu,
        a.district_id
    FROM radas r
        LEFT JOIN LATERAL (
            SELECT atu.koatuu, atu.name_uk, atu.district_id
            FROM atu
            WHERE atu.level = 1
                AND atu.region_id = r.region_id
            ORDER BY
                r.full_name <-> atu.name_uk
            LIMIT 1
        ) a ON true
    WHERE r.rada_type_id = 1
)
UPDATE radas r
SET atu_level = 1,
    koatuu = (
        SELECT koatuu
        FROM radas2atu r2a
        WHERE r.id = r2a.rada_id
    ),
    district_id = (
        SELECT district_id
        FROM radas2atu r2a
        WHERE r.id = r2a.rada_id
    )
WHERE r.rada_type_id = 1;
-------------------------------
-- rada_type_id = 3 (districts)
WITH radas2atu AS (
    SELECT
        r.id AS rada_id,
        a.koatuu,
        a.district_id
    FROM radas r
        LEFT JOIN LATERAL (
            SELECT atu.koatuu, atu.name_uk, atu.district_id
            FROM atu
            WHERE atu.level = 2
                AND atu.region_id = r.region_id
            ORDER BY
                r.full_name <-> atu.name_uk
            LIMIT 1
        ) a ON true
    WHERE r.rada_type_id = 3
)
UPDATE radas r
SET atu_level = 2,
    koatuu = (
        SELECT koatuu
        FROM radas2atu r2a
        WHERE r.id = r2a.rada_id
    ),
    district_id = (
        SELECT district_id
        FROM radas2atu r2a
        WHERE r.id = r2a.rada_id
    )
WHERE r.rada_type_id = 3;

-- rada_type_id = 2 (cities)
WITH radas2atu AS (
    SELECT
        r.id AS rada_id,
        a.koatuu,
        a.district_id
    FROM radas r
        LEFT JOIN LATERAL (
            SELECT atu.koatuu, atu.name_uk, atu.district_id
            FROM atu
            WHERE atu.level = 3
                AND atu.region_id = r.region_id
                AND atu.name_uk LIKE '%міська%'
            ORDER BY
                    r.full_name <-> atu.name_uk
            LIMIT 1
        ) a ON true
    WHERE r.rada_type_id = 2
)
UPDATE radas r
SET atu_level = 3,
    koatuu = (
        SELECT koatuu
        FROM radas2atu r2a
        WHERE r.id = r2a.rada_id
    ),
    district_id = (
        SELECT district_id
        FROM radas2atu r2a
        WHERE r.id = r2a.rada_id
    )
WHERE r.rada_type_id = 2
    AND r.full_name <> 'Київська міська рада';

-------------------------------
-- rada_type_id = 5 (townships)
WITH radas2atu AS (
    SELECT
        r.id AS rada_id,
        a.koatuu,
        a.district_id
    FROM radas r
        LEFT JOIN LATERAL (
            SELECT atu.koatuu, atu.name_uk, atu.district_id
            FROM atu
            WHERE atu.level = 3
                AND atu.region_id = r.region_id
            ORDER BY
                r.full_name <-> atu.name_uk
            LIMIT 1
        ) a ON true
    WHERE r.rada_type_id = 5
)
UPDATE radas r
SET atu_level = 3,
    koatuu = (
        SELECT koatuu
        FROM radas2atu r2a
        WHERE r.id = r2a.rada_id
    ),
    district_id = (
        SELECT district_id
        FROM radas2atu r2a
        WHERE r.id = r2a.rada_id
    )
WHERE r.rada_type_id = 5;

-------------------------------
-- rada_type_id = 6 (village)
WITH radas2atu AS (
    SELECT
        r.id AS rada_id,
        a.koatuu,
        a.district_id
    FROM radas r
        LEFT JOIN LATERAL (
            SELECT atu.koatuu, atu.name_uk, atu.district_id
            FROM atu
                LEFT JOIN atu a2
                    ON atu.district_id = a2.district_id AND a2.level = 2
            WHERE atu.level = 3
                AND atu.region_id = r.region_id
            ORDER BY
                concat(r.full_name, ' ', r.district_name)
                    <-> concat(atu.name_uk, ' ', a2.name_uk)
            LIMIT 1
        ) a ON true
    WHERE r.rada_type_id = 6
)
UPDATE radas r
SET atu_level = 3,
    koatuu = (
        SELECT koatuu
        FROM radas2atu r2a
        WHERE r.id = r2a.rada_id
    ),
    district_id = (
        SELECT district_id
        FROM radas2atu r2a
        WHERE r.id = r2a.rada_id
    )
WHERE r.rada_type_id = 6;

SELECT atu.koatuu, atu.name_uk, atu.district_id, a2.name_uk as district
FROM atu
    LEFT JOIN atu a2
        ON atu.district_id = a2.district_id AND a2.level = 2
WHERE atu.level = 3
  AND atu.region_id = 135
ORDER BY
    'Олександрівська селищна рада -' <-> concat(atu.name_uk, ' ', a2.name_uk)

SELECT
    r.id AS rada_id,
       r.full_name,
    a.koatuu,
    a.district_id
FROM radas r
         LEFT JOIN LATERAL (
    SELECT atu.koatuu, atu.name_uk, atu.district_id
    FROM atu
             LEFT JOIN atu a2
                       ON atu.district_id = a2.district_id
                           AND a2.level = 2
    WHERE atu.level = 3
      AND atu.region_id = r.region_id
    ORDER BY
            concat(r.full_name, ' ', r.district_name)
            <-> concat(atu.name_uk, ' ', a2.name_uk)
    LIMIT 1
    ) a ON true
WHERE r.rada_type_id = 5 AND r.region_id = 135
-------------------------------
-- rada_type_id = 4 (city_district)
WITH radas2atu AS (
    SELECT
        r.id AS rada_id,
        a.koatuu,
        a.district_id
    FROM radas r
        LEFT JOIN LATERAL (
            SELECT atu.koatuu, atu.name_uk, atu.district_id
            FROM atu
            WHERE atu.level = 5
                AND atu.region_id = r.region_id
            ORDER BY
                r.full_name <-> atu.name_uk
            LIMIT 1
        ) a ON true
    WHERE r.rada_type_id = 4
)
UPDATE radas r
SET atu_level = 5,
    koatuu = (
        SELECT koatuu
        FROM radas2atu r2a
        WHERE r.id = r2a.rada_id
    ),
    district_id = (
        SELECT district_id
        FROM radas2atu r2a
        WHERE r.id = r2a.rada_id
    )
WHERE r.rada_type_id = 4;


-- age groups:
SELECT
    c.full_name,
    c.age,
    a.name AS age_group
FROM public.candidates c
    LEFT JOIN age_ranges_dict a
        ON a.range @> c.age::int;
-- update
WITH age_ranges AS (
    SELECT c.id AS candidate_id,
           a.id AS age_range_id
    FROM public.candidates c
        LEFT JOIN age_ranges_dict a
            ON a.range @> c.age::int
)
UPDATE candidates
SET age_range_id = (
    SELECT age_range_id
    FROM age_ranges
    WHERE age_ranges.candidate_id = candidates.id
)
WHERE age_range_id IS NULL;

-- education:
SELECT
    c.full_name,
    c.education AS education_raw,
    e.name AS education
FROM public.candidates c
    LEFT JOIN educations_dict e
        ON c.education = ANY(e.keys);
-- update
WITH education AS (
    SELECT c.id AS candidate_id,
           e.id AS education_id
    FROM candidates c
        LEFT JOIN educations_dict e
            ON c.education_raw = ANY(e.keys)
)
UPDATE candidates
SET education_id = (
    SELECT education_id
    FROM education
    WHERE education.candidate_id = candidates.id
)
WHERE education_id IS NULL;

-- occupation:
WITH flat_occupations_dict AS (
    SELECT
        id,
        name,
        ranking,
        unnest(keys) AS key
    FROM occupations_dict
    ORDER BY ranking
)
SELECT
    c.full_name,
    c.occupation_raw,
    o.name AS occupation,
    o.ranking
FROM public.candidates c
LEFT JOIN LATERAL (
        SELECT
            id,
            name,
            ranking
        FROM flat_occupations_dict
        WHERE c.occupation_raw ILIKE concat('%', key, '%')  --c.occupation_raw
        ORDER BY ranking
        LIMIT 1
    ) o ON true;
-- update:
WITH flat_occupations_dict AS (
    SELECT id,
           ranking,
           unnest(keys) AS key
    FROM occupations_dict
    ORDER BY ranking
), occupations AS (
    SELECT c.id AS candidate_id,
           o.id AS occupation_id
    FROM public.candidates c
             LEFT JOIN LATERAL (
        SELECT id
        FROM flat_occupations_dict
        WHERE c.occupation_raw ILIKE concat('%', key, '%')
        ORDER BY ranking
        LIMIT 1
        ) o ON true
)
UPDATE candidates
SET occupation_id = (
    SELECT occupation_id
    FROM occupations
    WHERE occupations.candidate_id = candidates.id
)
WHERE occupation_id IS NULL;

UPDATE candidates
SET occupation_id = 16
WHERE occupation_id IS NULL;

-- 1.1 Find same name otg radas
WITH namesakes AS (
    SELECT
        name_uk,
        array_agg(koatuu) AS koatuus,
        count(*) AS count
    FROM atu a
    WHERE level = 3
    GROUP BY name_uk
    HAVING count(*) > 1
    ORDER BY count DESC
)
SELECT
    r.id                AS rada_id,
    r.full_name         AS rada_name,
    namesakes.name_uk   AS atu_name,
    namesakes.count     AS namesakes_count
FROM radas r,
     namesakes
WHERE r.atu_level = 3
    AND r.koatuu = ANY(namesakes.koatuus);

-- 1.2 find candidates from same name otg radas
WITH namesakes AS (
    SELECT
        name_uk,
        array_agg(koatuu) AS koatuus,
        count(*) AS count
    FROM atu a
    WHERE level = 3
    GROUP BY name_uk
    HAVING count(*) > 1
    ORDER BY count DESC
)
SELECT
    count(c.id)
FROM candidates c
     LEFT JOIN radas r
         ON r.id = c.rada_id,
     namesakes
WHERE r.atu_level = 3
  AND r.koatuu = ANY(namesakes.koatuus);

-- 1.3 Delete candidates from same name otg radas
WITH namesakes AS (
    SELECT
        name_uk,
        array_agg(koatuu) AS koatuus,
        count(*) AS count
    FROM atu a
    WHERE level = 3
    GROUP BY name_uk
    HAVING count(*) > 1
    ORDER BY count DESC
)
DELETE FROM candidates c
WHERE c.rada_id IN (
        SELECT r.id AS namesakes_rada_id
        FROM radas r,
             namesakes
        WHERE r.atu_level = 3
          AND r.koatuu = ANY(namesakes.koatuus)
    );

-- 1.4 Set atu fk values to NULL for same name otg radas
WITH namesakes AS (
    SELECT
        name_uk,
        array_agg(koatuu) AS koatuus,
        count(*) AS count
    FROM atu a
    WHERE level = 3
    GROUP BY name_uk
    HAVING count(*) > 1
    ORDER BY count DESC
)
UPDATE radas
    SET koatuu = NULL,
        atu_level = NULL,
        district_id = NULL
WHERE id IN (
    SELECT r.id AS namesakes_rada_id
    FROM radas r,
         namesakes
    WHERE r.atu_level = 3
      AND r.koatuu = ANY(namesakes.koatuus)
);

-- agg centroids for atu geom
ALTER TABLE public.atu_geometry
    ADD COLUMN centroid numeric(6,4)[];

UPDATE atu_geometry ag
SET centroid =  c.center
FROM (
    SELECT
        koatuu,
        level,
        ARRAY[
            round(st_x(st_centroid(geom))::numeric, 4),
            round(st_y(st_centroid(geom))::numeric, 4)
        ]::numeric(6,4)[] AS center
    FROM atu_geometry
) AS c
WHERE ag.koatuu = c.koatuu
  AND ag.level = c.level;


-- fill party results table
ALTER SEQUENCE parties_results_id_seq RESTART WITH 1;
INSERT INTO parties_results (party_code, rada_id, elections_type, candidates)
    SELECT
        c.party_code,
        c.rada_id,
        c.elections_type,
        count(*) AS candidates
    FROM candidates c
    GROUP BY c.party_code,
             c.rada_id,
             c.elections_type
    ORDER BY c.rada_id,
             c.elections_type,
             candidates DESC
ON CONFLICT (party_code, rada_id, elections_type)
    DO UPDATE SET candidates = excluded.candidates;

-- get region atu overview
SELECT
    string_agg(a.name_uk::text, '') FILTER ( WHERE a.level = 1 )  AS regiomName,
    count(*) FILTER ( WHERE a.level = 2 )               AS districts,
    count(*) FILTER ( WHERE a.level = 3 )               AS communites
FROM atu a
WHERE a.region_id = 132;

-- calc parties ranking by election type
SELECT
    p.code                      AS code,
    p.short_name                AS name,
    count(*)                    AS candidates,
    DENSE_RANK() OVER (
        ORDER BY count(*) DESC
    )                           AS ranking
FROM candidates c
    LEFT JOIN parties p ON c.party_code = p.code
    LEFT JOIN radas r ON c.rada_id = r.id
WHERE r.atu_level = 3 AND c.elections_type = 'DEPUTY'
GROUP BY p.code, p.short_name;

-- extract party name
SELECT
    code                                                     AS party_code,
    name                                                     AS original_name,
    UPPER(
        COALESCE(
            substring(name, '[""|«|"|”](.*)[""|»|"|”]'),
            name
        )
    ) 														AS extracted_name
FROM parties
WHERE ranking IS NOT NULL
ORDER BY ranking;

-- 'https://docs.google.com/spreadsheets/d/12bZF80z-FJmN_KFaGZ7uGoCwBYGbLKm4P0tCRKuwqwY/gviz/tq?tqx=out:csv&sheet=PIVOT_party_result_csv'
SELECT region_id FROM atu WHERE level = 1 ORDER BY  region_id


-- update party color
UPDATE parties p
SET color = data.color
FROM (
    VALUES
         (52, '#D63D62'),
         (338, '#008D26'),
         (247, '#E45C00'),
         (364, '#76BDE3'),
         (65, '#F7D100'),
         (356, '#F28959'),
         (136, '#8254C7'),
         (293, '#3C5C72'),
         (177, '#016DB5'),
         (56, '#1A4694'),
         (234, '#225EAC'),
         (169, '#CE362D'),
         (359, '#017146'),
         (269, '#E7BF32'),
         (22, '#FC9F32'),
         (351, '#36AD47'),
         (97, '#B75B5B'),
         (237, '#18A0DB'),
         (9, '#499DBF'),
         (93, '#5DB885'),
         (-1, '#60C5C5')
) AS data (party_code, color)
WHERE p.code = data.party_code;

-- delete same name candidates
WITH samecandidates AS (
    SELECT
        r.full_name								AS rada_name,
        r.region_name							AS region_name,
        array_agg(c.id ORDER BY c.id)			AS candidate_ids,
        array_agg(c.full_name ORDER BY c.id) 	AS names,
        count(*)								AS count
    FROM candidates c
             LEFT JOIN radas r ON c.rada_id = r.id
    GROUP BY
        r.full_name,
        r.region_name,
        c.date_of_birth,
        c.rada_id,
        c.party_code,
        c.occupation_id,
        c.tvo_number,
        c.tvo_rank,
        c.single_list_rank
    HAVING count(*) > 1
    ORDER BY count DESC
)
DELETE FROM candidates
WHERE id IN (
    SELECT candidate_ids[1]
    FROM samecandidates
);

-- update parties results
UPDATE parties_results pr
SET candidates = results.candidates,
    votes_cvk = results.votes_cvk,
    mandates_cvk = results.mandates_cvk
FROM (
    SELECT
        c.party_code,
        c.rada_id,
        count(*)                            AS candidates,
        sum(c.votes) FILTER (
            WHERE c.is_elected = true
            AND c.elections_type = 'MAYOR'
        )                                   AS votes_cvk,
        count(c.id) FILTER (
            WHERE c.is_elected = true
            AND c.elections_type = 'MAYOR'
        )                                   AS mandates_cvk
    FROM candidates c
        LEFT JOIN parties p ON c.party_code = p.code
    WHERE c.elections_type = 'MAYOR' AND c.rada_id = 77
    GROUP BY c.party_code,
             c.rada_id
    ORDER BY votes_cvk DESC NULLS LAST
) AS results
WHERE pr.party_code = results.party_code
  AND pr.rada_id = results.rada_id
  AND pr.elections_type = 'MAYOR';

-- SELECT
--     r.full_name,
--     sum(pr.mandates_cvk)
-- FROM parties_results pr
--     LEFT JOIN radas r on pr.rada_id = r.id
-- WHERE r.atu_level = 1
--     AND pr.mandates_cvk IS NOT NULL
-- GROUP BY r.full_name;

-- update district for 22 mandates radas
UPDATE radas r
SET district_name = atu_district.name
FROM (
    SELECT
        r.id,
        r.full_name,
        a.name_uk AS name
    FROM radas r
        LEFT JOIN atu a
            ON r.district_id = a.district_id AND a.level = 2
) AS atu_district
WHERE r.district_name = '-'
    AND r.id = atu_district.id;
-- reverse
UPDATE radas r
SET district_name = '-'
WHERE r.mandates > 22;


SELECT
    r.id                                                AS id,
    r.full_name                                         AS "fullName",
    r.region_name                                       AS "regionName",
    coalesce(nullif(r.district_name, '-'), ad.name_uk)  AS "districtName"
FROM radas r
    LEFT JOIN atu ad ON r.district_id = ad.district_id AND ad.level = 2
WHERE r.full_name = 'Ратнівська селищна рада'
    AND r.region_name = 'Волинська область'
    AND (r.district_name = 'Ковельський район'
            OR ad.name_uk = 'Ковельський район');

-- UPDATE atu
-- SET name_uk = replace(name_uk, '’', '''');
--
-- UPDATE radas
-- SET district_name = replace(district_name, '’', '''');

-- aggregate district turnout data
UPDATE radas r
SET voters = data.voters,
    participated_total = data.participated_total,
    participated_ps = data.participated_ps,
    invalid_ballots = data.invalid_ballots
FROM (
         SELECT
             district_id,
             sum(voters),
             sum(participated_total),
             sum(participated_ps),
             sum(invalid_ballots)
         FROM radas r
         WHERE r.atu_level = 3
         GROUP BY district_id
     ) AS data (district_id, voters, participated_total, participated_ps, invalid_ballots)
WHERE r.district_id = data.district_id AND r.atu_level = 2;
-- aggregate region turnout data
UPDATE radas r
SET voters = data.voters,
    participated_total = data.participated_total,
    participated_ps = data.participated_ps,
    invalid_ballots = data.invalid_ballots
FROM (
         SELECT
             region_id,
             sum(voters),
             sum(participated_total),
             sum(participated_ps),
             sum(invalid_ballots)
         FROM radas r
         WHERE r.atu_level = 3
         GROUP BY region_id
     ) AS data (region_id, voters, participated_total, participated_ps, invalid_ballots)
WHERE r.region_id = data.region_id AND r.atu_level = 1;
