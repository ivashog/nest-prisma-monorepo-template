-- aggregate candidates query
WITH sub AS (
    SELECT
        r.id AS koatuu,
        r.full_name AS name,
        count(*) AS count
    FROM candidates c
        LEFT JOIN radas r ON c.rada_id = r.id
    WHERE  rada_id <= 22
    GROUP BY rada_id, r.id
)
SELECT
    koatuu, name, count,
    round(count/SUM(count) OVER () * 100, 3) AS percent,
    round(count/AVG(count) OVER (), 3) AS deviation
FROM sub;

-- aggLevel = REGIONAL
SELECT
    a.koatuu,
    a.name_uk AS name,
    count(*) AS count
FROM candidates c
    LEFT JOIN radas r ON c.rada_id = r.id
    LEFT JOIN atu a ON r.region_id = a.region_id AND a.level = 1 -- REGIONAL
WHERE 1=1
--   AND r.atu_level = 1
GROUP BY a.koatuu,
         a.name_uk
ORDER BY koatuu;

-- aggLevel = DISTRICTS
SELECT
    a.koatuu,
    a.name_uk AS name,
    count(*) AS count
FROM candidates c
     LEFT JOIN radas r ON c.rada_id = r.id
--      LEFT JOIN atu a ON r.region_id = a.region_id AND a.level = 1 -- REGIONAL
     LEFT JOIN atu a ON r.district_id = a.district_id AND a.level = 2 -- DISTRICTS

WHERE 1=1
    AND r.atu_level = 2
GROUP BY a.koatuu,
         a.name_uk
ORDER BY count DESC;

-- aggLevel = COMMUNITIES
SELECT
    a.koatuu,
    a.name_uk AS name,
    count(*) AS count
FROM candidates c
         LEFT JOIN radas r ON c.rada_id = r.id
--          LEFT JOIN atu a ON r.region_id = a.region_id AND a.level = 1 -- REGIONAL
--          LEFT JOIN atu a ON r.district_id = a.district_id AND a.level = 2 -- DISTRICTS
         LEFT JOIN atu a ON r.koatuu = a.koatuu AND a.level = 3 -- COMMUNITIES
WHERE 1=1
  AND r.atu_level = 3
GROUP BY a.koatuu,
         a.name_uk
ORDER BY count DESC;

-- aggLevel = CITY_DISTRICTS
SELECT
    a.koatuu,
    a.name_uk AS name,
    count(*) AS count
FROM candidates c
         LEFT JOIN radas r ON c.rada_id = r.id
        LEFT JOIN atu a ON left(r.koatuu, 5) = left(a.koatuu, 5) AND a.level = 3 -- COMMUNITIES (CITY)
--          LEFT JOIN atu a ON r.koatuu = a.koatuu AND a.level = 5 -- CITY_DISTRICTS
WHERE 1=1
  AND r.atu_level = 5
GROUP BY a.koatuu,
         a.name_uk
ORDER BY count DESC;

-- cte for percent and deviation calculation
WITH basis AS (
    SELECT
        count(*) FILTER (WHERE 1=1)::numeric                 AS count_base,
        count(*) FILTER (WHERE c.party_code = 351)::numeric  AS count
    FROM candidates c
        LEFT JOIN radas r ON c.rada_id = r.id
    WHERE 1=1 AND c.elections_type = 'DEPUTY' AND r.atu_level = 1
        AND (c.elections_type = 'DEPUTY' AND r.atu_level = 1)
       OR  (c.elections_type = 'DEPUTY' AND r.koatuu = '8000000000')
),
main AS (
    SELECT
        a.koatuu                                             AS koatuu,
        a.name_uk                                            AS name,
        ag.centroid                                          AS centroid,
        count(*) FILTER (WHERE 1=1)::numeric                 AS count_base,
        count(*) FILTER (WHERE c.party_code = 351)::numeric  AS count
    FROM candidates c
        LEFT JOIN radas r ON c.rada_id = r.id
        LEFT JOIN atu a ON r.region_id = a.region_id AND a.level = 1 -- REGIONAL
        LEFT JOIN atu_geometry ag on a.koatuu = ag.koatuu and a.level = ag.level
    WHERE 1=1 AND c.elections_type = 'DEPUTY' AND r.atu_level = 1
        AND (c.elections_type = 'DEPUTY' AND r.atu_level = 1)
        OR  (c.elections_type = 'DEPUTY' AND r.koatuu = '8000000000')
    GROUP BY a.koatuu,
             a.name_uk,
             ag.centroid
    ORDER BY a.koatuu
)
SELECT
    m.koatuu,
    m.name,
    m.count,
    m.centroid,
    round((m.count / NULLIF(m.count_base, 0)) * 100, 2)     				                    AS percent,
    round(((m.count / NULLIF(m.count_base, 0)) - (b.count / NULLIF(b.count_base, 0))) * 100, 2) AS deviation
FROM main m,
     basis b;

-- find same name candidates
SELECT
    concat(split_part(full_name, ' ', 1), ' ', split_part(full_name, ' ', 2)) AS name,
    rada_id,
    tvo_number,
    count(*) AS count
FROM candidates c
GROUP BY name, rada_id, tvo_number
ORDER BY count DESC;

-- find hottest radas
SELECT
    r.full_name AS name,
    count(DISTINCT c.party_code) AS count
FROM candidates c
    LEFT JOIN radas r on c.rada_id = r.id
WHERE r.atu_level = 3 AND r.rada_type_id = 2
GROUP BY name
ORDER BY count DESC;

-- competition: mandates
SELECT
    r.full_name,
    sum(r.mandates) / count(r.full_name)
FROM candidates c
    LEFT JOIN radas r on c.rada_id = r.id
WHERE r.atu_level = 3
GROUP BY r.full_name;

-- competition: candidates-per-mandate
SELECT
    r.koatuu                                                                            AS koatuu,
    r.full_name                                                                         AS name,
    round(count(c.id)::numeric / (sum(r.mandates) / count(r.full_name))::numeric, 2)    AS value
FROM candidates c
    LEFT JOIN radas r on c.rada_id = r.id
WHERE r.atu_level = 3
GROUP BY r.koatuu, r.full_name
ORDER BY value DESC;

-- competition: parties
SELECT
    r.koatuu                        AS koatuu,
    r.full_name                     AS name,
    count(DISTINCT c.party_code)    AS value
FROM candidates c
    LEFT JOIN radas r on c.rada_id = r.id
WHERE r.atu_level = 3
GROUP BY r.koatuu, r.full_name
ORDER BY value DESC;

-- competition: all
SELECT
    r.koatuu                                                                            AS koatuu,
    r.full_name                                                                         AS name,
    sum(r.mandates) / count(r.full_name)                                                AS mandates,
    round(count(c.id)::numeric / (sum(r.mandates) / count(r.full_name))::numeric, 2)    AS candidates_per_mandate,
    count(DISTINCT c.party_code)                                                        AS parties
FROM candidates c
         LEFT JOIN radas r on c.rada_id = r.id
WHERE r.atu_level = 1
GROUP BY r.koatuu, r.full_name
ORDER BY r.koatuu;

-- party coverage
SELECT
    r.koatuu                                                  AS koatuu,
    r.full_name                                               AS name,
    round((count(*)::numeric / r.mandates::numeric) * 100, 2) AS value
FROM candidates c
     LEFT JOIN radas r ON c.rada_id = r.id
     LEFT JOIN parties p ON c.party_code = p.code
WHERE 1=1
  AND r.atu_level = 3
  AND c.party_code = 351
GROUP BY  r.koatuu, r.full_name, r.mandates
ORDER BY value DESC;

-- party ranking by atu_level
SELECT p.code AS party_code,
       p.short_name AS party_name,
       DENSE_RANK() OVER (
           ORDER BY count(*) DESC
           )     ranking
FROM candidates c
    LEFT JOIN parties p ON c.party_code = p.code
    LEFT JOIN radas r ON c.rada_id = r.id
WHERE r.atu_level = 1
GROUP BY p.code, p.short_name;

-- radas ranking by parties count
SELECT p.code AS party_code,
       p.short_name AS party_name,
       count(DISTINCT r.id) AS radas
FROM candidates c
    LEFT JOIN parties p ON c.party_code = p.code
    LEFT JOIN radas r ON c.rada_id = r.id
WHERE r.atu_level = 1
GROUP BY p.code, p.short_name
ORDER BY radas DESC;

-- party compare
SELECT
    r.koatuu                                            AS koatuu,
    r.full_name                                         AS name,
    count(c.id) FILTER (WHERE c.party_code = 351)
       - count(c.id) FILTER (WHERE c.party_code = 52)   AS value
FROM candidates c
    LEFT JOIN radas r ON c.rada_id = r.id
WHERE r.atu_level = 2
GROUP BY r.koatuu, r.full_name
ORDER BY value DESC;

-- calc candidates by radas types
SELECT
    rtd.name,
    c.elections_type,
    count(c.id) AS candidates
FROM candidates c
    LEFT JOIN radas r ON c.rada_id = r.id
    LEFT JOIN rada_types_dict rtd on r.rada_type_id = rtd.id
--WHERE c.elections_type <> 'DEPUTY'
GROUP BY c.elections_type, rtd.name, rtd.id
ORDER BY rtd.id;

-- calc mandates by radas types
SELECT
    rtd.name,
    sum(r.mandates) AS mandates
FROM radas r
    LEFT JOIN rada_types_dict rtd on r.rada_type_id = rtd.id
GROUP BY rtd.name, rtd.id
ORDER BY rtd.id;

-- find same name candidates
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
ORDER BY count DESC;


-- parties-ranking by elections results
WITH c AS (
    SELECT
        count(DISTINCT pr.rada_id)  AS "coverageTotal",
        sum(pr.mandates_cvk)        AS "mandatesTotal"
    FROM parties_results pr
        LEFT JOIN radas r ON r.id = pr.rada_id
    WHERE 1=1 AND pr.mandates_cvk > 0
      AND pr.elections_type = 'DEPUTY'
      AND r.atu_level = 3
      --AND r.region_id = 171
), q AS (
    SELECT
        json_build_object(
            'partyName', p.short_name,
            'color', p.color,
            'count', sum(pr.mandates_cvk),
            'total', max(c."mandatesTotal"),
            'percent', round(
                sum(pr.mandates_cvk)::numeric
                    / max(c."mandatesTotal")::numeric * 100,
                2)
        ) AS "byCount",
        json_build_object(
            'partyName', p.short_name,
            'color', p.color,
            'count', count(DISTINCT pr.rada_id),
            'total', max(c."coverageTotal"),
            'percent', round(
                count(DISTINCT pr.rada_id)::numeric
                    / max(c."coverageTotal")::numeric * 100,
                2)
        ) AS "byCover"
    FROM c, parties_results pr
        LEFT JOIN radas r ON r.id = pr.rada_id
        LEFT JOIN parties p ON p.code = pr.party_code
    WHERE 1=1 AND pr.mandates_cvk > 0
        AND pr.elections_type = 'DEPUTY'
        AND r.atu_level = 3
        --AND r.region_id = 171
    GROUP BY p.short_name, p.color
    ORDER BY sum(pr.mandates_cvk) DESC
)
SELECT
    json_build_object(
        'byCount', array_agg(q."byCount" ORDER BY (q."byCount"->>'percent')::numeric DESC),
        'byCover', array_agg(q."byCover" ORDER BY (q."byCover"->>'percent')::numeric DESC)
    ) AS data
FROM q;

CREATE OR REPLACE VIEW elections_results_overview AS
    WITH r_results AS (
        SELECT
            r.atu_level                                                                             AS atu_level,
            pr.elections_type                                                                       AS elections_type,
            r.region_id                                                                             AS region_id,
            count(DISTINCT pr.rada_id)  FILTER (WHERE  pr.mandates_cvk IS NOT NULL)::int            AS radas,
            coalesce(sum(pr.mandates_cvk) FILTER (WHERE  pr.mandates_cvk IS NOT NULL), 0)::int      AS mandates,
            count(DISTINCT pr.party_code) FILTER (WHERE  pr.mandates_cvk IS NOT NULL)::int          AS parties
        FROM radas r
            INNER JOIN parties_results pr
                ON r.id = pr.rada_id
        GROUP BY r.atu_level,
                 pr.elections_type,
                 r.region_id
    ), r_parties AS (
        SELECT
            r.atu_level,
            c.elections_type,
            r.region_id,
            count(DISTINCT c.party_code)::int AS total_parties
        FROM candidates c
            LEFT JOIN radas r ON r.id = c.rada_id
            LEFT JOIN parties p ON p.code  = c.party_code
        GROUP BY r.atu_level,
                 c.elections_type,
                 r.region_id
    ), r_mandates AS (
        SELECT
            r.atu_level                     AS atu_level,
            'DEPUTY'::elections_type        AS elections_type,
            r.region_id                     AS region_id,
            count(DISTINCT r.id)::int       AS total_radas,
            sum(r.mandates)::int            AS total_mandates
        FROM radas r
        GROUP BY r.atu_level, r.region_id
        UNION ALL
        SELECT
            r.atu_level                     AS atu_level,
            'MAYOR'::elections_type         AS elections_type,
            r.region_id                     AS region_id,
            count(DISTINCT r.id)::int       AS total_radas,
            count(DISTINCT r.id)::int       AS total_mandates
        FROM radas r WHERE r.atu_level = 3
        GROUP BY r.atu_level, r.region_id
    )
    SELECT
        rr.*,
        rp.total_parties,
        rm.total_radas,
        rm.total_mandates,
        round(rr.radas::numeric / rm.total_radas::numeric * 100, 2)         AS elected_radas_perc,
        round(rr.mandates::numeric / rm.total_mandates::numeric * 100, 2)   AS elected_mandates_perc,
        round(rr.parties::numeric / rp.total_parties::numeric * 100, 2)     AS elected_parties_perc
    FROM r_results rr
        LEFT JOIN r_parties rp
           ON rp.elections_type = rr.elections_type
               AND rp.atu_level = rr.atu_level
               AND rp.region_id = rr.region_id
        LEFT JOIN r_mandates rm
           ON rm.elections_type = rr.elections_type
               AND rm.atu_level = rr.atu_level
               AND rm.region_id = rr.region_id;
-- select elections overview
SELECT
    json_build_object(
        'count', sum(ro.radas),
        'total', sum(ro.total_radas),
        'percent', round(
            sum(ro.radas)::numeric
                / sum(ro.total_radas)::numcleeric * 100,
            2)
    )                               AS radas,
    json_build_object(
        'count', sum(ro.mandates),
        'total', sum(ro.total_mandates),
        'percent', round(
            sum(ro.mandates)::numeric
                / sum(ro.total_mandates)::numeric * 100,
            2)
    )                               AS mandates,
    json_build_object(
        'count', sum(ro.parties),
        'total', sum(ro.total_parties),
        'percent', round(
           sum(ro.parties)::numeric
                / sum(ro.total_parties)::numeric * 100,
            2)
    )                               AS parties
FROM elections_results_overview ro
WHERE atu_level = 2 AND elections_type = 'DEPUTY' AND region_id = 105;

-- rada winners
SELECT
    DISTINCT ON (r.koatuu) r.full_name          AS name,
    r.koatuu                                    AS koatuu,
    first_value(
        CASE WHEN pr.mandates IS NOT NULL
        THEN pr.party_code ELSE NULL END
    ) OVER rada_window                          AS party_winner,
    max(pr.mandates) OVER rada_window           AS mandates,
    max(r.mandates)  OVER rada_window           AS mandates_total,
    round(
        max(pr.mandates) OVER rada_window::numeric
            / max(r.mandates) OVER rada_window::numeric * 100,
        2
    )                                           AS mandates_percent
FROM radas r
    LEFT JOIN parties_results pr ON pr.rada_id = r.id
    LEFT JOIN parties p ON p.code = pr.party_code
WHERE 1=1
    AND pr.elections_type = 'DEPUTY'
    AND r.atu_level = 3
WINDOW rada_window AS  (
    PARTITION BY pr.rada_id
    ORDER BY pr.mandates DESC NULLS LAST
)
ORDER BY r.koatuu;

-- rada winners view
CREATE MATERIALIZED VIEW rada_winners_view AS
    WITH rada_winners AS (
        SELECT
            DISTINCT pr.rada_id                                 AS rada_id,
            pr.elections_type                                   AS elections_type,
            r.atu_level                                         AS atu_level,
            (CASE
              WHEN pr.elections_type = 'DEPUTY'
                  THEN max(r.mandates)  OVER rada_window
              ELSE 1
            END)                                                AS total_mandates,
            first_value(
                CASE WHEN pr.mandates_cvk IS NOT NULL
                    AND pr.mandates_cvk > 0
                THEN pr.party_code ELSE NULL END
            ) OVER order_rada_window                            AS party_winner,
            nullif(max(pr.mandates_cvk) OVER rada_window, 0)    AS winner_mandates,
            nullif(max(pr.votes_cvk) OVER rada_window, 0)       AS winner_votes,
            nullif(round(
                first_value(pr.mandates_cvk) OVER order_rada_window::numeric
                    / (CASE WHEN pr.elections_type = 'DEPUTY'
                        THEN max(r.mandates) OVER rada_window
                        ELSE 1 END)::numeric * 100,
                2
            ), 0)                                               AS winner_percent,
            nullif(sum(pr.mandates_cvk) OVER rada_window, 0)    AS elected_mandates,
            nullif(round(
                sum(pr.mandates_cvk) OVER rada_window::numeric
                    / (CASE WHEN pr.elections_type = 'DEPUTY'
                        THEN max(r.mandates)  OVER rada_window
                        ELSE 1 END)::numeric * 100,
                2
            ), 0)                                               AS elected_percent,
            sum(pr.votes_cvk) OVER rada_window                  AS total_votes,
            round(
                max(pr.votes_cvk) OVER rada_window ::numeric
                    / coalesce(
                        sum(pr.votes_cvk) OVER rada_window, 1
                        )::numeric * 100,
                2
            )                                                   AS votes_percent
        FROM radas r
            LEFT JOIN parties_results pr ON r.id = pr.rada_id
            WINDOW rada_window AS (
                PARTITION BY pr.rada_id, pr.elections_type
            ), order_rada_window AS (
                rada_window ORDER BY pr.mandates_cvk DESC NULLS LAST
            )
        ORDER BY r.atu_level
    )
    SELECT
        r.koatuu,
        r.full_name                                                 AS name,
        r.region_name                                               AS region,
        (CASE
            WHEN rw.elections_type = 'DEPUTY' THEN p.short_name
            WHEN rw.elections_type = 'MAYOR'  THEN c.full_name
        END)                                                        AS winner_name,
        (CASE
             WHEN rw.elections_type = 'DEPUTY'
                 OR rw.elected_mandates = 0 THEN NULL
             WHEN rw.elections_type = 'MAYOR'  THEN p.short_name
        END)                                                        AS winner_nomination,
        (CASE
             WHEN rw.elections_type = 'DEPUTY' THEN p.color
             WHEN rw.elections_type = 'MAYOR'
                AND rw.elected_mandates <> 0   THEN p.color
             ELSE NULL
        END)                                                        AS winner_color,
        rw.*,
        (CASE
            WHEN rw.elections_type = 'DEPUTY' THEN rw.votes_percent
            WHEN rw.elections_type = 'MAYOR' THEN
                round(c.votes::numeric
                        / rw.total_votes::numeric * 100, 2)
        END)                                                        AS votes_percent,
        (CASE
            WHEN rw.winner_percent >= 50 THEN 'strong'
            WHEN rw.winner_percent BETWEEN 25 AND 49 THEN 'moderate'
            WHEN rw.winner_percent < 25 THEN 'weak'
            WHEN rw.winner_percent = 0
                OR rw.winner_percent IS NULL THEN NULL
        END)                                                        AS winner_status
    FROM rada_winners rw
        LEFT JOIN parties p ON rw.party_winner = p.code
        LEFT JOIN radas r ON rw.rada_id = r.id
        LEFT JOIN candidates c
            ON rw.rada_id = c.rada_id
                AND rw.party_winner = c.party_code
                AND c.elections_type = 'MAYOR'
                AND c.is_elected = true
WITH DATA;

-- repeat voting:
SELECT
    full_name,
    repeat_voting
FROM radas WHERE repeat_voting IS NOT NULL;
--
SELECT
    c.id, c.full_name, c.is_elected, c.votes, r.full_name AS rada
FROM candidates c
         LEFT JOIN radas r on c.rada_id = r.id
WHERE c.elections_type = 'MAYOR'
  AND c.is_elected = true
  AND r.repeat_voting IS NOT NULL
ORDER BY rada;
-- delete winners from repeat voting radas mayors
UPDATE candidates c
SET is_elected = false
WHERE c.id IN (
    SELECT c.id
    FROM candidates c
        LEFT JOIN radas r on c.rada_id = r.id
    WHERE c.elections_type = 'MAYOR'
      AND c.is_elected = true
      AND r.repeat_voting IS NOT NULL
);


-- results popup
SELECT
    r.koatuu,
    r.full_name                 AS rada_name,
    r.region_name,
    p.short_name                AS party,
    r.mandates                  AS total_mandates,
    sum( pr.mandates) OVER ()   AS elected_mandates,
    round(
        sum( pr.mandates) OVER ()  ::numeric
            / r.mandates::numeric * 100,
        2
    )                           AS elected_mandates_percent,
    pr.mandates                 AS party_mandates,
    round(
        sum(pr.mandates)::numeric
            / r.mandates::numeric * 100,
        2
    )                           AS party_mandates_percent
FROM radas r
    LEFT JOIN parties_results pr ON pr.rada_id = r.id
    LEFT JOIN parties p ON p.code = pr.party_code
WHERE r.atu_level = 2 AND r.koatuu = '1410300000'
GROUP BY r.full_name,
         r.region_name,
         p.short_name,
         r.mandates,
         pr.mandates
ORDER BY pr.mandates DESC;
-- rada info
SELECT
    r.full_name                 AS name,
    r.region_name,
    r.mandates                  AS total,
    sum( pr.mandates)           AS mandates,
    round(
        sum( pr.mandates) ::numeric
            / r.mandates::numeric * 100,
        2
    )                           AS percent
FROM radas r
    LEFT JOIN parties_results pr ON pr.rada_id = r.id
WHERE r.atu_level = 2 AND r.koatuu = '1410300000'
GROUP BY r.full_name,
         r.region_name, r.mandates;

-- top parties
SELECT
    p.short_name                AS name,
    p.color                     AS color,
    r.mandates                  AS total,
    pr.mandates_cvk             AS mandates,
    round(
        pr.mandates_cvk::numeric
            / r.mandates::numeric * 100,
        2
    )                           AS percent
FROM radas r
    LEFT JOIN parties_results pr ON pr.rada_id = r.id
    LEFT JOIN parties p ON p.code = pr.party_code
WHERE r.atu_level = 1 AND r.koatuu = '7100000000'
ORDER BY mandates DESC;

SELECT
    ar.full_name AS name,
    ar.region_name,
    ar.koatuu AS koatuu,
    ag.centroid,
    sum(rw.total_mandates) AS total_mandates,
    sum(rw.total_mandates) AS total_mandates
FROM rada_winners_view rw
    LEFT JOIN radas r ON rw.rada_id = r.id
    LEFT JOIN atu a ON r.region_id = a.region_id AND a.level = 1
    LEFT JOIN radas ar ON a.koatuu = ar.koatuu AND a.level = ar.atu_level
    LEFT JOIN atu_geometry ag
          ON ar.koatuu = ag.koatuu AND ag.level = ar.atu_level
WHERE rw.atu_level = 3
  AND rw.elections_type = 'DEPUTY'
GROUP BY ar.full_name,
         ar.region_name,
         ar.koatuu,
         ag.centroid;

-- rada results info
SELECT
    r.full_name,
    r.region_name,
    r_info.districts,
    r_info.communities,
    r.mandates,
    c_info.candidates,
    round(
        c_info.candidates::numeric
            / r.mandates::numeric,
        1
    ) AS candidates_per_mandate,
    r.polling_stations,
    r.voters_drv,
    r.population,
    p_info.parties
FROM radas r
    LEFT JOIN LATERAL (
        SELECT
            count(*) FILTER (WHERE level = 2)   AS districts,
            count(*) FILTER (WHERE level = 3)   AS communities
        FROM atu WHERE region_id = r.region_id
    ) AS r_info ON true
    LEFT JOIN LATERAL (
        SELECT
            count(*) AS candidates
        FROM candidates c
        WHERE c.rada_id = r.id AND c.elections_type = 'DEPUTY'
    ) AS c_info ON true
    LEFT JOIN LATERAL (
        SELECT
            to_json(array_agg(row_to_json(p))) AS parties
        FROM (
            SELECT
                p.short_name                AS name,
                p.color                     AS color,
                r2.mandates                 AS total,
                pr.mandates_cvk             AS mandates,
                round(
                     pr.mandates_cvk::numeric
                     / r2.mandates::numeric * 100,
                     2
                )                           AS percent
            FROM radas r2
                LEFT JOIN parties_results pr ON pr.rada_id = r2.id
                LEFT JOIN parties p ON p.code = pr.party_code
            WHERE r2.atu_level = r.atu_level AND r2.koatuu = r.koatuu
            ORDER BY mandates DESC
        ) p
    ) AS p_info ON true
WHERE r.atu_level = 1
  AND r.koatuu = '7100000000';


-- rada results overview for deputies
SELECT
    to_json(array_agg(row_to_json(party_candidates)))
FROM (
     SELECT
         p.short_name                                AS name,
         p.color                                     AS color,
         ARRAY[
             max(pr.mandates_cvk),
             max(r2.mandates),
             round(
                             max(pr.mandates_cvk)::numeric
                             / max(r2.mandates)::numeric * 100,
                             2
                 )
        ]                                  AS values,
         to_json(
            array_agg(
                row_to_json(candidates.*)
                    ORDER BY candidates.tvo_number
            )
         )                                           AS candidates
     FROM radas r2
        LEFT JOIN parties_results pr
            ON pr.rada_id = r2.id AND pr.elections_type = 'DEPUTY'
        LEFT JOIN parties p ON p.code = pr.party_code
        LEFT JOIN LATERAL (
            SELECT
                c.full_name         AS name,
                c.date_of_birth     AS "dateOfBirth",
                c.age               AS age,
                ed.name             AS education,
                p2.short_name       AS affiliation,
                od.name             AS occupation,
                c.tvo_number
            FROM candidates c
                LEFT JOIN educations_dict ed ON c.education_id = ed.id
                LEFT JOIN parties p2 ON c.party_affiliation_code = p2.code
                LEFT JOIN occupations_dict od ON c.occupation_id = od.id
            WHERE c.rada_id = r2.id
              AND c.party_code = pr.party_code
              AND c.elections_type = 'DEPUTY'
              AND c.is_elected = true
            ORDER BY c.tvo_number
        ) AS candidates ON true
     WHERE r2.atu_level = 3 AND r2.koatuu = '0725081301'
     GROUP BY p.short_name, p.color
     ORDER BY max(pr.mandates_cvk) DESC NULLS LAST
) AS party_candidates;

-- rada results overview for mayors
SELECT
    to_json(array_agg(row_to_json(w)))
FROM (
    SELECT
        concat(c.full_name, ' (', p.short_name, ')')    AS name,
        p.color                                         AS color,
        ARRAY[
            c.votes,
            sum(c.votes) OVER (),
            round(
                c.votes::numeric
                    / sum(c.votes) OVER ()::numeric * 100,
            2)
        ]                                               AS values,
        to_json(ARRAY[row_to_json(ci.*)])               AS candidates
    FROM radas r2
        LEFT JOIN parties_results pr
            ON pr.rada_id = r2.id AND pr.elections_type = 'MAYOR'
        LEFT JOIN parties p ON p.code = pr.party_code
        LEFT JOIN candidates c
            ON c.rada_id = r2.id
                AND c.party_code = pr.party_code
                AND c.elections_type = 'MAYOR'
        LEFT JOIN LATERAL (
            SELECT
                c2.full_name         AS name,
                c2.date_of_birth     AS "dateOfBirth",
                c2.age               AS age,
                ed.name             AS education,
                p2.short_name       AS affiliation,
                od.name             AS occupation
            FROM candidates c2
                LEFT JOIN educations_dict ed ON c2.education_id = ed.id
                LEFT JOIN parties p2 ON c2.party_affiliation_code = p2.code
                LEFT JOIN occupations_dict od ON c2.occupation_id = od.id
            WHERE c2.id = c.id
        ) AS ci ON true
    WHERE r2.atu_level = 3 AND r2.koatuu = '0725081301'
    ORDER BY c.votes DESC NULLS LAST
) AS w;

-- Get party parties analysis report by radas
SELECT
    r.full_name             AS name,
    r.region_name           AS "regionName",
    r.koatuu                AS koatuu,
    ag.centroid             AS centroid,
    sum(pr.mandates_cvk)    AS mandates,
    max(r.mandates)         AS "totalMandates",
    round(
        sum(pr.mandates_cvk)::numeric
            / max(r.mandates) * 100::numeric,
        2
    )                       AS percent,
    json_build_object(
        'names', array_agg(p.short_name ORDER BY pr.mandates_cvk DESC NULLS LAST),
        'colors', array_agg(p.color ORDER BY pr.mandates_cvk DESC NULLS LAST),
        'mandates', array_agg(pr.mandates_cvk ORDER BY pr.mandates_cvk DESC NULLS LAST)

    ) AS parties
FROM radas r
    LEFT JOIN parties_results pr
        ON r.id = pr.rada_id AND pr.elections_type = 'DEPUTY'
    LEFT JOIN parties p ON pr.party_code = p.code
    LEFT JOIN atu_geometry ag
        ON r.koatuu = ag.koatuu AND r.atu_level = ag.level
WHERE pr.elections_type = 'DEPUTY'
  AND r.atu_level = 1
  AND pr.party_code IN (351,52) -- Слуга народу, ОПЗЖ
GROUP BY r.full_name, r.region_name, r.koatuu, pr.elections_type, ag.centroid
ORDER BY percent DESC NULLS LAST, r.koatuu;

-- Get elections overview /overview/elections
WITH data AS (
    SELECT
        r.atu_level                 AS "atuLevel",
        c.elections_type            AS "electionType",
        json_build_object(
            'name', p.short_name,
            'color', p.color,
            'count', count(c.id)
        ) AS "byCount",
        json_build_object(
            'name', p.short_name,
            'color', p.color,
            'count', count(DISTINCT c.rada_id)
        ) AS "byCover"
    FROM candidates c
        LEFT JOIN radas r ON r.id = c.rada_id
        LEFT JOIN parties p ON p.code  = c.party_code
    WHERE r.atu_level <= 3
    GROUP BY r.atu_level,
             c.elections_type,
             p.short_name,
             p.color,
             r.mandates
    ORDER BY r.atu_level, count(c.id) DESC
)
SELECT
    json_build_object(
        'regional', json_build_object(
                        'byCount', array_agg(d."byCount") FILTER (WHERE d."atuLevel" = 1),
                        'byCover', array_agg(d."byCover") FILTER (WHERE d."atuLevel" = 1)
                    ),
        'districts', json_build_object(
                        'byCount', array_agg(d."byCount") FILTER (WHERE d."atuLevel" = 2),
                        'byCover', array_agg(d."byCover") FILTER (WHERE d."atuLevel" = 2)
                    ),
        'communities', json_build_object(
                        'byCount', array_agg(d."byCount") FILTER (WHERE d."atuLevel" = 3 AND d."electionType" = 'DEPUTY'),
                        'byCover', array_agg(d."byCover") FILTER (WHERE d."atuLevel" = 3 AND d."electionType" = 'DEPUTY')
                    ),
        'mayors', json_build_object(
                        'byCount', array_agg(d."byCount") FILTER (WHERE d."atuLevel" = 3 AND d."electionType" = 'MAYOR'),
                        'byCover', array_agg(d."byCover") FILTER (WHERE d."atuLevel" = 3 AND d."electionType" = 'MAYOR')
                    )
    ) AS data
FROM data d;

WITH e_mandates AS (
    SELECT
        r.atu_level                     AS atu_level,
        'DEPUTY'::elections_type        AS elections_type,
        count(DISTINCT r.id)::int       AS radas,
        sum(r.mandates)::int            AS mandates
    FROM radas r
    GROUP BY r.atu_level
    UNION ALL
    SELECT
        r.atu_level                     AS atu_level,
        'MAYOR'::elections_type         AS elections_type,
        count(DISTINCT r.id)::int       AS radas,
        count(DISTINCT r.id)::int       AS mandates
    FROM radas r WHERE r.atu_level = 3 AND r.rada_type_id = 2 -- only cities
    GROUP BY r.atu_level
), e_candidates AS (
    SELECT
        r.atu_level                     AS atu_level,
        c.elections_type                AS elections_type,
        count(c.id)::int                AS candidates
    FROM radas r
        LEFT JOIN candidates c ON r.id = c.rada_id
    GROUP BY r.atu_level, c.elections_type
)
SELECT
    em.*,
    ec.candidates,
    round(
        ec.candidates::numeric
            / em.mandates::numeric,
        1
    ) AS "candidatesPerMandate"
FROM e_mandates em
    LEFT JOIN e_candidates ec
        ON em.atu_level = ec.atu_level
            AND em.elections_type = ec.elections_type;

SELECT
    json_build_object(
        'regional', json_build_object(
            'radas', max(eo.radas) FILTER (WHERE pro.atu_level = 1),
            'mandates', max(eo.mandates) FILTER (WHERE pro.atu_level = 1),
            'candidates', max(eo.candidates) FILTER (WHERE pro.atu_level = 1),
            'candidatesPerMandate', max(eo.candidates_per_mandate) FILTER (WHERE pro.atu_level = 1),
            'byCount', array_agg(pro.by_count) FILTER (WHERE pro.atu_level = 1),
            'byCover', array_agg(pro.by_cover) FILTER (WHERE  pro.atu_level = 1)
        ),
        'districts', json_build_object(
            'radas', max(eo.radas) FILTER (WHERE pro.atu_level = 2),
            'mandates', max(eo.mandates) FILTER (WHERE pro.atu_level = 2),
            'candidates', max(eo.candidates) FILTER (WHERE pro.atu_level = 2),
            'candidatesPerMandate', max(eo.candidates_per_mandate) FILTER (WHERE pro.atu_level = 2),
            'byCount', array_agg(pro.by_count) FILTER (WHERE pro.atu_level = 2),
            'byCover', array_agg(pro.by_cover) FILTER (WHERE  pro.atu_level = 2)
        ),
        'communities', json_build_object(
            'radas', max(eo.radas) FILTER (WHERE pro.atu_level = 3 AND pro.elections_type = 'DEPUTY'),
            'mandates', max(eo.mandates) FILTER (WHERE pro.atu_level = 3 AND pro.elections_type = 'DEPUTY'),
            'candidates', max(eo.candidates) FILTER (WHERE pro.atu_level = 3 AND pro.elections_type = 'DEPUTY'),
            'candidatesPerMandate', max(eo.candidates_per_mandate) FILTER (WHERE pro.atu_level = 3 AND pro.elections_type = 'DEPUTY'),
            'byCount', array_agg(pro.by_count) FILTER (WHERE pro.atu_level = 3 AND pro.elections_type = 'DEPUTY'),
            'byCover', array_agg(pro.by_cover) FILTER (WHERE  pro.atu_level = 3 AND pro.elections_type = 'DEPUTY')
        ),
        'mayors', json_build_object(
            'radas', max(eo.radas) FILTER (WHERE pro.atu_level = 3 AND pro.elections_type = 'MAYOR'),
            'mandates', max(eo.mandates) FILTER (WHERE pro.atu_level = 3 AND pro.elections_type = 'MAYOR'),
            'candidates', max(eo.candidates) FILTER (WHERE pro.atu_level = 3 AND pro.elections_type = 'MAYOR'),
            'candidatesPerMandate', max(eo.candidates_per_mandate) FILTER (WHERE pro.atu_level = 3 AND pro.elections_type = 'MAYOR'),
            'byCount', array_agg(pro.by_count) FILTER (WHERE pro.atu_level = 3 AND pro.elections_type = 'MAYOR'),
            'byCover', array_agg(pro.by_cover) FILTER (WHERE  pro.atu_level = 3 AND pro.elections_type = 'MAYOR')
        )
    ) AS data
FROM parties_ranking_overview pro
    LEFT JOIN elections_overview eo
        ON pro.elections_type = eo.elections_type
            AND pro.atu_level = eo.atu_level;


-- Get rada overview /overview/radas/{electionType}/{koatuu}
SELECT
    r.full_name                             AS name,
    r.region_name                           AS "regionName",
    max(r.mandates)                         AS mandates,
    count(c.id)                             AS candidates,
    round(
        count(c.id)::numeric
            / max(r.mandates)::numeric,
        1
    )                                       AS "candidatesPerMandate",
    count(DISTINCT c.party_code)            AS "partiesCount"
FROM radas r
    LEFT JOIN candidates c ON r.id = c.rada_id AND c.elections_type = 'DEPUTY'
WHERE r.atu_level = 1
  AND r.koatuu = '1800000000'
GROUP BY r.full_name, r.region_name

-- atu-info
SELECT
    (CASE
        WHEN count(*)
            FILTER (WHERE r.atu_level = 1) > 1
        THEN 'Україна'
        ELSE string_agg(name_uk::text, '')
                FILTER (WHERE a.level = 1)
    END)                                                       AS name,
    ARRAY [
        count(*)
            FILTER (WHERE r.atu_level = 1
                AND r.region_id NOT IN (101, 185, 180)
                ),
        count(*)
            FILTER (WHERE a.level = 1
                AND a.region_id NOT IN (101, 185, 180))
    ]                                                       AS regions,
    ARRAY [
        count(*) FILTER (WHERE r.atu_level = 2),
        count(*) FILTER (WHERE a.level = 2)
    ]                                                       AS districts,
    ARRAY [
        count(*) FILTER (WHERE r.atu_level = 3),
        count(*) FILTER (WHERE a.level = 3)
    ]                                                       AS communities,
    sum(r.population) FILTER (WHERE r.atu_level = 3)        AS population,
    sum(r.voters_drv) FILTER (WHERE r.atu_level = 3)        AS voters,
    sum(r.polling_stations) FILTER (WHERE r.atu_level = 3)  AS polling_stations
FROM atu a
    LEFT JOIN radas r
        ON a.koatuu = r.koatuu AND a.level = r.atu_level
WHERE a.region_id = 987
